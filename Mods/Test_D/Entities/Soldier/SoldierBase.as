#include "SoldierCommon.as"
#include "Blood.as"
#include "WaterParticles.as"
#include "ClassesCommon.as"
#include "HoverMessage.as"
#include "MapCommon.as"
#include "SoldierRevive.as"
#include "SoldierCrosshair.as"
#include "RadioCharacters.as"

namespace Soldier
{
	void DefaultInit(CBlob@ this)
	{
		if (getData(this) !is null)
			return;

		// data
		Data data;
		data.wallGrab = false;
		this.set("data", @data);

		// tags
		this.Tag("player");

		// dont rotate
		this.getShape().SetRotationsAllowed(false);

		//back bit
		AddTopShape(this);

		//this.getSprite().SetEmitSound("Sounds/RunningFoley.ogg");

		// class setup

		const u8 classType = this.get_u8("class");
		SetupClass(this, data, classType);

		this.set_u8("class pick", 5); // plate selector

		// chat bubble
		this.chatBubbleOffset.y = 12;//-46;
		this.SetChatBubbleFont("hud");
		this.maxChatBubbleLines = 1;

		// lobby		
		this.set_u32("bet", 0);
	}

	// COMMON TICK FUNCTIONALITY

	void InitData(CBlob@ this, Data@ data)
	{
		@data.blob = this;
		@data.map = this.getMap();
		@data.sprite = this.getSprite();
		@data.shape = this.getShape();
		data.pos = this.getPosition();
		data.vel = this.getVelocity();
		data.vellen = this.getShape().vellen;
		data.aimpos = this.getAimPos();
		data.inMenu = getRules().get_s16("in menu") > 0 || getRules().get_bool("in class menu");
		data.up = !data.inMenu && this.isKeyPressed(key_up);
		data.down = !data.inMenu && this.isKeyPressed(key_down);
		data.left = !data.inMenu && this.isKeyPressed(key_left);
		data.right = !data.inMenu && this.isKeyPressed(key_right);
		data.fire = !data.inMenu && this.isKeyPressed(key_action1);
		data.fire2 = !data.inMenu && this.isKeyPressed(key_action2);
		data.jump = !data.inMenu && this.isKeyPressed(key_jump);
		data.crouch = !data.inMenu && this.isKeyPressed(key_crouch);
		data.isMyPlayer = this.isMyPlayer();
		data.onGround = this.isOnGround();
		data.onWall = this.isOnWall();
		data.facingLeft = this.isFacingLeft();
		data.direction = data.facingLeft ? -1.0f : 1.0f;
		data.radius = this.getRadius();
		data.gametime = getGameTime();
		data.local = data.isMyPlayer || (getNet().isServer() && this.getBrain().isActive());

		CMap@ map = getMap();
		Vec2f tpos = data.pos + Vec2f(0, 2);
		Vec2f hpos = tpos + Vec2f(0, -8);
		data.oldInWater = data.inWater;
		data.inWater = map.isInWater(tpos) || map.isInWater(hpos);
		data.oldWaterSurface = data.waterSurface;
		data.waterSurface = data.inWater && !map.isInWater(hpos);

		data.onLadder = this.isOnLadder();

		data.attached = this.isAttached();
	}

	void SetupClass(CBlob@ this, Data@ data, const int type)
	{
		data.type = type;
		CSprite@ sprite = this.getSprite();
		CBrain@ brain = this.getBrain();

		RadioCharacter@ rc = getCharacterFor(this.getTeamNum(), type);
		data.pitch = rc.pitch;

		switch (type)
		{
			case ASSAULT:
				data.primaryName = "ammo";
				data.secondaryName = "nades";
				if (!getNet().isServer())
					break;

				sprite.RemoveScript("SniperAnims.as");
				sprite.RemoveScript("EngineerAnims.as");
				sprite.RemoveScript("CivilianAnims.as");
				sprite.RemoveScript("MedicAnims.as");
				sprite.RemoveScript("CommandoAnims.as");
				this.RemoveScript("SniperBase.as");
				this.RemoveScript("EngineerBase.as");
				this.RemoveScript("CivilianBase.as");
				this.RemoveScript("MedicBase.as");
				this.RemoveScript("CommandoBase.as");
				brain.RemoveScript("MedicSimpleBrain.as");
				brain.RemoveScript("EngineerSimpleBrain.as");
				brain.RemoveScript("SniperSimpleBrain.as");
				brain.RemoveScript("CommandoSimpleBrain.as");
				brain.RemoveScript("CivilianSimpleBrain.as");
				break;

			case SNIPER:
				data.primaryName = "ammo";
				if (!getNet().isServer())
					break;

				sprite.RemoveScript("AssaultAnims.as");
				sprite.RemoveScript("EngineerAnims.as");
				sprite.RemoveScript("CivilianAnims.as");
				sprite.RemoveScript("MedicAnims.as");
				sprite.RemoveScript("CommandoAnims.as");
				this.RemoveScript("AssaultBase.as");
				this.RemoveScript("EngineerBase.as");
				this.RemoveScript("CivilianBase.as");
				this.RemoveScript("MedicBase.as");
				this.RemoveScript("CommandoBase.as");
				this.RemoveScript("SoldierGrenade.as");
				brain.RemoveScript("MedicSimpleBrain.as");
				brain.RemoveScript("EngineerSimpleBrain.as");
				brain.RemoveScript("CommandoSimpleBrain.as");
				brain.RemoveScript("AssaultSimpleBrain.as");
				brain.RemoveScript("CivilianSimpleBrain.as");
				break;

			case ENGINEER:
				data.primaryName = "bombs";
				data.secondaryName = "missiles";
				if (!getNet().isServer())
					break;

				sprite.RemoveScript("AssaultAnims.as");
				sprite.RemoveScript("SniperAnims.as");
				sprite.RemoveScript("CivilianAnims.as");
				sprite.RemoveScript("MedicAnims.as");
				sprite.RemoveScript("CommandoAnims.as");
				this.RemoveScript("AssaultBase.as");
				this.RemoveScript("SniperBase.as");
				this.RemoveScript("SoldierGrenade.as");
				this.RemoveScript("CivilianBase.as");
				this.RemoveScript("MedicBase.as");
				this.RemoveScript("CommandoBase.as");
				brain.RemoveScript("MedicSimpleBrain.as");
				brain.RemoveScript("SniperSimpleBrain.as");
				brain.RemoveScript("CommandoSimpleBrain.as");
				brain.RemoveScript("AssaultSimpleBrain.as");
				brain.RemoveScript("CivilianSimpleBrain.as");
				break;

			case MEDIC:
				data.secondaryName = "medkits";
				if (!getNet().isServer())
					break;

				sprite.RemoveScript("SniperAnims.as");
				sprite.RemoveScript("EngineerAnims.as");
				sprite.RemoveScript("CivilianAnims.as");
				sprite.RemoveScript("AssaultAnims.as");
				sprite.RemoveScript("CommandoAnims.as");
				this.RemoveScript("SniperBase.as");
				this.RemoveScript("EngineerBase.as");
				this.RemoveScript("CivilianBase.as");
				this.RemoveScript("AssaultBase.as");
				this.RemoveScript("CommandoBase.as");
				this.RemoveScript("SoldierGrenade.as");
				brain.RemoveScript("SniperSimpleBrain.as");
				brain.RemoveScript("CommandoSimpleBrain.as");
				brain.RemoveScript("EngineerSimpleBrain.as");
				brain.RemoveScript("AssaultSimpleBrain.as");
				brain.RemoveScript("CivilianSimpleBrain.as");
				break;

			case COMMANDO:
				data.secondaryName = "flashbang";
				if (!getNet().isServer())
					break;

				sprite.RemoveScript("SniperAnims.as");
				sprite.RemoveScript("EngineerAnims.as");
				sprite.RemoveScript("CivilianAnims.as");
				sprite.RemoveScript("MedicAnims.as");
				sprite.RemoveScript("AssaultAnims.as");
				this.RemoveScript("SniperBase.as");
				this.RemoveScript("EngineerBase.as");
				this.RemoveScript("CivilianBase.as");
				this.RemoveScript("MedicBase.as");
				this.RemoveScript("AssaultBase.as");
				brain.RemoveScript("MedicSimpleBrain.as");
				brain.RemoveScript("EngineerSimpleBrain.as");
				brain.RemoveScript("SniperSimpleBrain.as");
				brain.RemoveScript("AssaultSimpleBrain.as");
				brain.RemoveScript("CivilianSimpleBrain.as");
				break;

			case CIVILIAN:
			default:
				if (!getNet().isServer())
					break;

				sprite.RemoveScript("AssaultAnims.as");
				sprite.RemoveScript("SniperAnims.as");
				sprite.RemoveScript("EngineerAnims.as");
				sprite.RemoveScript("MedicAnims.as");
				sprite.RemoveScript("CommandoAnims.as");
				this.RemoveScript("AssaultBase.as");
				this.RemoveScript("SniperBase.as");
				this.RemoveScript("SoldierGrenade.as");
				this.RemoveScript("EngineerBase.as");
				this.RemoveScript("MedicBase.as");
				this.RemoveScript("CommandoBase.as");
				brain.RemoveScript("MedicSimpleBrain.as");
				brain.RemoveScript("EngineerSimpleBrain.as");
				brain.RemoveScript("SniperSimpleBrain.as");
				brain.RemoveScript("CommandoSimpleBrain.as");
				brain.RemoveScript("AssaultSimpleBrain.as");
				break;
		}
	}

	void DefaultTick(CBlob@ this)
	{
		Data@ data = getData(this);
		CRules@ rules = getRules();

		InitData(this, data);

		// airtime counter

		if (inAir(data) || this.isAttached())
		{
			data.airTime++;
		}
		else
		{
			data.airTime = 0;
		}

		// stun

		if (data.stunTime > 0)
		{
			if (data.onGround)
				data.stunTime -= 3;
			else
				data.stunTime--;

			data.stunned = (data.stunTime > 0);

			EndCrosshair(this, data);
			data.lockCrouch = 0;

			if (!data.stunned) //simplify checks
			{
				data.stunTime = 0;
			}
		}
		else
		{
			data.stunned = false;
		}

		// scream in air
		if (data.dead || data.stunned) //MM: find a better way of doing this on rockets, attached makes them scream on trucks
		{
			if (data.airTime == 14 && data.vel.y < -2.0f)
			{
				data.sprite.PlayRandomSound("ManScream", 1.0f, data.pitch);
			}
		}

		// recover from death

		if (data.dead)
		{
			if (getNet().isServer())
			{
				const bool player = this.getPlayer() !is null;
				if ((rules.get_bool("respawning") || !player) && data.gametime - data.deadTime > recoverTicks)
				{
					this.server_Die(); // mooks just die
					return;
				}
			}

			if (data.deadScreamTime + Soldier::deadScreamInterval < data.gametime &&
			        (this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action1)))
			{
				data.deadScreamTime = data.gametime;
				data.sprite.PlayRandomSound("ManAgony", 1.0f, data.pitch);
				data.sprite.SetAnimation("agony");
				//if (!this.isBot())
				//	AddMessage(this, "Help!");
			}

			if (sv_test && this.isKeyJustPressed(key_action3))
			{
				Revive(this);
			}
		}

		//overlap interactions (was in movement for some reason before?)
		if (data.dead || data.healTime > 0)
		{
			CBlob@[] blobs;
			if (this.getOverlapping(@blobs))
			{
				for (u32 i = 0; i < blobs.length; i++)
				{
					CBlob@ blob = blobs[i];

					//live enemy!
					if (blob.getTeamNum() != this.getTeamNum() &&
					        blob.getHealth() > 0.0f &&
					        blob.hasTag("player"))
					{
						if (data.dead)
						{
							Vec2f slapspeed(4.5f, 3.5f);
							data.vel.x = blob.isFacingLeft() ? -slapspeed.x : slapspeed.x;
							data.vel.y = -slapspeed.y;
							data.stunTime = 45;
							blob.getSprite().PlaySound("Slap");
						}

						if (data.healTime > 0)
						{
							data.healTime = 0; //TODO MM - sync this please :)
						}

						break;
					}
				}
			}
		}

		// cheer scream

		if (!data.dead && data.deadScreamTime + Soldier::deadScreamInterval < data.gametime &&
		        (this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action1)))
		{
			if (rules.isGameOver())
			{
				data.deadScreamTime = data.gametime;
				data.sprite.PlayRandomSound("MumbleCheer", 1.0f, data.pitch);
				//AddMessage(this, "Hurray!");
			}
			else if (rules.isIntermission() || rules.isWarmup())
			{
				data.deadScreamTime = data.gametime;
				//data.sprite.PlayRandomSound("MumbleReady", 1.0f, data.pitch);
				//AddMessage(this, "Go!");
			}
		}

		//update aim position

		if (this.isMyPlayer() || this.isBot())
		{
			Vec2f newtarget = this.getPosition();
			if (data.crosshair)
			{
				newtarget += data.crosshairOffset;
				if (this.isMyPlayer())
				{
					Soldier::SyncCrosshair(this, data);
				}
			}
			else
			{
				const bool runleft = data.left && !data.right && !data.onWall;
				const bool runright = data.right && !data.left && !data.onWall;
				const bool run = runleft || runright;

				const f32 moveAmountX = run ? 130.0f : 70.0f;
				const f32 moveAmountY = run ? 70.0f : 30.0f;
				f32 vertical = 0.0f;
				if (data.up)
				{
					vertical = -1.0f;
				}
				else if (data.down)
				{
					vertical = 1.0f;
				}

				newtarget += Vec2f((data.facingLeft ? -1.0f : 1.0f) * moveAmountX, vertical * moveAmountY);
			}

			f32 follow_fac = 0.1f;
			data.cameraTarget = (data.cameraTarget * (1.0f - follow_fac)) + (newtarget * follow_fac);
		}

		// water particles
		if (data.inWater != data.oldInWater ||
		        (data.waterSurface && XORRandom(4) == 0))
		{
			if (data.vellen > 1.0f)
			{
				this.getSprite().PlayRandomSound("SplashSmall.ogg");
				Particles::WaterSplash(data.pos, 1, data.vel);
			}
		}
		else if (data.inWater && !data.waterSurface) //under water
		{
			if (XORRandom(50) == 0 || data.gametime % 30 == 0) //bubbles
			{
				//TODO: sound effect
				//TODO: bubble "pop" when out of water
				Particles::BubbleSmall(data.pos, 1 + XORRandom(3), data.vel);
			}
		}

		// bleed particles

		if (this.getHealth() < this.getInitialHealth() && XORRandom(4) == 0)
		{
			if (data.inWater)
			{
				Particles::WaterBlood(data.pos, 1, 1.0f);
			}
			else
			{
				Particles::Blood(data.pos, 1, 1.0f);
			}
		}

		// unlock

		if (this.isKeyJustPressed(key_action1) || this.isKeyJustPressed(key_action2))
		{
			data.lockCrouch = 0;
		}

		// healing


		if (data.healTime > 0)
		{
			data.healTime++;
			if (data.healTime > Soldier::medicHealDelay)
			{
				if (getNet().isServer())
				{
					Revive(this);
				}
			}
		}

		// facing

		if (!data.crosshair
		        && (!data.fire || data.type != Soldier::MEDIC)) // strafe
		{
			if (data.left && !data.right)
			{
				this.SetFacingLeft(true);
			}
			else if (data.right && !data.left)
			{
				this.SetFacingLeft(false);
			}
		}

		data.idleTime++;
		if (data.left || data.right || data.up || data.fire || data.down || data.jump || data.crouch)
		{
			data.idleTime = 0;
		}
	}

	// COLLISION

	bool DefaultCollision(CBlob@ this, CBlob@ blob)
	{
		const bool isSoldier = blob.getName() == "soldier";
		Soldier::Data@ data = Soldier::getData(this);

		if (isSoldier)
		{
			Soldier::Data@ data2 = Soldier::getData(blob);
			if (data2.shield && !data2.dead && blob.getHealth() > 0.0f && blob.getTeamNum() != this.getTeamNum())
			{
				return true;
			}
		}
		else if (data.shield && !data.dead && blob.getHealth() > 0.0f)
		{
			return true;
		}

		return !isSoldier;

		//return isSoldier && !data.dead && blob.getHealth() > 0.0f;
	}

// SYNC:
	void Bite(CBlob@ this, Data@ data)
	{
		Vec2f pos = data.pos;
		Vec2f vel(data.facingLeft ? -1.0f : 1.0f, 0.0f);

		HitInfo@[] hitInfos;
		if (getMap().getHitInfosFromRay(pos, -vel.Angle(), vel.Length(), this, @hitInfos))
		{
			//HitInfo objects are sorted, first come closest hits
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ b = hi.blob;
				if (b is this) continue;
				if (b !is null)
				{
					if (b.getTeamNum() == this.getTeamNum()) continue;

					this.server_Hit(b, hi.hitpos,
					                vel, 0.333f,
					                0, true);
					break; //one at a time
				}
			}
		}
	}
}

void onInit(CBlob@ this)
{
	Soldier::DefaultInit(this);
}

void onTick(CBlob@ this)
{
	Soldier::DefaultTick(this);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Soldier::DefaultCollision(this, blob);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null)
	{
		Soldier::Data@ data = Soldier::getData(this);
		if (data.dead || data.stunned)
		{
			f32 vellen = data.vel.getLength();
			if (data.vel * normal < 0.0f && vellen > 4.0f)
			{
				data.sprite.PlayRandomSound("ManArg", 1.0f, data.pitch);

				//bounce, reflect, 50% restitution (some friction and not perfect bounce)
				data.vel = (data.vel + normal * -2 * (data.vel * normal)) * 0.5f;
				this.setVelocity(data.vel);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (cmd == Soldier::Commands::CROSSHAIR)
	{
		Vec2f offset = params.read_Vec2f();
		if (!this.isMyPlayer())
		{
			data.crosshairOffset = offset;
		}
	}
	else if (cmd == Soldier::Commands::REVIVE)
	{
		if (getNet().isClient() && !getNet().isServer())
		{
			Revive(this);
		}
	}
}

// SYNC


void onSendCreateData(CBlob@ this, CBitStream@ stream)
{
	Soldier::Data@ data = Soldier::getData(this);

	stream.write_s32(data.jumpCounter);
	stream.write_s32(data.airTime);
	stream.write_bool(data.ledgeClimb);
	stream.write_bool(data.oldLedgeClimb);
	stream.write_bool(data.canLedgeClimb);
	stream.write_u32(data.fireTime);
	stream.write_s32(data.idleTime);
	stream.write_u32(data.shotTime);
	stream.write_f32(data.grenadeStep);
	stream.write_s32(data.grenades);
	stream.write_Vec2f(data.crosshairOffset);
	stream.write_bool(data.crosshair);
	stream.write_s32(data.crosshairTime);
	stream.write_bool(data.crouching);
	stream.write_bool(data.oldCrouching);
	stream.write_s32(data.lockCrouch);
	stream.write_bool(data.sliding);
	stream.write_bool(data.oldSliding);
	stream.write_bool(data.dead);
	stream.write_s32(data.deadTime);
	stream.write_s32(data.ammo);
	stream.write_bool(data.stunned);
	stream.write_s8(data.stunTime);
	stream.write_f32(data.walkSpeedModifier);
	stream.write_f32(data.jumpSpeedModifier);
	stream.write_s32(data.deadScreamTime);
	stream.write_s32(data.biteTime);
	stream.write_bool(data.inWater);
	stream.write_bool(data.oldInWater);
	stream.write_bool(data.waterSurface);
	stream.write_bool(data.oldWaterSurface);
	stream.write_s32(data.camoMode);
	stream.write_bool(data.shield);
	stream.write_bool(data.wallGrab);
	stream.write_bool(data.oldWallGrab);
	stream.write_u8(data.engineerState);
	stream.write_u16(data.missileId);
	stream.write_u8(data.bombs);
}

bool onReceiveCreateData(CBlob@ this, CBitStream@ stream)
{
	Soldier::Data@ data = Soldier::getData(this);
	if (data is null)
	{
		warn("No data for soldier in onReceiveCreateData");
		return false;
	}

	if (!stream.saferead_s32(data.jumpCounter)) return false;
	if (!stream.saferead_s32(data.airTime)) return false;
	if (!stream.saferead_bool(data.ledgeClimb)) return false;
	if (!stream.saferead_bool(data.oldLedgeClimb)) return false;
	if (!stream.saferead_bool(data.canLedgeClimb)) return false;
	if (!stream.saferead_u32(data.fireTime)) return false;
	if (!stream.saferead_s32(data.idleTime)) return false;
	if (!stream.saferead_u32(data.shotTime)) return false;
	if (!stream.saferead_f32(data.grenadeStep)) return false;
	if (!stream.saferead_s32(data.grenades)) return false;
	if (!stream.saferead_Vec2f(data.crosshairOffset)) return false;
	if (!stream.saferead_bool(data.crosshair)) return false;
	if (!stream.saferead_s32(data.crosshairTime)) return false;
	if (!stream.saferead_bool(data.crouching)) return false;
	if (!stream.saferead_bool(data.oldCrouching)) return false;
	if (!stream.saferead_s32(data.lockCrouch)) return false;
	if (!stream.saferead_bool(data.sliding)) return false;
	if (!stream.saferead_bool(data.oldSliding)) return false;
	if (!stream.saferead_bool(data.dead)) return false;
	if (!stream.saferead_s32(data.deadTime)) return false;
	if (!stream.saferead_s32(data.ammo)) return false;
	if (!stream.saferead_bool(data.stunned)) return false;
	if (!stream.saferead_s8(data.stunTime)) return false;
	if (!stream.saferead_f32(data.walkSpeedModifier)) return false;
	if (!stream.saferead_f32(data.jumpSpeedModifier)) return false;
	if (!stream.saferead_s32(data.deadScreamTime)) return false;
	if (!stream.saferead_s32(data.biteTime)) return false;
	if (!stream.saferead_bool(data.inWater)) return false;
	if (!stream.saferead_bool(data.oldInWater)) return false;
	if (!stream.saferead_bool(data.waterSurface)) return false;
	if (!stream.saferead_bool(data.oldWaterSurface)) return false;
	if (!stream.saferead_s32(data.camoMode)) return false;
	if (!stream.saferead_bool(data.shield)) return false;
	if (!stream.saferead_bool(data.wallGrab)) return false;
	if (!stream.saferead_bool(data.oldWallGrab)) return false;
	if (!stream.saferead_s8(data.engineerState)) return false;
	if (!stream.saferead_u16(data.missileId)) return false;
	if (!stream.saferead_u8(data.bombs)) return false;

	return true;
}

