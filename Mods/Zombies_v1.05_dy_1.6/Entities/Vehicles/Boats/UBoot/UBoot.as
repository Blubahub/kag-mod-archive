#include "Vehicle2.as"

// Boat logic

const string charge_time_prop = "ballista charge time";
const u8 charge_time_max = 80;

const string cooldown_time_prop = "ballista cooldown time";
const u8 cooldown_time = 20;

void onInit(CBlob@ this )
{
	Vehicle_Setup( this,
                   185.0f, // move speed
                   0.38f,  // turn speed
                   Vec2f(0.0f, -1.2f), // jump out velocity
                   true  // inventory access
                 );
				 
	Vehicle_SetupWeapon( this,
					 cooldown_time, // fire delay (ticks)
					 1, // fire bullets amount
					 Vec2f(-6.0f, -8.0f), // fire position ffset
					 "mat_bolts", // bullet ammo config name
					 "ballista_bolt", // bullet config name
					 "CatapultFire", // fire sound
					 "EmptyFire", // empty fire sound
					 Vehicle_Fire_Style::custom
				   );
	
    Vehicle_SetupWaterSound( this,  "BoatRowing", // movement sound
                             0.0f, // movement sound volume modifier   0.0f = no manipulation
                             0.0f // movement sound pitch modifier     0.0f = no manipulation
                           );
    
	Vec2f pos_off(0,0);
    this.Tag("boat");
    this.Tag("respawn");
               
    this.getShape().SetOffset(Vec2f(-6,18));

    this.getShape().getConsts().bullet = true;
    
    AttachmentPoint@[] aps;
    if (this.getAttachmentPoints( @aps ))
    {
        for (uint i = 0; i < aps.length; i++)
        {
            AttachmentPoint@ ap = aps[i];
            ap.offsetZ = 10.0f;
		}
	}
    
	this.getShape().getConsts().transports = true;
    
	// additional shapes

	//{
	//	Vec2f[] shape = { Vec2f( 39.0f,  4.0f ) -pos_off,
	//					  Vec2f( 67.0f,  4.0f ) -pos_off,
	//					  Vec2f( 73.0f,  5.0f ) -pos_off,
	//					  Vec2f( 48.0f,  5.0f ) -pos_off };
	//	this.getShape().AddShape( shape );
	//}
	
	//back of entrance
	{
		Vec2f[] shape = { Vec2f( 46.0f,  20.0f ) -pos_off,
						  Vec2f( 48.0f,  20.0f ) -pos_off,
						  Vec2f( 46.0f,  21.0f ) -pos_off,
						  Vec2f( 48.0f,  21.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}

	{
		Vec2f[] shape = { Vec2f( 69.0f,  5.0f ) -pos_off,
						  Vec2f( 73.0f,  5.0f ) -pos_off,
						  Vec2f( 73.0f,  24.0f ) -pos_off,
						  Vec2f( 69.0f,  24.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	
	{
		Vec2f[] shape = { Vec2f( 69.0f,  23.0f ) -pos_off,
						  Vec2f( 93.0f,  31.0f ) -pos_off,
						  Vec2f( 79.0f,  43.0f ) -pos_off,
						  Vec2f( 69.0f,  45.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	
	//{
	//	Vec2f[] shape = { Vec2f( 2.0f,  24.0f ) -pos_off,
	//					  Vec2f( 49.0f, 24.0f ) -pos_off,
	//					  Vec2f( 49.0f, 26.0f ) -pos_off,
	//					  Vec2f( 3.0f,  26.0f ) -pos_off };
	//	this.getShape().AddShape( shape );
	//}
	
	//back
	{
		Vec2f[] shape = { Vec2f( 12.0f,  26.0f ) -pos_off,
						  Vec2f( 15.0f, 26.0f ) -pos_off,
						  Vec2f( 12.0f, 42.0f ) -pos_off,
						  Vec2f( 15.0f, 42.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	
	//back "ladder"
	{
		Vec2f[] shape = { Vec2f( 9.0f, 34.0f ) -pos_off,
						  Vec2f( 12.0f, 30.0f ) -pos_off,
						  Vec2f( 9.0f, 34.0f ) -pos_off,
						  Vec2f( 12.0f, 42.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	
	{
	//roof
		Vec2f[] shape = { Vec2f( 13.0f, 24.0f ) -pos_off,
						  Vec2f( 50.0f, 24.0f ) -pos_off,
						  Vec2f( 13.0f, 26.0f ) -pos_off,
						  Vec2f( 50.0f, 26.0f ) -pos_off };
		this.getShape().AddShape( shape );
	}
	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ front = sprite.addSpriteLayer( "front layer", sprite.getConsts().filename, 96, 56 );
	if (front !is null)
	{
		front.addAnimation("default",0,false);
		int[] frames = { 0 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(55.0f);
	}	
		
	//War Boat icon
	AddIconToken( "$"+this.getName()+"$", CFileMatcher("VehicleIcons.png").getFirst(), Vec2f(32,32), 2 );   // override icon    
    // init arm sprites
	CSpriteLayer@ arm = sprite.addSpriteLayer( "arm", "Ballista.png", 24, 40 );
    
	if (arm !is null)
    {
		f32 angle = getAngle(this, 0);
		
        Animation@ anim = arm.addAnimation( "default", 0, false );
        //anim.AddFrame(6);
       //anim.AddFrame(4);
       anim.AddFrame(10);
		CSpriteLayer@ arm = this.getSprite().getSpriteLayer( "arm" );	
		if (arm !is null)
		{
			arm.RotateBy( angle, Vec2f(0.0f,-13.0f) );
			//arm.TranslateBy( Vec2f(10.0f,-15.0f) );
			arm.SetOffset( Vec2f(-23.0f,20.0f) );
			arm.SetRelativeZ(60.0f);
		}
    }
    
    this.set_u8(charge_time_prop, 0);
    Vehicle_SetWeaponAngle( this, 0 );
	this.set_string("autograb blob", "mat_bolts");

	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob( "mat_bolts" );
		if (ammo !is null)	{
			if (!this.server_PutInInventory( ammo ))
				ammo.server_Die();
		}
	}
}

void onTick( CBlob@ this )
{
	//ballista
	if (this.hasAttached())
	{
		u8 cool = this.get_u8(cooldown_time_prop);
		if (cool > 0)
		{
			cool--;
			this.set_u8(cooldown_time_prop, cool);
		}
    
		f32 angle = getAngle(this, this.get_u8(charge_time_prop));

		Vehicle_SetWeaponAngle( this, angle );
    
		CSpriteLayer@ arm = this.getSprite().getSpriteLayer( "arm" );	 
		if (arm !is null)
		{
			arm.ResetTransform( );
			f32 floattime = getGameTime();
			//arm.TranslateBy( Vec2f(10.0f * sign,-15.0f) );
			arm.RotateBy( angle, Vec2f(0.0f,-13.0f) );
			arm.SetOffset( Vec2f(-23.0f,20.0f) );
			arm.SetRelativeZ(60.0f);
			/*
			if (this.get_u8("loaded ammo") > 0) {
				arm.animation.frame = 1;
			}
			else {
				arm.animation.frame = 0;
			}*/
		}

		Vehicle_StandardControls( this );
	}
	Vehicle_Update( this );
	Vehicle_DontRotateInWater( this );
	//this.AddForce( Vec2f(-500.0f,0.0f));
}

//void Vehicle_onFire( CBlob@ this, CBlob@ bullet, const u8 charge ) {}
//bool Vehicle_canFire( CBlob@ this , bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_boat( this, blob );
}			 

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

void onTick( CSprite@ this )
{
	this.SetZ(-50.0f);	
}

f32 getAngle(CBlob@ this, const u8 charge)
{
	if (charge > 0)			   // don't allow rotation while charging
		return Vehicle_getWeaponAngle( this );

    f32 angle = 0.0f;
    bool facing_left = this.isFacingLeft();
    AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("UBOOT_GUNNER");
    bool failed = true;

    if (gunner !is null && gunner.getOccupied() !is null)
    {
        Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

        if ( (!facing_left && aim_vec.x < 0) ||
                ( facing_left && aim_vec.x > 0 ) )
        {
            if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

            angle = (-(aim_vec).getAngle() + 270.0f);
            angle = Maths::Max( 0.0f , Maths::Min( angle , 90.0f ) );
        }
    }

    if (facing_left) { angle *= -1; }

    return angle;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    if (!Vehicle_AddFlipButton( this, caller))
    {
        Vehicle_AddLoadAmmoButton( this, caller );
    }
}//

bool Vehicle_canFire( CBlob@ this , bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
	u8 charge = this.get_u8(charge_time_prop);
	
	if (charge > 0 || isActionPressed)
	{	
		if (charge < charge_time_max && isActionPressed)
		{
			charge++;
			this.set_u8(charge_time_prop,charge);

			u8 t = Maths::Round(float(charge_time_max)*0.66f);
			if ((charge < t && charge % 10 == 0) || (charge >= t && charge % 5 == 0))
				this.getSprite().PlaySound( "/LoadingTick" );

			chargeValue = charge;
			return false;
		}
		chargeValue = charge;
		return true;
	}
	
	return false;
}

void Vehicle_onFire( CBlob@ this, CBlob@ bullet, const u8 _charge )
{
    if (bullet !is null)
    {
		u8 charge_prop = _charge;
		
		f32 charge = 20.0f * (float(charge_prop) / float(charge_time_max));
		
        f32 angle = getAngle( this, _charge );
        Vec2f vel = Vec2f(0.0f, -charge).RotateBy(angle);
        bullet.setVelocity( vel );
        bullet.setPosition(bullet.getPosition() + vel );
    }
    
    this.set_u8(charge_time_prop,0);
    this.set_u8(cooldown_time_prop,cooldown_time);
}
