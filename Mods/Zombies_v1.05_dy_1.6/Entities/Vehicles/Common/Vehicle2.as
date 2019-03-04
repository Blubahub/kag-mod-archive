#include "SeatsCommon.as"
#include "VehicleAttachmentCommon.as"

// HOOKS THAT YOU MUST IMPLEMENT WHEN INCLUDING THIS FILE
// void Vehicle_onFire( CBlob@ this, CBlob@ bullet, const u8 charge )
//		bullet will be null on client! always check for null
// bool Vehicle_canFire( CBlob@ this, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )


namespace Vehicle_Fire_Style
{
enum Style{
	normal = 0, //fires as soon as the charge is done
	custom, //fires if the charge is done, but also calls Vehicle_preFire
};
}

void Vehicle_Setup( CBlob@ this,
                    f32 moveSpeed, f32 turnSpeed, Vec2f jumpOutVelocity, bool inventoryAccess
                  )
{
    this.set_u32("fire time", 0);
    this.set_u8("loaded ammo",0);
    this.set_string("fire sound", "" );
    this.set_string("empty sound", "" );
    this.set_string("bullet name", "" );
    this.set_bool("blob ammo", false );
    this.set_string("ammo name", "" );
    this.set_u16("fire delay", 0 );
    this.set_u8("fire amount", 0);
    this.set_Vec2f("fire pos", Vec2f_zero );
    this.set_f32("move speed", moveSpeed);
    this.set_f32("turn speed", turnSpeed);
    this.set_Vec2f( "out vel", jumpOutVelocity );
    this.set_bool( "inventoryAccess", inventoryAccess );
	this.set_u16("ammo stocked", 0);
    this.addCommandID("fire");
    this.addCommandID("fire blob");
    this.addCommandID("flip_over");
    this.addCommandID("getin_mag");
    this.addCommandID("load_ammo");
    this.addCommandID("putin_mag");
    this.addCommandID("vehicle getout");
    this.addCommandID("reload");
    //this.Tag("heavy weight");
	this.Tag("vehicle");
	this.getShape().getConsts().collideWhenAttached = true;
    AttachmentPoint@ mag = getMagAttachmentPoint( this );

    if (mag !is null)
    {
        this.set_Vec2f("mag offset", mag.offset);
    }

    AddIconToken( "$LoadAmmo$", "GUI/InteractionIcons.png", Vec2f(16,16), 7, 7 );
}

void Vehicle_SetupWeapon( CBlob@ this, int fireDelay, int fireAmount, Vec2f firePosition, const string& in ammoConfigName, const string& in bulletConfigName,
                          const string& in fireSound, const string& in emptySound, Vehicle_Fire_Style::Style fireStyle = Vehicle_Fire_Style::normal )
{
    this.set_u32("fire time", getGameTime());
    this.set_u8("loaded ammo",0);
    this.set_string("fire sound", fireSound );
    this.set_string("empty sound", emptySound );
    this.set_string("bullet name", bulletConfigName );
    this.set_bool("blob ammo", hasMag(this) );
    this.set_string("ammo name", ammoConfigName );
    
    this.set_u16("fire delay", fireDelay );
    this.set_u8("fire amount", fireAmount);
    
    this.set_u8("fire style", fireStyle);
    
	this.set_f32( "wep_angle", 0.0f );
}

void Vehicle_SetupGroundSound( CBlob@ this, const string& in movementSound, f32 movementVolumeMod, f32 movementPitchMod )
{
    this.set_string("ground sound", movementSound);
    this.set_f32("ground volume", movementVolumeMod);
    this.set_f32("ground pitch", movementPitchMod);
    this.getSprite().SetEmitSoundPaused( true );
}

void Vehicle_SetupWaterSound( CBlob@ this, const string& in movementSound, f32 movementVolumeMod, f32 movementPitchMod )
{
    this.set_string("water sound", movementSound);
    this.set_f32("water volume", movementVolumeMod);
    this.set_f32("water pitch", movementPitchMod);
    this.getSprite().SetEmitSoundPaused( true );
}

void Vehicle_Update( CBlob@ this )
{
    // wheels
	if (this.getShape().vellen > 0.07f && !this.isAttached()) {
		UpdateWheels( this );
	}

    // reload
	if (this.hasAttached())
	{
		f32 time_til_fire = Maths::Max((this.get_u32("fire time") - getGameTime()), 1);	 
		if (time_til_fire < 2) {
			Vehicle_LoadAmmoIfEmpty( this );
		}
	}

    // update movement sounds    
    f32 velx = Maths::Abs(this.getVelocity().x);

    // ground sound

    if (velx < 0.02f || (!this.isOnGround() && !this.isInWater()) )
    {
		CSprite@ sprite = this.getSprite();
        f32 vol = sprite.getEmitSoundVolume();
        sprite.SetEmitSoundVolume( vol*0.9f );
        if (vol < 0.1f)
        {
            sprite.SetEmitSoundPaused( true );
            sprite.SetEmitSoundVolume( 1.0f );
        }
    }
    else
    {
        if (this.isOnGround() && this.exists("ground sound"))
        {
			CSprite@ sprite = this.getSprite();
            if (sprite.getEmitSoundPaused())
            {
                this.getSprite().SetEmitSound( CFileMatcher(this.get_string("ground sound")).getRandom() );
                sprite.SetEmitSoundPaused( false );
            }

            f32 volMod = this.get_f32("ground volume");
            f32 pitchMod = this.get_f32("ground pitch");

            if (volMod > 0.0f) {
                sprite.SetEmitSoundVolume( Maths::Min( velx*0.565f * volMod, 1.0f ) );
            }

            if (pitchMod > 0.0f) {
                sprite.SetEmitSoundSpeed( Maths::Max( Maths::Min( Maths::Sqrt(0.5f * velx * pitchMod), 1.5f ), 0.75f ) );
            }
        }
        else if (this.isInWater() && this.exists("water sound"))
        {
			CSprite@ sprite = this.getSprite();
            if (sprite.getEmitSoundPaused())
            {
                this.getSprite().SetEmitSound( CFileMatcher(this.get_string("water sound")).getRandom() );
                sprite.SetEmitSoundPaused( false );
            }

            f32 volMod = this.get_f32("water volume");
            f32 pitchMod = this.get_f32("water pitch");

            if (volMod > 0.0f) {
                sprite.SetEmitSoundVolume( Maths::Min( velx*0.565f * volMod, 1.0f ) );
            }

            if (pitchMod > 0.0f) {
                sprite.SetEmitSoundSpeed( Maths::Max( Maths::Min( Maths::Sqrt(0.5f * velx * pitchMod), 1.5f ), 0.75f ) );
            }
        }
    }	   
}

int server_LoadAmmo(CBlob@ this, CBlob@ ammo, int take)
{
    u8 loadedAmmo = this.get_u8("loaded ammo");
    int amount = ammo.getQuantity();

    if (amount >= take)
    {
        loadedAmmo += take;
        ammo.server_SetQuantity(amount-take);
    }
    else if (amount > 0)  // take rest
    {
        loadedAmmo += amount;
        ammo.server_SetQuantity(0);
    }

    if (loadedAmmo > 0) {
        SetOccupied( this.getAttachments().getAttachmentPointByName("MAG"), 1 );
    }

    this.set_u8("loaded ammo", loadedAmmo);
    CBitStream params;
    params.write_u8( loadedAmmo );
    this.SendCommand( this.getCommandID("reload"), params );

    // no ammo left - remove from inv and die
	const u16 ammoQuantity = ammo.getQuantity();
    if (ammoQuantity == 0)
    {
        this.server_PutOutInventory( ammo );
        ammo.server_Die();
    }

	// ammo count for GUI
	RecountAmmo( this );

    return loadedAmmo;
}

void RecountAmmo( CBlob@ this )
{												 
	int ammoStocked = this.get_u8("loaded ammo") - this.get_u8("fire amount");
	const string ammoName = this.get_string("ammo name");
	for (int i = 0; i < this.getInventory().getItemsCount(); i++)
	{
		CBlob@ invItem = this.getInventory().getItem(i);
		if (invItem.getName() == ammoName) {
			ammoStocked += invItem.getQuantity();
		}
	}
	this.set_u16("ammo stocked", ammoStocked );
	this.Sync("ammo stocked", true);
}

AttachmentPoint@ getMagAttachmentPoint( CBlob@ this )
{
    return this.getAttachments().getAttachmentPointByName("MAG");
}

CBlob@ getMagBlob( CBlob@ this )
{
    return this.getAttachments().getAttachedBlob("MAG");
}

bool isMagEmpty(CBlob@ this)
{
    return (getMagBlob(this) is null);
}

bool hasMag(CBlob@ this)
{
    return (getMagAttachmentPoint(this) !is null);
}

bool canFire( CBlob@ this )
{
    return ((getGameTime() > this.get_u32("fire time")));
}

void Vehicle_SetWeaponAngle( CBlob@ this, f32 angleDegrees )
{
    this.set_f32( "wep_angle", angleDegrees );
}

f32 Vehicle_getWeaponAngle( CBlob@ this )
{
    return this.get_f32( "wep_angle" );
}

void Vehicle_LoadAmmoIfEmpty( CBlob@ this )
{
    if (getNet().isServer() && this.getInventory().getItemsCount() > 0 &&
            getMagBlob(this) is null &&
            this.get_u8("loaded ammo") == 0)
    {
        CBlob@ toLoad = this.getInventory().getItem(0);

        if (toLoad.getName() == this.get_string("ammo name"))
        {
            server_LoadAmmo(this, toLoad, this.get_u8("fire amount"));
        }
        else if (this.get_bool("blob ammo") && this.server_PutOutInventory( toLoad )) {
            this.server_AttachTo( toLoad, "MAG" );
        }
    }
}

void SetFireDelay( CBlob@ this, int shot_delay )
{
    this.set_u32("fire time", (getGameTime() + shot_delay));
}

bool Vehicle_AddFlipButton( CBlob@ this, CBlob@ caller )
{
    if (isFlipped(this))
    {
        CButton@ button = caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("flip_over"), "Flip back" );

        if (button !is null)
        {
            button.deleteAfterClick = false;
            return true;
        }
    }

    return false;
}

bool MakeLoadAmmoButton( CBlob@ this, CBlob@ caller, Vec2f offset )
{
    // find ammo in inventory
    CInventory@ inv = caller.getInventory();

    if (inv !is null)
    {
        string ammo = this.get_string("ammo name");
        CBlob@ ammoBlob = inv.getItem( ammo );

        //check hands
        if (ammoBlob is null)
        {
            CBlob@ held = caller.getCarriedBlob();

            if (held !is null)
            {
                if (held.getName() == ammo) {
                    @ammoBlob = held;
                }
            }
        }

        if (ammoBlob !is null)
        {
            CBitStream callerParams;
            callerParams.write_u16(caller.getNetworkID());
            caller.CreateGenericButton( "$"+ammoBlob.getName()+"$", offset, this, this.getCommandID("load_ammo"), "Load " + ammoBlob.getInventoryName(), callerParams );
            return true;
        }

        /*else
        {
            CButton@ button = caller.CreateGenericButton( "$DISABLED$", offset, this, 0, "Needs " + ammoBlob.getInventoryName() );
            if (button !is null) button.enableRadius = 0.0f;
            return true;
        }*/
    }

    return false;
}

bool Vehicle_AddLoadAmmoButton( CBlob@ this, CBlob@ caller )
{
    // MAG
    if (!hasMag(this))
    {
        return MakeLoadAmmoButton( this, caller, Vec2f_zero );
    }
    else
    {
        // MAG
        //if (!isMagEmpty(this))
        //{
        //    CButton@ button = caller.CreateGenericButton( "$DISABLED$", getMagAttachmentPoint(this).offset, this, 0, "" );

        //    if (button !is null) { button.enableRadius = 0.0f; }

        //    return true;
        //}

        // put in what is carried
        CBlob@ carryObject = caller.getCarriedBlob(); 
        if (carryObject !is null && !carryObject.isSnapToGrid())  // not spikes or door
        {
            CBitStream callerParams;
            callerParams.write_u16(caller.getNetworkID());
            callerParams.write_u16(carryObject.getNetworkID());
            caller.CreateGenericButton( "$"+carryObject.getName()+"$", getMagAttachmentPoint(this).offset, this, this.getCommandID("putin_mag"), "Load " + carryObject.getInventoryName(), callerParams );
            return true;
        }
        else  // nothing in hands - take automatic
        {
            return MakeLoadAmmoButton( this, caller, getMagAttachmentPoint(this).offset );
        }
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    bool isServer = getNet().isServer();

    /// LOAD AMMO
    if (isServer && cmd == this.getCommandID("load_ammo"))
    {
        CBlob@ caller = getBlobByNetworkID( params.read_u16() );
        if (caller !is null)
        {
			// take all ammo blobs from caller and try to put in vehicle
			const string ammo = this.get_string("ammo name");
			array<CBlob@> ammos;

			CBlob@ carryObject = caller.getCarriedBlob(); 
			if (carryObject !is null && carryObject.getName() == ammo) {
				ammos.push_back( carryObject );
			}
						
			for (int i = 0; i < caller.getInventory().getItemsCount(); i++)
			{
				CBlob@ invItem = caller.getInventory().getItem(i);
				if (invItem.getName() == ammo) {
					ammos.push_back( invItem );					
				}
			}

			for (int i = 0; i < ammos.length; i++) {
				if (!this.server_PutInInventory( ammos[i] )) {
					caller.server_PutInInventory( ammos[i] );
				}
			}

			RecountAmmo( this );
        }
    }
    /// PUT IN MAG
    else if (isServer && cmd == this.getCommandID("putin_mag"))
    {
        CBlob@ caller = getBlobByNetworkID( params.read_u16() );
        CBlob@ blob = getBlobByNetworkID( params.read_u16() );
        if (caller !is null && blob !is null)
        {
			// put what was in mag into inv
			CBlob@ magBlob = getMagBlob(this);
			if (magBlob !is null)
			{
				magBlob.server_DetachFromAll();
				this.server_PutInInventory(magBlob);
			}
            blob.server_DetachFromAll();
            this.server_AttachTo( blob, "MAG" );
        }
    }
    /// FIRE
    else if (cmd == this.getCommandID("fire"))
    {
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		const u8 charge = params.read_u8();
        Fire( this, caller, charge );
    }
    /// FIRE BLOB
    else if (cmd == this.getCommandID("fire blob"))
    {
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		const u8 charge = params.read_u8();
        Vehicle_onFire( this, blob, charge );
    }
    /// FLIP OVER
    else if (cmd == this.getCommandID("flip_over"))
    {
        if (isFlipped(this))
        {
            this.getShape().SetStatic( false );
            this.getShape().doTickScripts = true;
            f32 angle = this.getAngleDegrees();
            this.AddTorque(angle < 180 ? -1000:1000);
            this.AddForce(Vec2f(0,-1000));
        }
    }
    /// GET IN MAG
    else if (isServer && cmd == this.getCommandID("getin_mag"))
    {
        CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null) 
			this.server_AttachTo( caller, "MAG" );
    }
    /// GET OUT
    else if (isServer && cmd == this.getCommandID("vehicle getout"))
    {
        CBlob@ caller = getBlobByNetworkID( params.read_u16() );

        if (caller !is null)  {
            this.server_DetachFrom( caller );
        }
    }
    /// RELOAD as in server_LoadAmmo   - client-side
    else if (!isServer && cmd == this.getCommandID("reload"))
    {
        u8 loadedAmmo = params.read_u8();

        if (loadedAmmo > 0 && this.getAttachments() !is null) {
            SetOccupied( this.getAttachments().getAttachmentPointByName("MAG"), 1 );
        }

        this.set_u8("loaded ammo", loadedAmmo);
    }
}

void Fire( CBlob@ this, CBlob@ caller, const u8 charge )
{
    // normal fire
    if ( canFire(this) && caller !is null ) // can fire
    {
        CBlob @blobInMag = getMagBlob(this);
        CBlob @carryObject = caller.getCarriedBlob();
        AttachmentPoint@ mag = getMagAttachmentPoint( this );
        Vec2f bulletPos;

        if (mag !is null)
        {
            bulletPos = mag.getPosition();
        }
        else
        {
            bulletPos = this.get_Vec2f("fire pos");	
            if (!this.isFacingLeft()) {
                bulletPos.x = -bulletPos.x;
            }	   
            bulletPos = caller.getPosition() + bulletPos;
        }

        bool shot = false;

		// fire whatever was in the mag/bowl first
		if (blobInMag !is null)
		{
			this.server_DetachFrom( blobInMag );
			server_FireBlob( this, blobInMag, charge );
			shot = true;
		}										  
		else
		{
			u8 loadedAmmo = this.get_u8("loaded ammo");
			if (loadedAmmo != 0) // shoot if ammo loaded
			{
				shot = true;

				const int team = caller.getTeamNum();	 
				const bool isServer = getNet().isServer();
				for (u8 i = 0; i < loadedAmmo; i++) 
				{
					CBlob@ bullet = isServer ? server_CreateBlobNoInit( this.get_string("bullet name") ) : null;
					if (bullet !is null)
					{
						bullet.setPosition( bulletPos );
						bullet.server_setTeamNum( team );
						bullet.Init();
					}

					Vehicle_onFire( this, bullet, charge );

					if (bullet !is null)
					{
						//bullet.Init(); // erases vel and pos data :(
					}
				}

				this.set_u8("loaded ammo",0);
				SetOccupied( mag, 0 );
			}
		}

        // sound

        if (shot) {
            this.getSprite().PlaySound( CFileMatcher(this.get_string("fire sound")).getRandom() );
        }
        else
        {   // empty shot
            this.getSprite().PlaySound( CFileMatcher(this.get_string("empty sound")).getRandom() );
            Vehicle_onFire( this, null, 0 );
        }

        // finally set the delay
        SetFireDelay( this, this.get_u16("fire delay"));
    }
}

void server_FireBlob( CBlob@ this, CBlob@ blob, const u8 charge )
{
    if (blob !is null)
    {
        CBitStream params;
        params.write_netid( blob.getNetworkID() );
		params.write_u8( charge );
        this.SendCommand( this.getCommandID("fire blob"), params );
    }
}

void Vehicle_StandardControls( CBlob@ this )
{
    f32 angle = this.getAngleDegrees();
    AttachmentPoint@[] aps;

    if (this.getAttachmentPoints( @aps ))
    {
        for (uint i = 0; i < aps.length; i++)
        {
            AttachmentPoint@ ap = aps[i];
            CBlob@ blob = ap.getOccupied();

            if (blob !is null && ap.socket)
            {
				// GET OUT
                if (blob.isMyPlayer() && ap.isKeyJustPressed( key_up))
                {
                    CBitStream params;
                    params.write_u16( blob.getNetworkID() );
                    this.SendCommand( this.getCommandID("vehicle getout"), params );
                    return;
                } // get out

                // DRIVER

                if (this.isOnGround() && ap.name == "DRIVER")
                {
					// set facing
					blob.SetFacingLeft( this.isFacingLeft() );
					
                    // left / right
                    if (angle < 80 || angle > 290)
                    {
                        f32 moveForce = this.get_f32("move speed");
                        f32 turnSpeed = this.get_f32("turn speed");
                        Vec2f groundNormal = this.getGroundNormal();
                        Vec2f vel = this.getVelocity();
                        Vec2f force;

                        // more force when starting
                        if (this.getShape().vellen < 0.1f) {
                            moveForce *= 5.0f;
                        }

                        // more force on boat
                        if (!this.isOnMap() && this.isOnGround()) {
                            moveForce *= 1.5f;
                        }

                        bool slopeangle = (angle > 15 && angle < 345 && this.isOnMap());

                        if (ap.isKeyPressed( key_left ))
                        {
                            if (groundNormal.y < -0.4f && groundNormal.x > 0.05f && vel.x < 1.0f && slopeangle) { // put more force when going up
                                force.x -= 7.0f * moveForce;
                            }
                            else {
                                force.x -= moveForce;
                            }

                            if (vel.x < -turnSpeed) {
                                this.SetFacingLeft( true );
                            }
                        }

                        if (ap.isKeyPressed( key_right ))
                        {
                            if (groundNormal.y < -0.4f && groundNormal.x < -0.05f && vel.x > -1.0f && slopeangle) { // put more force when going up
                                force.x += 7.0f * moveForce;
                            }
                            else {
                                force.x += moveForce;
                            }

                            if (vel.x > turnSpeed) {
                                this.SetFacingLeft( false );
                            }
                        }

                        force.RotateBy(this.getShape().getAngleDegrees());
                        this.AddForce(force);
                    }

                    // climb uphills

                    if (ap.isKeyPressed( key_down ) || ap.isKeyPressed( key_action3 ))
                    {
                        if (angle > 330 || angle < 30)
                        {
                            f32 wallMultiplier = (this.isOnWall() && (angle > 345 || angle < 15)) ? 1.2f : 1.0f;
                            f32 torque = 150.0f * wallMultiplier;
                            this.AddTorque( this.isFacingLeft() ? torque : -torque );
                            this.AddForce(Vec2f(0.0f,-200.0f * wallMultiplier));
                        }

                        if (isFlipped(this))
                        {
                            f32 angle = this.getAngleDegrees();
                            this.AddTorque(angle < 180 ? -500:500);
                            this.AddForce(Vec2f(0,-1000));
                        }
                    }
                }  // driver

                if (blob.isMyPlayer() && ap.name == "GUNNER" || blob.isMyPlayer() && ap.name == "UBOOT_GUNNER")
                {
					// set facing
					blob.SetFacingLeft( this.isFacingLeft() );
					
					const u8 style = this.get_u8 ("fire style" );
					switch (style)
					{
						case Vehicle_Fire_Style::normal:
						if ( ap.isKeyPressed( key_action1 ) )
						{
							if (canFire(this))
							{
								CBitStream fireParams;
								fireParams.write_u16( blob.getNetworkID() );
								fireParams.write_u8( 0 );
								this.SendCommand( this.getCommandID("fire"), fireParams );
							}
						}
						break;
						
						case Vehicle_Fire_Style::custom:
						{
						u8 charge = 0;
						if (canFire(this) && Vehicle_canFire(this, ap.isKeyPressed( key_action1 ), ap.wasKeyPressed( key_action1 ), charge))
						{
							CBitStream fireParams;
							fireParams.write_u16( blob.getNetworkID() );
							fireParams.write_u8( charge );
							this.SendCommand( this.getCommandID("fire"), fireParams );
						}
						}
						
						break;
					}
                } // gunner

                // ROWER

                if ( (ap.name == "ROWER" && this.isInWater()) || (ap.name == "SAIL" && !this.hasTag("no sail") ))
                {
                    f32 moveForce = this.get_f32("move speed");
                    f32 turnSpeed = this.get_f32("turn speed");
                    f32 torque = 0.0f;
                    f32 BowTorque = 110.0f;
                    Vec2f force;
                    bool moving = false;
                    const bool left = ap.isKeyPressed( key_left );
                    const bool right = ap.isKeyPressed( key_right );
                    const Vec2f vel = this.getVelocity();

					bool backwards = false;

                    // row left/right

                    if (left)
                    {
                        force.x -= moveForce;

                        if (vel.x < -turnSpeed)
                        {
                            this.SetFacingLeft( true );
                            torque += BowTorque;
                        }
                        else
                        {
							backwards = true;
						}

                        moving = true;
                    }

                    if (right)
                    {
                        force.x += moveForce;

                        if (vel.x > turnSpeed)
                        {
                            this.SetFacingLeft( false );
                            torque -= BowTorque;
                        }
                        else
                        {
							backwards = true;
						}

                        moving = true;
                    }
                    
                    if (moving)
                    {
						if (backwards)
							force *= 0.5f;
						
                        force.RotateBy(this.getAngleDegrees());
                        this.AddForce(force);
                        this.AddTorque(torque);
                    }
                } // rower
				
				// UBOOT
				
				if ( (ap.name == "UBOOT_GUNNER" && this.isInWater()))
                {
					blob.set_s8("air_count", 100);
				}

                if ( (ap.name == "UBOOT" && this.isInWater()))
                {
                    f32 moveForce = this.get_f32("move speed");
                    f32 turnSpeed = this.get_f32("turn speed");
                    f32 torque = 0.0f;
                    f32 BowTorque = 110.0f;
                    Vec2f force;
                    bool moving = false;
                    const bool left = ap.isKeyPressed( key_left );
                    const bool right = ap.isKeyPressed( key_right );
					const bool up = ap.isKeyPressed( key_up );
                    const bool down = ap.isKeyPressed( key_down );
                    const Vec2f vel = this.getVelocity();
					
					blob.set_s8("air_count", 80);

					bool backwards = false;

                    // row left/right

                    if (left)
                    {
                        if (vel.x < -turnSpeed)
                        {
                            this.SetFacingLeft( true );
                            torque += BowTorque;
                        }
                        else
                        {
							backwards = true;
						}
						
						if (vel.x > -0.16 && vel.x < 0)
                        {
						    force.x -= moveForce*2.0;
							//force.y += moveForce*15.0;
                        }
                        else
                        {
						    force.x -= moveForce*3.0;
							//force.y += moveForce*3.6;
						}

                        moving = true;
                    }

                    if (right)
                    {		
                        if (vel.x > turnSpeed)
                        {
                            this.SetFacingLeft( false );
                            torque -= BowTorque;
                        }
                        else
                        {
							backwards = true;
						}
						
						if (vel.x < 0.16 && vel.x > 0)
                        {
						    force.x += moveForce*2.0;
							//force.y += moveForce*15.0;
                        }
                        else
                        {
						    force.x += moveForce*3.0;
							//force.y += moveForce*3.6;
						}

                        moving = true;
                    }
					
					if (down)
                    {
						if(!right && !left)
						{
							force.y += moveForce*10.0;
						}
						else
						{
							force.y += moveForce*2.0;
						}

                        moving = true;
                    }
                    
                    if (moving)
                    {
						if (backwards)
							force *= 0.5f;
						
                        force.RotateBy(this.getAngleDegrees());
                        this.AddForce(force);
                        this.AddTorque(torque);
                    }
                } // rower
            }  // ap.occupied
        }   // for
    }
}

CSpriteLayer@ Vehicle_addWheel( CBlob@ this, const string& in textureName, int frameWidth, int frameHeight, int frame, Vec2f offset )
{
    if (!this.exists("wheels_angle")) {
        this.set_u8( "wheels_angle", 0 );
    }

    CSpriteLayer@ wheel = this.getSprite().addSpriteLayer( "!w", textureName, frameWidth, frameHeight );

    if (wheel !is null)
    {
        Animation@ anim = wheel.addAnimation( "default", 0, false );
        anim.AddFrame(frame);
        wheel.SetOffset( offset );
    }

    return wheel;
}

CSpriteLayer@ Vehicle_addWoodenWheel( CBlob@ this, int frame, Vec2f offset )
{
    return Vehicle_addWheel( this, "Entities/Vehicles/Common/WoodenWheels.png", 16, 16, frame, offset );
}

void UpdateWheels( CBlob@ this )
{
    //if (!this.isOnMap()) {
    //    return;
    //}

    //rotate wheels
    CSprite@ sprite = this.getSprite();
    uint sprites = sprite.getSpriteLayerCount();

    for (uint i = 0; i < sprites; i++)
    {
        CSpriteLayer@ wheel = sprite.getSpriteLayer( i );	
        if (wheel.name == "!w") // this is a wheel
        {
            f32 wheels_angle = (Maths::Round(wheel.getWorldTranslation().x * 10) % 360 ) / 1.0f;
            wheel.ResetTransform();
            wheel.RotateBy(wheels_angle + i * i * 16.0f, Vec2f_zero);
            wheel.SetRelativeZ(0.1f);
            // bump effect
            //if (wheels_angle > 36.0f && wheels_angle < 46.0f)
            //  wheel.TranslateBy( Vec2f(0.0f, -1.0f ) );
        }
    }
}

void Vehicle_DontRotateInWater( CBlob@ this )
{
	if (this.isInWater())
	{
		const f32 thresh = 10.0f;
		const f32 angle = this.getAngleDegrees();
		if (angle < thresh || angle > 360.0f-thresh)
		{
			this.setAngleDegrees( 0.0f );
			this.getShape().SetRotationsAllowed(false);
		}
		else
			this.getShape().SetRotationsAllowed(true);		
	}
	else
		this.getShape().SetRotationsAllowed(true);

}

bool Vehicle_doesCollideWithBlob_ground( CBlob@ this, CBlob@ blob )
{
	if (!blob.isCollidable() || blob.isAttached()) // no colliding against people inside vehicles
		return false;  
    // if going fast so hit little blobs (enemy people)
    if (blob.getRadius() > this.getRadius() || (blob.getTeamNum() != this.getTeamNum() && (this.getShape().vellen > 1.0f)) || (blob.getShape().isStatic())) {
        return true;
    }
    return false;
}

bool Vehicle_doesCollideWithBlob_boat( CBlob@ this, CBlob@ blob )
{
	if (!blob.isCollidable() || blob.isAttached()) // no colliding against people inside vehicles
		return false;
	return ((!blob.hasTag("vehicle") || this.getTeamNum() != blob.getTeamNum())); // don't collide with team boats (other vehicles will attach)
}

// hmm - better make hooks to these?

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    // special-case stone material  - put in inventory
    if (getNet().isServer() && attached.getName() == this.get_string("ammo name") )
    {
        attached.server_DetachFromAll();
        this.server_PutInInventory( attached );
        server_LoadAmmo( this, attached, this.get_u8("fire amount") );
    }

    // move mag offset

    if ( attachedPoint.name == "MAG" )
    {
        attachedPoint.offset = this.get_Vec2f("mag offset");
        attachedPoint.offset.y += attached.getHeight()/2.0f;
        attachedPoint.offsetZ = -60.0f;
    }
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
    if ( attachedPoint.name == "MAG" )
    {
        attachedPoint.offset = this.get_Vec2f("mag offset");
    }

    // jump out - needs to be synced so do here

    if ( detached.hasTag("player") && attachedPoint.socket ) {
		detached.setVelocity( this.get_Vec2f( "out vel") );
		detached.setPosition( detached.getPosition() + Vec2f(0.0f, -4.0f));
    }
}

//void onAddToInventory( CBlob@ this, CBlob@ blob )
//{
//	if (getNet().isServer() && blob.getName() == this.get_string("ammo name") )
//	{
//		RecountAmmo( this );
//	}
//}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
    return (this.get_bool( "inventoryAccess"));
}

bool isFlipped( CBlob@ this )
{
	f32 angle = this.getAngleDegrees();		 
	return (angle > 80 && angle < 290);
}
