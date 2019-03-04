#include "VehicleCommon.as"
#include "ArrowDinghyControl.as"
void onInit(CBlob@ this )
{
    Vehicle_Setup( this,
                   100.0f, // move speed
                   0.31f,  // turn speed
                   Vec2f(0.0f, -2.5f), // jump out velocity
                   true  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
    Vehicle_SetupWaterSound( this, v, "BoatRowing", // movement sound
                             0.0f, // movement sound volume modifier   0.0f = no manipulation
                             0.0f // movement sound pitch modifier     0.0f = no manipulation
                           );
    this.getShape().SetOffset(Vec2f(0,9));
    this.getShape().SetCenterOfMassOffset(Vec2f(-1.5f,4.5f));
	this.getShape().getConsts().transports = true;
	this.Tag("heavy weight");
	
	if (getNet().isServer())// && hasTech( this, "mounted bow"))
	{
		CBlob@ bow = server_CreateBlob( "mounted_bow" );	
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow, "BOW" );
			this.set_u16("bowid",bow.getNetworkID());
		}
		
		CBlob@ sail = server_CreateBlob( "sail" );	
		if (sail !is null)
		{
			sail.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( sail, "SAIL" );
			this.set_u16("sailid",sail.getNetworkID());
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return (!this.isInWater() || this.isOnMap()) &&
			this.getOldVelocity().LengthSquared() < 4.0f;
}

void onTick( CBlob@ this )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	
	CBlob@ sail = getBlobByNetworkID(this.get_u16("sailid"));
	
	const int time = this.getTickSinceCreated();
	if (this.hasAttached() || time < 30) //driver, seat or gunner, or just created
		Vehicle_StandardControls( this, v );		
	
	if (sail.hasTag("up") && this.isInWater())
	{
		f32 turnSpeed = v.turn_speed;
        Vec2f vel = this.getVelocity();
		
		v.move_speed = 45;
		
		if (vel.x < -turnSpeed)
			Vehicle_SimulateControl( this, v, "left" );
		else 
			Vehicle_SimulateControl( this, v, "right" );
	}
	else v.move_speed = 100;
	if(this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if (bow !is null) bow.server_setTeamNum(this.getTeamNum());
	}
	if (sail !is null) sail.server_setTeamNum(this.getTeamNum());
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onAttach( this, v, attached, attachedPoint );
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onDetach( this, v, detached, attachedPoint );
}		

void onDie(CBlob@ this)
{
	if(this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if(bow !is null)
		{
			bow.server_Die();
		}
	}
	
	if(this.exists("sailid"))
	{
		CBlob@ sail = getBlobByNetworkID(this.get_u16("sailid"));
		if(sail !is null)
		{
			sail.server_Die();
		}
	}
}
