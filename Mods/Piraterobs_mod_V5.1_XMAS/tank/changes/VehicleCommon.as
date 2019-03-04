#include "SeatsCommon.as"
#include "VehicleAttachmentCommon.as"
#include "MakeDustParticle.as";

// HOOKS THAT YOU MUST IMPLEMENT WHEN INCLUDING THIS FILE
// void Vehicle_onFire( CBlob@ this, CBlob@ bullet, const u8 charge )
//      bullet will be null on client! always check for null
// bool Vehicle_canFire( CBlob@ this, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )


class VehicleInfo
{
	s32 fire_time;
	bool firing;
	u8 loaded_ammo;
	string fire_sound;
	string empty_sound;
	string bullet_sound;
	bool blob_ammo;
	string ammo_name;
	string bullet_name;
	u16 fire_delay;
	u8 fire_amount;
	u8 fire_cost_per_amount;
	Vec2f fire_pos;
	f32 move_speed;
	f32 turn_speed;
	Vec2f out_vel;
	bool inventoryAccess;
	u16 ammo_stocked;
	Vec2f mag_offset;
	u8 fire_style;
	f32 wep_angle;
	f32 fly_speed;
	f32 fly_amount;
	s8 move_direction;
	string ground_sound;
	f32 ground_volume;
	f32 ground_pitch;
	string water_sound;
	f32 water_volume;
	f32 water_pitch;
	bool infinite_ammo;
	u8 wheels_angle;
	u32 pack_secs;
	u32 pack_time;
	u16 charge;
	u16 last_charge;
	u16 max_charge_time;
	u16 cooldown_time;
	int8 power;
};


namespace Vehicle_Fire_Style
{
	enum Style
	{
		normal = 0, //fires as soon as the charge is done
		custom, //fires if the charge is done, but also calls Vehicle_preFire
	};
};

void Vehicle_Setup(CBlob@ this,
                   f32 moveSpeed, f32 turnSpeed, Vec2f jumpOutVelocity, bool inventoryAccess
                  )
{
	VehicleInfo v;

	v.fire_time = 0;
	v.firing = false;
	v.loaded_ammo = 0;
	v.fire_sound = 0;
	v.blob_ammo = false;
	v.ammo_name = "";
	v.fire_delay = 0;
	v.fire_amount = 0;
	v.fire_pos = Vec2f_zero;
	v.move_speed = moveSpeed;
	v.turn_speed = turnSpeed;
	v.out_vel = jumpOutVelocity;
	v.inventoryAccess = inventoryAccess;
	v.ammo_stocked = 0;
	v.mag_offset = Vec2f_zero;
	v.infinite_ammo = false;
	v.charge = 0;
	v.last_charge = 0;
	v.max_charge_time = 100;
	v.cooldown_time = 0;
	v.fire_cost_per_amount = 1;
	v.power = 0;
											
	this.addCommandID("fire");
	this.addCommandID("fire blob");
	this.addCommandID("flip_over");
	this.addCommandID("getin_mag");
	this.addCommandID("load_ammo");
	this.addCommandID("putin_mag");
	this.addCommandID("vehicle getout");
	this.addCommandID("reload");
	this.addCommandID("recount ammo");
	this.Tag("vehicle");
	this.getShape().getConsts().collideWhenAttached = false;
	AttachmentPoint@ mag = getMagAttachmentPoint(this);
	if (mag !is null)
	{
		v.mag_offset = mag.offset;
	}
	this.set("VehicleInfo", @v);
}

void Vehicle_SetupWeapon(CBlob@ this, VehicleInfo@ v, int fireDelay, int fireAmount, Vec2f firePosition, const string& in ammoConfigName, const string& in bulletConfigName,
                         const string& in fireSound, const string& in emptySound, Vehicle_Fire_Style::Style fireStyle = Vehicle_Fire_Style::normal)
{
	v.fire_time = 0;
	v.loaded_ammo = 0;
	v.fire_sound = fireSound;
	v.empty_sound = emptySound;
	v.bullet_name = bulletConfigName;
	v.blob_ammo = hasMag(this);
	v.ammo_name = ammoConfigName;
	v.fire_delay = fireDelay;
	v.fire_amount = fireAmount;
	v.fire_style = fireStyle;
	v.wep_angle = 0.0f;

	if (getRules().exists("singleplayer"))
	{
		v.infinite_ammo = true;
	}
}

void Vehicle_SetupAirship(CBlob@ this, VehicleInfo@ v,
                          f32 flySpeed)
{
	v.fly_speed = flySpeed;
	v.fly_amount = 0.25f;
	v.move_direction = 0;
	this.Tag("airship");
}

void Vehicle_SetupGroundSound(CBlob@ this, VehicleInfo@ v, const string& in movementSound, f32 movementVolumeMod, f32 movementPitchMod)
{
	v.ground_sound = movementSound;
	v.ground_volume = movementVolumeMod;
	v.ground_pitch = movementPitchMod;
	this.getSprite().SetEmitSoundPaused(true);
}

void Vehicle_SetupWaterSound(CBlob@ this, VehicleInfo@ v, const string& in movementSound, f32 movementVolumeMod, f32 movementPitchMod)
{
	v.water_sound = movementSound;
	v.water_volume = movementVolumeMod;
	v.water_pitch = movementPitchMod;
	this.getSprite().SetEmitSoundPaused(true);
}

int server_LoadAmmo(CBlob@ this, CBlob@ ammo, int take, VehicleInfo@ v)
{
	if (ammo is null)
	{
		v.loaded_ammo = take;
		CBitStream params;
		params.write_u8(take);
		this.SendCommand(this.getCommandID("reload"), params);
		return take;
	}

	u8 loadedAmmo = v.loaded_ammo;
	int amount = ammo.getQuantity();

	const bool infinite = v.infinite_ammo;

	if (amount >= take)
	{
		loadedAmmo += take;
		ammo.server_SetQuantity(amount - take);
	}
	else if (amount > 0)  // take rest
	{
		loadedAmmo += amount;
		ammo.server_SetQuantity(0);
	}

	if (loadedAmmo > 0)
	{
		SetOccupied(this.getAttachments().getAttachmentPointByName("MAG"), 1);
	}

	v.loaded_ammo = loadedAmmo;
	CBitStream params;
	params.write_u8(loadedAmmo);
	this.SendCommand(this.getCommandID("reload"), params);

	// no ammo left - remove from inv and die
	const u16 ammoQuantity = ammo.getQuantity();
	if (ammoQuantity == 0)
	{
		this.server_PutOutInventory(ammo);
		ammo.server_Die();
	}

	// ammo count for GUI
	RecountAmmo(this, v);

	return loadedAmmo;
}

void RecountAmmo(CBlob@ this, VehicleInfo@ v)
{
	int ammoStocked = v.loaded_ammo;
	const string ammoName = v.ammo_name;
	for (int i = 0; i < this.getInventory().getItemsCount(); i++)
	{
		CBlob@ invItem = this.getInventory().getItem(i);
		if (invItem.getName() == ammoName)
		{
			ammoStocked += invItem.getQuantity();
		}
	}

	v.ammo_stocked = ammoStocked;

	CBitStream params;
	params.write_u16(v.ammo_stocked);
	this.SendCommand(this.getCommandID("recount ammo"), params);
}

AttachmentPoint@ getMagAttachmentPoint(CBlob@ this)
{
	return this.getAttachments().getAttachmentPointByName("MAG");
}

CBlob@ getMagBlob(CBlob@ this)
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

bool canFireIgnoreFiring(CBlob@ this, VehicleInfo@ v)
{
	return (getGameTime() > v.fire_time);
}

bool canFire(CBlob@ this, VehicleInfo@ v)
{
	return (v.firing && canFireIgnoreFiring(this, v));
}

void Vehicle_SetWeaponAngle(CBlob@ this, f32 angleDegrees, VehicleInfo@ v)
{
	v.wep_angle = angleDegrees;
}

f32 Vehicle_getWeaponAngle(CBlob@ this, VehicleInfo@ v)
{
	return v.wep_angle;
}

void Vehicle_LoadAmmoIfEmpty(CBlob@ this, VehicleInfo@ v)
{
	if (getNet().isServer() && (this.getInventory().getItemsCount() > 0 || v.infinite_ammo) &&
	        getMagBlob(this) is null &&
	        v.loaded_ammo == 0)
	{
		CBlob@ toLoad = this.getInventory().getItem(0);
		if (toLoad !is null)
		{
			if (toLoad.getName() == v.ammo_name)
			{
				server_LoadAmmo(this, toLoad, v.fire_amount * v.fire_cost_per_amount, v);
			}
			else if (v.blob_ammo && this.server_PutOutInventory(toLoad))
			{
				this.server_AttachTo(toLoad, "MAG");
			}
		}
		else
		{
			server_LoadAmmo(this, null, v.fire_amount * v.fire_cost_per_amount, v);
		}
	}
}

void SetFireDelay(CBlob@ this, int shot_delay, VehicleInfo@ v)
{
	v.firing = false;
	v.fire_time = (getGameTime() + shot_delay);
}

bool Vehicle_AddFlipButton(CBlob@ this, CBlob@ caller)
{
	if (isFlipped(this))
	{
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0, -4), this, this.getCommandID("flip_over"), "Flip back");

		if (button !is null)
		{
			button.deleteAfterClick = false;
			return true;
		}
	}

	return false;
}

bool MakeLoadAmmoButton(CBlob@ this, CBlob@ caller, Vec2f offset, VehicleInfo@ v)
{
	// find ammo in inventory
	CInventory@ inv = caller.getInventory();

	if (inv !is null)
	{
		string ammo = v.ammo_name;
		CBlob@ ammoBlob = inv.getItem(ammo);

		//check hands
		if (ammoBlob is null)
		{
			CBlob@ held = caller.getCarriedBlob();

			if (held !is null)
			{
				if (held.getName() == ammo)
				{
					@ammoBlob = held;
				}
			}
		}

		if (ammoBlob !is null)
		{
			CBitStream callerParams;
			callerParams.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$" + ammoBlob.getName() + "$", offset, this, this.getCommandID("load_ammo"), "Load " + ammoBlob.getInventoryName(), callerParams);
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

bool Vehicle_AddLoadAmmoButton(CBlob@ this, CBlob@ caller)
{
	// MAG
	if (!hasMag(this))
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return false;
		}
		return MakeLoadAmmoButton(this, caller, Vec2f_zero, v);
	}
	else
	{
		// put in what is carried
		CBlob@ carryObject = caller.getCarriedBlob();
		if (carryObject !is null && !carryObject.isSnapToGrid())  // not spikes or door
		{
			CBitStream callerParams;
			callerParams.write_u16(caller.getNetworkID());
			callerParams.write_u16(carryObject.getNetworkID());
			caller.CreateGenericButton("$" + carryObject.getName() + "$", getMagAttachmentPoint(this).offset, this, this.getCommandID("putin_mag"), "Load " + carryObject.getInventoryName(), callerParams);
			return true;
		}
		else  // nothing in hands - take automatic
		{
			VehicleInfo@ v;
			if (!this.get("VehicleInfo", @v))
			{
				return false;
			}
			return MakeLoadAmmoButton(this, caller, getMagAttachmentPoint(this).offset, v);
		}
	}
}

void Fire(CBlob@ this, VehicleInfo@ v, CBlob@ caller, const u8 charge)
{
	// normal fire
	if (canFireIgnoreFiring(this, v) && caller !is null)
	{
		CBlob @blobInMag = getMagBlob(this);
		CBlob @carryObject = caller.getCarriedBlob();
		AttachmentPoint@ mag = getMagAttachmentPoint(this);
		Vec2f bulletPos;

		if (mag !is null)
		{
			bulletPos = mag.getPosition();
		}
		else
		{
			bulletPos = v.fire_pos;
			if (!this.isFacingLeft())
			{
				bulletPos.x = -bulletPos.x;
			}
			bulletPos = caller.getPosition() + bulletPos;
		}

		bool shot = false;

		// fire whatever was in the mag/bowl first
		if (blobInMag !is null)
		{
			this.server_DetachFrom(blobInMag);

			if (!blobInMag.hasTag("player"))
				blobInMag.SetDamageOwnerPlayer(caller.getPlayer());

			server_FireBlob(this, blobInMag, charge);
			shot = true;
		}
		else
		{
			u8 loadedAmmo = v.loaded_ammo;
			if (loadedAmmo != 0) // shoot if ammo loaded
			{
				shot = true;

				const int team = caller.getTeamNum();
				const bool isServer = getNet().isServer();
				for (u8 i = 0; i < loadedAmmo; i += v.fire_cost_per_amount)
				{
					CBlob@ bullet = isServer ? server_CreateBlobNoInit(v.bullet_name) : null;
					if (bullet !is null)
					{
						bullet.setPosition(bulletPos);
						bullet.server_setTeamNum(team);
						bullet.SetDamageOwnerPlayer(caller.getPlayer());
						bullet.Init();
						bullet.SetDamageOwnerPlayer(caller.getPlayer());
					}

					server_FireBlob(this, bullet, charge);
				}

				v.loaded_ammo = 0;
				SetOccupied(mag, 0);
			}
		}

		// sound

		if (shot)
		{
			this.getSprite().PlayRandomSound(v.fire_sound);
		}
		else
		{
			// empty shot
			this.getSprite().PlayRandomSound(v.empty_sound);
			Vehicle_onFire(this, v, null, 0);
		}

		// finally set the delay
		SetFireDelay(this, v.fire_delay, v);
	}
}

void server_FireBlob(CBlob@ this, CBlob@ blob, const u8 charge)
{
	if (blob !is null)
	{
		CBitStream params;
		params.write_netid(blob.getNetworkID());
		params.write_u8(charge);
		this.SendCommand(this.getCommandID("fire blob"), params);
	}
}

void Vehicle_StandardControls(CBlob@ this, VehicleInfo@ v)
{
	v.move_direction = 0;
	AttachmentPoint@[] aps;
	if (!this.getAttachmentPoints(@aps))
	{
		return;
	}

	for (uint i = 0; i < aps.length; i++)
	{
		AttachmentPoint@ ap = aps[i];
		CBlob@ blob = ap.getOccupied();

		if (blob is null || !ap.socket)
		{
			continue;
		}
		
		// GET OUT
		if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
		{
			CBitStream params;
			params.write_u16(blob.getNetworkID());
			this.SendCommand(this.getCommandID("vehicle getout"), params);
			return;
		} // get out

		// DRIVER

		if (ap.name == "DRIVER" && !this.hasTag("immobile"))
		{
			const f32 angle = this.getAngleDegrees();
			// set facing
			const bool faceleft = this.isFacingLeft();
			blob.SetFacingLeft( faceleft );
			const bool left = ap.isKeyPressed( key_left );
			const bool right = ap.isKeyPressed( key_right );
			const bool down = ap.isKeyPressed( key_down );
			const bool jump = ap.isKeyPressed( key_action3 );
			const bool onground = this.isOnGround();
			const bool onwall = this.isOnWall();
			const bool flipped = isFlipped(this);
			
			// left / right
			f32 moveForce = v.move_speed;
			f32 turnSpeed = v.turn_speed;
			Vec2f vel = this.getVelocity();
			Vec2f pos = this.getPosition();
			Vec2f force;
			Vec2f center(0, 10);

			if(this.exists("mass center")){
				center = this.get_Vec2f("mass center");
			}
			center += pos;

			if(left && v.power > -50 || !right && v.power > 0){
				v.power = v.power > 0 ? 0 : v.power-1;
			} 
			if(right && v.power < 50 || !left && v.power < 0){
				v.power = v.power < 0 ? 0 : v.power+1;
			}

			// gearbox
			moveForce /= 2*vel.Length()+0.2; //speed limit
			moveForce *= v.power/5;
			moveForce *= 0.1 + Maths::Cos(this.getGroundNormal().AngleWith(Vec2f(0, -1)) * 3.1415f / 180); //traction

			if (left && !flipped && (onground || onwall)) {
				force.x += moveForce;

				if (vel.x < -turnSpeed) {
					this.SetFacingLeft( true );
				}
			}

			if (right && !flipped && (onground || onwall)) {
				force.x += moveForce;

				if (vel.x > turnSpeed) {
					this.SetFacingLeft( false );
				}
			}

			force.RotateBy(this.getShape().getAngleDegrees());
			this.AddForce(force);
			//this.AddForceAtPosition(force, center + Vec2f(0, 6));

			//brakes
			if((onground || onwall) && ((left && vel.x > 0.0) || (right && vel.x < -0.0))){
				if(getNet().isClient() && Maths::Abs(vel.x) > 1 && (getGameTime() % 5) == 0){
					MakeDustParticle(center + Vec2f(0, 6), "dust2");
					this.getSprite().PlayRandomSound( "/Scrape1" );
				}
				this.getShape().setFriction(0.8);
			} else {
				this.getShape().setFriction(0.03);
			}

			// wheelie
			if (onground && (down || flipped && (left || right))
				&& ((!faceleft && !(angle < 330 && angle > 270))    // FRAGILE. KEEP AWAY FROM DIRECT SUNLIGHT
					|| (faceleft && !(angle > 30 && angle < 90))) )
			{
				f32 torque = 100.0f;
				int8 sign;
				if (down)
					sign = faceleft ^^ flipped ? 1 : -1;
				else
					sign = left ^^ flipped ? 1 : -1;

				this.AddTorque(sign * torque);
				this.AddForceAtPosition(Vec2f(0.0f,-100.0f), 
					center + Vec2f(-this.getShape().getWidth()/2, 0) * sign);
				//print("AddTorque");
			}
			
			if(onground && jump)
			{
				this.AddForce(Vec2f(0.0f,-1000.0f));
			}

		}  // driver

		// GUNNER

		if (blob.isMyPlayer() && ap.name == "GUNNER")
		{
			// set facing
			blob.SetFacingLeft(this.isFacingLeft());

			const u8 style = v.fire_style;
			switch (style)
			{
			case Vehicle_Fire_Style::normal:
				//normal firing
				v.firing = false;
				if (ap.isKeyPressed(key_action1))
				{
					v.firing = true;
					if (canFire(this, v))
					{
						CBitStream fireParams;
						fireParams.write_u16(blob.getNetworkID());
						fireParams.write_u8(0);
						this.SendCommand(this.getCommandID("fire"), fireParams);
					}
				}
				break;

			case Vehicle_Fire_Style::custom:
				//custom firing requirements
			{
				u8 charge = 0;
				if (Vehicle_canFire(this, v, ap.isKeyPressed(key_action1), ap.wasKeyPressed(key_action1), charge) && canFire(this, v))
				{
					CBitStream fireParams;
					fireParams.write_u16(blob.getNetworkID());
					fireParams.write_u8(charge);
					this.SendCommand(this.getCommandID("fire"), fireParams);
				}
			}

				break;
			}

		} // gunner

		// FLYER

		if (ap.name == "FLYER")
		{
			f32 moveForce = v.move_speed;

			f32 flyAmount = v.fly_amount;

			f32 turnSpeed = v.turn_speed;
			s8 direction = v.move_direction;

			Vec2f force;
			bool moving = false;
			const bool up = ap.isKeyPressed(key_action1);
			const bool down = ap.isKeyPressed(key_action2) || ap.isKeyPressed(key_down);

			const Vec2f vel = this.getVelocity();

			bool backwards = false;

			// fly up/down
			if (up || down)
			{
				if (up)
				{
					direction -= 1;

					flyAmount += 0.3f / getTicksASecond();
					if (flyAmount > 1.0f)
						flyAmount = 1.0f;
				}
				else
				{
					direction += 1;

					flyAmount -= 0.3f / getTicksASecond();
					if (flyAmount < 0.5f)
						flyAmount = 0.5f;
				}
				v.fly_amount = flyAmount;
				v.move_direction = direction;
			}

			// fly left/right
			const bool left = ap.isKeyPressed(key_left);
			const bool right = ap.isKeyPressed(key_right);
			if (left)
			{
				force.x -= moveForce;

				if (vel.x < -turnSpeed)
				{
					this.SetFacingLeft(true);
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
					this.SetFacingLeft(false);
				}
				else
				{
					backwards = true;
				}

				moving = true;
			}


			if (moving)
			{
				// this.AddForceAtPosition( force, ap.getPosition());
				this.AddForce(force);
			}
		} // flyer


		// ROWER

		if ((ap.name == "ROWER" && this.isInWater()) || (ap.name == "SAIL" && !this.hasTag("no sail")))
		{
			const f32 moveForce = v.move_speed;
			const f32 turnSpeed = v.turn_speed;
			Vec2f force;
			bool moving = false;
			const bool left = ap.isKeyPressed(key_left);
			const bool right = ap.isKeyPressed(key_right);
			const Vec2f vel = this.getVelocity();

			bool backwards = false;

			// row left/right

			if (left)
			{
				force.x -= moveForce;

				if (vel.x < -turnSpeed)
				{
					this.SetFacingLeft(true);
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
					this.SetFacingLeft(false);
				}
				else
				{
					backwards = true;
				}

				moving = true;
			}

			if (moving)
			{
				this.AddForce(force);
			}
		} // rower
	}   // for
	

	if (this.hasTag("airship"))
	{
		f32 flyForce = v.fly_speed;
		f32 flyAmount = v.fly_amount;
		this.AddForce(Vec2f(0, flyForce * flyAmount));
	}

}

CSpriteLayer@ Vehicle_addWheel(CBlob@ this, VehicleInfo@ v, const string& in textureName, int frameWidth, int frameHeight, int frame, Vec2f offset)
{
	v.wheels_angle = 0;
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ wheel = sprite.addSpriteLayer("!w " + sprite.getSpriteLayerCount(), textureName, frameWidth, frameHeight);

	if (wheel !is null)
	{
		Animation@ anim = wheel.addAnimation("default", 0, false);
		anim.AddFrame(frame);
		wheel.SetOffset(offset);
		wheel.SetRelativeZ(0.1f);
	}

	return wheel;
}

CSpriteLayer@ Vehicle_addWoodenWheel(CBlob@ this, VehicleInfo@ v, int frame, Vec2f offset)
{
	return Vehicle_addWheel(this, v, "Entities/Vehicles/Common/WoodenWheels.png", 16, 16, frame, offset);
}

void UpdateWheels(CBlob@ this)
{
	if (this.hasTag("immobile"))
		return;

	//rotate wheels
	CSprite@ sprite = this.getSprite();
	uint sprites = sprite.getSpriteLayerCount();

	for (uint i = 0; i < sprites; i++)
	{
		CSpriteLayer@ wheel = sprite.getSpriteLayer(i);
		if (wheel.name.substr(0, 2) == "!w") // this is a wheel
		{
			bool small = wheel.getFrame() == 1;
			int sign = wheel.isFacingLeft() ? 1 : -1;
			f32 wheels_angle = (Maths::Round(wheel.getWorldTranslation().x * 10) % 360 ) / 1.0f;
			wheel.ResetTransform();
			wheel.RotateBy(wheels_angle + i * i * 16.0f, small ? Vec2f(0.5*sign, -0.5) : Vec2f_zero);
		}
	}
}

void Vehicle_DontRotateInWater(CBlob@ this)
{
//  if (getGameTime() % 5 > 0)
	//  return;

	if (getMap().isInWater(this.getPosition() + Vec2f(0.0f, this.getHeight() * 0.5f)))
	{
		const f32 thresh = 15.0f;
		const f32 angle = this.getAngleDegrees();
		if ((angle < thresh || angle > 360.0f - thresh) && !this.hasTag("sinking"))
		{
			this.setAngleDegrees(0.0f);
			this.getShape().SetRotationsAllowed(false);
			return;

		}
	}

	this.getShape().SetRotationsAllowed(true);
}

bool Vehicle_doesCollideWithBlob_ground(CBlob@ this, CBlob@ blob)
{
	if (!blob.isCollidable() || blob.isAttached()) // no colliding against people inside vehicles
		return false;
	if (blob.getRadius() > this.getRadius()
	 || (blob.getTeamNum() != this.getTeamNum() && (blob.hasTag("player") && this.getShape().vellen > 1.0f || blob.hasTag("vehicle")))
	 || (blob.getShape().isStatic())
	 || blob.hasTag("projectile")
	 || blob.getShape().getConsts().transports) {
		return true;
	}
	return false;
}

bool Vehicle_doesCollideWithBlob_boat(CBlob@ this, CBlob@ blob)
{
	if (!blob.isCollidable() || blob.isAttached()) // no colliding against people inside vehicles
		return false;
	// no colliding with shit underwater
	if (blob.hasTag("material") || (blob.isInWater() && (blob.getName() == "heart" || blob.getName() == "log" || blob.hasTag("dead"))))
		return false;

	return true;
	//return ((!blob.hasTag("vehicle") || this.getTeamNum() != blob.getTeamNum())); // don't collide with team boats (other vehicles will attach)
}

void Vehicle_onAttach(CBlob@ this, VehicleInfo@ v, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	// special-case stone material  - put in inventory
	if (getNet().isServer() && attached.getName() == v.ammo_name)
	{
		attached.server_DetachFromAll();
		this.server_PutInInventory(attached);
		server_LoadAmmo(this, attached, v.fire_amount, v);
	}

	// move mag offset

	if (attachedPoint.name == "MAG")
	{
		attachedPoint.offset = v.mag_offset;
		attachedPoint.offset.y += attached.getHeight() / 2.0f;
		attachedPoint.offsetZ = -60.0f;
	}
}

void Vehicle_onDetach(CBlob@ this, VehicleInfo@ v, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint.name == "MAG")
	{
		attachedPoint.offset = v.mag_offset;
	}

	// jump out - needs to be synced so do here

	if (detached.hasTag("player") && attachedPoint.socket)
	{

		// Fires on detach. Blame Fuzzle.
		if (attachedPoint.name == "GUNNER" && v.charge > 0)
		{
			CBitStream params;
			params.write_u16(detached.getNetworkID());
			params.write_u8(v.charge);
			this.SendCommand(this.getCommandID("fire"), params);
		}

		detached.setPosition(detached.getPosition() + Vec2f(0.0f, -4.0f));
		detached.setVelocity(v.out_vel);
		detached.IgnoreCollisionWhileOverlapped(null);
		this.IgnoreCollisionWhileOverlapped(null);
	}
}

bool isFlipped(CBlob@ this)
{
	f32 angle = this.getAngleDegrees();
	return (angle > 90 && angle < 270);
}
