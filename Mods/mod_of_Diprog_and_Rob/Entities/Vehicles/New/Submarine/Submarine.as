#include "VehicleCommon.as"

// Boat logic

void onInit(CBlob@ this )
{
	Vehicle_Setup( this,
                   150.0f, // move speed
                   0.19f,  // turn speed
                   Vec2f(0.0f, -30.0f), // jump out velocity
                   true  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_SetupAirship( this, v, 900.0f );

    this.SetLight( true );
    this.SetLightRadius( 48.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    
	Vec2f pos_off(0,0);
    this.getShape().SetOffset(Vec2f(0,9));
    this.getShape().SetCenterOfMassOffset(Vec2f(0.0f,0.0f));
	this.getShape().getConsts().transports = true;
	this.getShape().getConsts().bullet = false;
	this.set_f32("map dmg modifier", 10.0f);
	this.Tag("blocks sword");

    AttachmentPoint@[] aps;
    if (this.getAttachmentPoints( @aps ))
    {
        for (uint i = 0; i < aps.length; i++)
        {
            AttachmentPoint@ ap = aps[i];
            ap.offsetZ = 10.0f;
		}
	}

    // override icon
 //   AddIconToken( "$"+this.getName()+"$", CFileMatcher("VehicleIcons.png").getFirst(), Vec2f(32,32), 2 );

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ front = sprite.addSpriteLayer( "front layer", sprite.getConsts().filename, 64, 32 );
	if (front !is null)
	{
		front.addAnimation("default",0,false);
		int[] frames = { 0, 1, 2 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(55.0f);
	}
	// Top
	{
		Vec2f[] shape = { Vec2f( 36.0f,  24.0f ) -pos_off,
						  Vec2f( 46.0f,  24.0f ) -pos_off,
						  Vec2f( 55.0f,  31.0f ) -pos_off,
						  Vec2f( 51.0f,  31.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	// Front
	{
		Vec2f[] shape = { Vec2f( 51.0f,  31.0f ) -pos_off,
						  Vec2f( 55.0f,  31.0f ) -pos_off,
						  Vec2f( 55.0f,  42.0f ) -pos_off,
						  Vec2f( 51.0f,  42.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	// Butts
	{
		Vec2f[] shape = { Vec2f( 4.0f,  31.0f ) -pos_off,
						  Vec2f( 8.0f,  31.0f ) -pos_off,
						  Vec2f( 8.0f,  42.0f ) -pos_off,
						  Vec2f( 4.0f,  42.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	// Back Top
	{
		Vec2f[] shape = { Vec2f( 12.0f,  25.0f ) -pos_off,
						  Vec2f( 14.0f,  25.0f ) -pos_off,
						  Vec2f( 8.0f,  31.0f ) -pos_off,
						  Vec2f( 4.0f,  31.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	CSpriteLayer@ rudder = sprite.addSpriteLayer( "rudder", "sub_blades", 4, 11 );
	if (rudder !is null)
	{
		rudder.addAnimation("default",4,true);
		int[] frames = { 1,2,3,4 };
		rudder.animation.AddFrames(frames);
		rudder.SetRelativeZ(5.0f);
		rudder.SetOffset(Vec2f(26,0.5));
	}
	
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}
void onTick( CBlob@ this )
{
	if(this.isInWater()) {
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_StandardControls( this, v );
	}
	Vehicle_DontRotateInWater( this );
}

void onTick( CSprite@ this )
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth()/blob.getInitialHealth()));
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_boat( this, blob );	
}