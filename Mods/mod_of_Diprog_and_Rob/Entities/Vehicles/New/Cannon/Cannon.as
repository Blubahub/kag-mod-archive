#include "VehicleCommon.as";

// Mounted Bow logic

const Vec2f offsetCannon = Vec2f(-5,0);

void onInit( CBlob@ this )
{
    Vehicle_Setup( this,
                   0.0f, // move speed
                   0.31f,  // turn speed
                   Vec2f(0.0f, 2.0f), // jump out velocity
                   false  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
    Vehicle_SetupWeapon( this, v,
                         160, // fire delay (ticks)
                         1, // fire bullets amount
                         Vec2f(26.0f, -6.0f), // fire position offset
                         "mat_cannon_balls", // bullet ammo config name
                         "cannon_ball", // bullet config name
                         "CannonFire", // fire sound
                         "EmptyFire" // empty fire sound
                       );
    v.charge = 400;
    // init arm + cage sprites
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ arm = sprite.addSpriteLayer( "arm", sprite.getConsts().filename, 33, 16 );
	
    if (arm !is null)
    {
        Animation@ anim = arm.addAnimation( "new", 0, false );
		arm.SetRelativeZ( 1.0f );
		arm.SetOffset( offsetCannon);
        anim.AddFrame(1);
    }

    CSpriteLayer@ cage = sprite.addSpriteLayer( "cage", sprite.getConsts().filename, 33, 16 );

    if (cage !is null)
    {
        Animation@ anim = cage.addAnimation( "new", 0, false );
        anim.AddFrame(0);
    }

    this.getShape().SetRotationsAllowed( false );
	this.set_string("autograb blob", "mat_cannon_balls");

	sprite.SetZ(-10.0f);
	this.Tag("heavy weight");

	this.getCurrentScript().runFlags |= Script::tick_hasattached;	

	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob( "mat_cannon_balls" );
		if (ammo !is null)	{
			if (!this.server_PutInInventory( ammo ))
				ammo.server_Die();
		}
	}
}

f32 getAimAngle( CBlob@ this, VehicleInfo@ v )
{
    f32 angle = Vehicle_getWeaponAngle(this, v);
    bool facing_left = this.isFacingLeft();
    AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
    bool failed = true;

    if (gunner !is null && gunner.getOccupied() !is null)
    {
        gunner.offsetZ = 5.0f;
        Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if( this.isAttached() )
		{
			if (facing_left) { aim_vec.x = -aim_vec.x; }
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ( (!facing_left && aim_vec.x < 0) ||
					( facing_left && aim_vec.x > 0 ) )
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				angle = Maths::Max( -80.0f , Maths::Min( angle , 80.0f ) );
			}
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
    }

    return angle;
}

void onTick( CBlob@ this )
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}

		//set the arm angle based on GUNNER mouse aim, see above ^^^^
		f32 angle = getAimAngle( this, v );
		Vehicle_SetWeaponAngle( this, angle, v );
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer( "arm" );

		if (arm !is null)
		{
			bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left? -1: 1);

			arm.ResetTransform( );
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ( 1.0f );
			arm.RotateBy( rotation, Vec2f(facing_left?-4.0f:4.0f,-3.0f) );
		}


		Vehicle_StandardControls( this, v );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    if (!Vehicle_AddFlipButton( this, caller))
    {
        Vehicle_AddLoadAmmoButton( this, caller );
    }
}


bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused )
{
    if (bullet !is null)
    {
		u16 charge = v.charge;
        f32 angle = Vehicle_getWeaponAngle( this, v );
        angle = angle * (this.isFacingLeft() ? -1:1);
        angle += ((XORRandom(512) - 256) / 64.0f);
        
        Vec2f vel = Vec2f(charge/16.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
        bullet.setVelocity( vel );
        Vec2f offset = offsetCannon;
        offset.RotateBy(angle);
        //bullet.setPosition(this.getPosition() + offset*1.1f );
		// set much higher drag than archer arrow
		bullet.getShape().setDrag( bullet.getShape().getDrag() * 1.4f );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("fire blob"))
	{	  		
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_onFire( this, v, blob, charge );
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	}
}
