#include "VehicleCommon.as"

// Mounted Bow logic

const Vec2f arm_offset = Vec2f(-2, -4);

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              50.0f, // move speed
	              0.40f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupWeapon(this, v,
	                    40, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, 2.0f), // fire position offset
	                    "mat_tankshell", // bullet ammo config name
	                    "tankshell", // bullet config name
	                    "KegExplosion", // fire sound
	                    "EmptyFire" // empty fire sound
	                   );
	v.charge = 100;
		
	this.set_f32("hit dmg modifier", 2.0f);
	this.set_f32("map dmg modifier", 6.0f);
	
	this.set_u32("lastHornTime", 0.0f);
	
	this.getShape().SetOffset(Vec2f(0, 8));
	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "SteamTank_Cannon.png", 32, 8);

	sprite.SetZ(10.0f);

	Vehicle_SetupGroundSound(this, v, "machinery_out_lp_03", 0.8f, 1.0f);
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-12.0f, 12.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-1.0f, 12.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(10.0f, 12.0f));
	
	AttachmentPoint@ driverpoint = this.getAttachments().getAttachmentPointByName("DRIVER");
	if (driverpoint !is null)
	{
		driverpoint.SetKeysToTake(key_action1);
	}
	
	if (arm !is null)
	{
		Animation@ anim = arm.addAnimation("default", 0, false);
		anim.AddFrame(4);
		anim.AddFrame(5);
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(1.0f);
	}

	this.getShape().SetRotationsAllowed(true);
	this.set_string("autograb blob", "mat_tankshell");

	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_tankshell");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}
}

f32 getAimAngle(CBlob@ this, VehicleInfo@ v)
{
	f32 angle = Vehicle_getWeaponAngle(this, v);
	bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
	bool failed = true;

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if (this.isAttached())
		{
			if (facing_left) { aim_vec.x = -aim_vec.x; }
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			        (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				angle = Maths::Max(-60.0f , Maths::Min(angle , 5.0f));
			}
		}
	}

	return angle;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.getPlayer() !is null && (attachedPoint.name == "DRIVER" || attachedPoint.name == "GUNNER"))
	{
		print("ATTACH: before " + attached.hasTag("invincible"));
		attached.Tag("invincible");
		print("ATTACH: after " + attached.hasTag("invincible"));
	}

	// print("" + attachedPoint.name);
	// print("attached");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	print("DETACH: before " + detached.hasTag("invincible"));
	detached.Untag("invincible");
	print("DETACH: after " + detached.hasTag("invincible"));
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("DRIVER");
		// CBlob@ driver = point.getOccupied();
		

		// if (driver !is null)
		// {
			// if (point.isKeyPressed(key_action1) && this.get_u32("lastHornTime") < getGameTime())
			// {
				// this.getSprite().PlaySound("ship_horn_02");
				// this.set_u32("lastHornTime", getGameTime() + 100);
			// }
		// }

		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}

		//set the arm angle based on GUNNER mouse aim, see above ^^^^
		f32 angle = getAimAngle(this, v);
		Vehicle_SetWeaponAngle(this, angle, v);
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");

		if (arm !is null)
		{
			bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left ? -1 : 1);

			if (v.loaded_ammo > 0)
			{
				arm.animation.frame = 1;
			}
			else
			{
				arm.animation.frame = 0;
			}

			arm.ResetTransform();
			arm.SetRelativeZ(-1.0f);
			arm.SetOffset(arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		}

		Vehicle_StandardControls(this, v);
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused)
{
	if (bullet !is null)
	{
		u16 charge = v.charge;
		f32 angle = this.getAngleDegrees() + Vehicle_getWeaponAngle(this, v);
		angle = angle * (this.isFacingLeft() ? -1 : 1);
		angle += ((XORRandom(256) - 128) / 64.0f);

		Vec2f vel = Vec2f(20.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		bullet.setVelocity(vel);
		Vec2f offset = arm_offset;
		offset.RotateBy(angle);
		bullet.setPosition(this.getPosition() + offset);
		
		bullet.server_SetTimeToDie(-1);
		bullet.server_SetTimeToDie(20.0f);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire blob"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}

		Vehicle_onFire(this, v, blob, charge);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
}