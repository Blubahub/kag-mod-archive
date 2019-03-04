// SSKArcher logic

#include "SSKArcherCommon.as"
#include "ThrowCommon.as"
#include "Hitters.as"
#include "SSKRunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "SSKStatusCommon.as"

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_arrows = 1;
const int STAB_DELAY = 10;
const int STAB_TIME = 22;

void onInit(CBlob@ this)
{
	SSKArcherInfo ssk_archer;
	this.set("ssk_archerInfo", @ssk_archer);

	this.set_s8("charge_time", 0);
	this.set_u8("charge_state", SSKArcherParams::not_aiming);
	this.set_bool("has_arrow", false);
	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	this.push("names to activate", "keg");
	this.push("names to activate", "bomb");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound("BowPull.ogg");
	this.addCommandID("shoot arrow");
	this.addCommandID("pickup arrow");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID(grapple_sync_cmd);

	SetHelp(this, "help self hide", "ssk_archer", "Hide    $KEY_S$", "", 1);
	SetHelp(this, "help self action2", "ssk_archer", "$Grapple$ Grappling hook    $RMB$", "", 3);

	//add a command ID for each arrow type
	for (uint i = 0; i < arrowTypeNames.length; i++)
	{
		this.addCommandID("pick " + arrowTypeNames[i]);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}

void ManageGrapple(CBlob@ this, SSKArcherInfo@ ssk_archer)
{
	CSprite@ sprite = this.getSprite();
	u8 charge_state = ssk_archer.charge_state;
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);
	if (right_click)
	{
		// cancel charging
		if (charge_state != SSKArcherParams::not_aiming)
		{
			charge_state = SSKArcherParams::not_aiming;
			ssk_archer.charge_time = 0;
			sprite.SetEmitSoundPaused(true);
			sprite.PlaySound("PopIn.ogg");
		}
		else if (canSend(this)) //otherwise grapple
		{
			ssk_archer.grappling = true;
			ssk_archer.grapple_id = 0xffff;
			ssk_archer.grapple_pos = pos;

			ssk_archer.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				ssk_archer.grapple_vel = direction * ssk_archer_grapple_throw_speed;
			}
			else
			{
				ssk_archer.grapple_vel = Vec2f_zero;
			}

			SyncGrapple(this);
		}

		ssk_archer.charge_state = charge_state;
	}

	if (ssk_archer.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if (!this.isKeyPressed(key_action2))
		{
			if (canSend(this))
			{
				ssk_archer.grappling = false;
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 ssk_archer_grapple_range = ssk_archer_grapple_length * ssk_archer.grapple_ratio;
			const f32 ssk_archer_grapple_force_limit = this.getMass() * ssk_archer_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (ssk_archer.grapple_ratio > 0.2f)
				ssk_archer.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = ssk_archer.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - ssk_archer_grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * ssk_archer_grapple_stiffness);
					force *= Maths::Min(ssk_archer_grapple_force_limit, Maths::Max(0.0f, offdist + ssk_archer_grapple_slack) * ssk_archer_grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? too long? close grapple
			if (ssk_archer.grapple_pos.x < 0 ||
			        ssk_archer.grapple_pos.x > (map.tilemapwidth)*map.tilesize ||
			        dist > ssk_archer_grapple_length * 3.0f)
			{
				if (canSend(this))
				{
					ssk_archer.grappling = false;
					SyncGrapple(this);
				}
			}
			else if (ssk_archer.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(ssk_archer.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				ssk_archer.grapple_vel = (ssk_archer.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = ssk_archer.grapple_pos + ssk_archer.grapple_vel;
				next -= offset;

				Vec2f dir = next - ssk_archer.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
					{
						ssk_archer.grapple_pos += dir * step;
					}
					else
					{
						ssk_archer.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, ssk_archer, map, dist);
				}

			}
			else //stuck -> pull towards pos
			{

				//wallrun/jump reset to make getting over things easier
				//at the top of grapple
				if (this.isOnWall()) //on wall
				{
					//close to the grapple point
					//not too far above
					//and moving downwards
					Vec2f dif = pos - ssk_archer.grapple_pos;
					if (this.getVelocity().y > 0 &&
					        dif.y > -10.0f &&
					        dif.Length() < 24.0f)
					{
						//need move vars
						SSKRunnerMoveVars@ moveVars;
						if (this.get("moveVars", @moveVars))
						{
							moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
						}
					}
				}

				CBlob@ b = null;
				if (ssk_archer.grapple_id != 0)
				{
					@b = getBlobByNetworkID(ssk_archer.grapple_id);
					if (b is null)
					{
						ssk_archer.grapple_id = 0;
					}
				}

				if (b !is null)
				{
					ssk_archer.grapple_pos = b.getPosition();
					if (b.isKeyJustPressed(key_action1) ||
					        b.isKeyJustPressed(key_action2) ||
					        this.isKeyPressed(key_use))
					{
						if (canSend(this))
						{
							ssk_archer.grappling = false;
							SyncGrapple(this);
						}
					}
				}
				else if (shouldReleaseGrapple(this, ssk_archer, map))
				{
					if (canSend(this))
					{
						ssk_archer.grappling = false;
						SyncGrapple(this);
					}
				}

				this.AddForce(force);
				Vec2f target = (this.getPosition() + offset);
				if (!map.rayCastSolid(this.getPosition(), target) &&
					(this.getVelocity().Length() > 2 || !this.isOnMap()))
				{
					this.setPosition(target);
				}

				if (b !is null)
					b.AddForce(-force * (b.getMass() / this.getMass()));

			}
		}

	}
}

void ManageBow(CBlob@ this, SSKArcherInfo@ ssk_archer, SSKRunnerMoveVars@ moveVars)
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	bool hasarrow = ssk_archer.has_arrow;
	s8 charge_time = ssk_archer.charge_time;
	u8 charge_state = ssk_archer.charge_state;
	const bool pressed_action2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();

	if (ismyplayer)
	{
		if ((getGameTime() + this.getNetworkID()) % 10 == 0)
		{
			hasarrow = hasArrows(this);

			if (!hasarrow)
			{
				// set back to default
				for (uint i = 0; i < ArrowType::count; i++)
				{
					hasarrow = hasArrows(this, i);
					if (hasarrow)
					{
						ssk_archer.arrow_type = i;
						break;
					}
				}
			}
		}

		this.set_bool("has_arrow", hasarrow);
		this.Sync("has_arrow", false);

		ssk_archer.stab_delay = 0;
	}

	if (charge_state == SSKArcherParams::legolas_charging) // fast arrows
	{
		if (!hasarrow)
		{
			charge_state = SSKArcherParams::not_aiming;
			charge_time = 0;
		}
		else
		{
			charge_state = SSKArcherParams::legolas_ready;
		}
	}
	//charged - no else (we want to check the very same tick)
	if (charge_state == SSKArcherParams::legolas_ready) // fast arrows
	{
		//moveVars.walkFactor *= 0.75f;

		ssk_archer.legolas_time--;
		if (!hasarrow || ssk_archer.legolas_time == 0)
		{
			bool pressed = this.isKeyPressed(key_action1);
			charge_state = pressed ? SSKArcherParams::readying : SSKArcherParams::not_aiming;
			charge_time = 0;
			//didn't fire
			if (ssk_archer.legolas_arrows == SSKArcherParams::legolas_arrows_count)
			{
				Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
				SSKStatusVars@ statusVars;
				if (this.get("statusVars", @statusVars))
				{
					statusVars.tumbleTime = 15;

					if (getNet().isServer())
						SyncTumbling(this);
				}	
			}
			else if (pressed)
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}
		else if (this.isKeyJustPressed(key_action1) ||
		         (ssk_archer.legolas_arrows == SSKArcherParams::legolas_arrows_count &&
		          !this.isKeyPressed(key_action1) &&
		          this.wasKeyPressed(key_action1)))
		{
			ClientFire(this, charge_time, hasarrow, ssk_archer.arrow_type, true);
			charge_state = SSKArcherParams::legolas_charging;
			charge_time = SSKArcherParams::shoot_period - SSKArcherParams::legolas_charge_time;
			Sound::Play("FastBowPull.ogg", pos);
			ssk_archer.legolas_arrows--;

			if (ssk_archer.legolas_arrows == 0)
			{
				charge_state = SSKArcherParams::readying;
				charge_time = 5;

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}

	}
	else if (this.isKeyPressed(key_action1))
	{
		//moveVars.walkFactor *= 0.75f;
		//moveVars.canVault = false;

		const bool just_action1 = this.isKeyJustPressed(key_action1);

		//	printf("charge_state " + charge_state );

		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
		        (charge_state == SSKArcherParams::not_aiming || charge_state == SSKArcherParams::fired))
		{
			charge_state = SSKArcherParams::readying;
			hasarrow = hasArrows(this);

			if (!hasarrow)
			{
				ssk_archer.arrow_type = ArrowType::normal;
				hasarrow = hasArrows(this);

			}

			if (ismyplayer)
			{
				this.set_bool("has_arrow", hasarrow);
				this.Sync("has_arrow", false);
			}

			charge_time = 0;

			if (!hasarrow)
			{
				charge_state = SSKArcherParams::no_arrows;

				if (ismyplayer && !this.wasKeyPressed(key_action1))   // playing annoying no ammo sound
				{
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
				}

			}
			else
			{
				if (ismyplayer)
				{
					if (just_action1)
					{
						const u8 type = ssk_archer.arrow_type;

						if (type == ArrowType::water)
						{
							sprite.PlayRandomSound("/WaterBubble");
						}
						else if (type == ArrowType::fire)
						{
							sprite.PlaySound("SparkleShort.ogg");
						}
					}
				}

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);

				if (!ismyplayer)   // lower the volume of other players charging  - ooo good idea
				{
					sprite.SetEmitSoundVolume(0.5f);
				}
			}
		}
		else if (charge_state == SSKArcherParams::readying)
		{
			charge_time++;

			if (charge_time > SSKArcherParams::ready_time)
			{
				charge_time = 1;
				charge_state = SSKArcherParams::charging;
			}
		}
		else if (charge_state == SSKArcherParams::charging)
		{
			charge_time++;

			if (charge_time >= SSKArcherParams::legolas_period)
			{
				// Legolas state

				Sound::Play("AnimeSword.ogg", pos, ismyplayer ? 1.3f : 0.7f);
				Sound::Play("FastBowPull.ogg", pos);
				charge_state = SSKArcherParams::legolas_charging;
				charge_time = SSKArcherParams::shoot_period - SSKArcherParams::legolas_charge_time;

				ssk_archer.legolas_arrows = SSKArcherParams::legolas_arrows_count;
				ssk_archer.legolas_time = SSKArcherParams::legolas_time;
			}

			if (charge_time >= SSKArcherParams::shoot_period)
				sprite.SetEmitSoundPaused(true);
		}
		else if (charge_state == SSKArcherParams::no_arrows)
		{
			if (charge_time < SSKArcherParams::ready_time)
			{
				charge_time++;
			}
		}
	}
	else
	{
		if (charge_state > SSKArcherParams::readying)
		{
			if (charge_state < SSKArcherParams::fired)
			{
				ClientFire(this, charge_time, hasarrow, ssk_archer.arrow_type, false);

				charge_time = SSKArcherParams::fired_time;
				charge_state = SSKArcherParams::fired;
			}
			else //fired..
			{
				charge_time--;

				if (charge_time <= 0)
				{
					charge_state = SSKArcherParams::not_aiming;
					charge_time = 0;
				}
			}
		}
		else
		{
			charge_state = SSKArcherParams::not_aiming;    //set to not aiming either way
			charge_time = 0;
		}

		sprite.SetEmitSoundPaused(true);
	}

	// safe disable bomb light

	if (this.wasKeyPressed(key_action1) && !this.isKeyPressed(key_action1))
	{
		const u8 type = ssk_archer.arrow_type;
		if (type == ArrowType::bomb)
		{
			BombFuseOff(this);
		}
	}

	// my player!

	if (ismyplayer)
	{
		// set cursor

		if (!getHUD().hasButtons())
		{
			int frame = 0;
			//	print("ssk_archer.charge_time " + ssk_archer.charge_time + " / " + SSKArcherParams::shoot_period );
			if (ssk_archer.charge_state == SSKArcherParams::readying)
			{
				frame = 1 + float(ssk_archer.charge_time) / float(SSKArcherParams::shoot_period + SSKArcherParams::ready_time) * 7;
			}
			else if (ssk_archer.charge_state == SSKArcherParams::charging)
			{
				if (ssk_archer.charge_time <= SSKArcherParams::shoot_period)
				{
					frame = float(SSKArcherParams::ready_time + ssk_archer.charge_time) / float(SSKArcherParams::shoot_period) * 7;
				}
				else
					frame = 9;
			}
			else if (ssk_archer.charge_state == SSKArcherParams::legolas_ready)
			{
				frame = 10;
			}
			else if (ssk_archer.charge_state == SSKArcherParams::legolas_charging)
			{
				frame = 9;
			}
			getHUD().SetCursorFrame(frame);
		}

		// activate/throw

		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}

		// pick up arrow

		if (ssk_archer.fletch_cooldown > 0)
		{
			ssk_archer.fletch_cooldown--;
		}

		// pickup from ground

		if (ssk_archer.fletch_cooldown == 0 && this.isKeyPressed(key_action2))
		{
			if (getPickupArrow(this) !is null)   // pickup arrow from ground
			{
				this.SendCommand(this.getCommandID("pickup arrow"));
				ssk_archer.fletch_cooldown = PICKUP_COOLDOWN;
			}
		}
	}

	ssk_archer.charge_time = charge_time;
	ssk_archer.charge_state = charge_state;
	ssk_archer.has_arrow = hasarrow;

}

void onTick(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars))
	{
		return;
	}	

	// freeze the logic if hitstunned
	bool isHitstunned = statusVars.isHitstunned;
	if (isHitstunned)
	{
		return;
	}

	SSKArcherInfo@ ssk_archer;
	if (!this.get("ssk_archerInfo", @ssk_archer))
	{
		return;
	}

	if (statusVars.tumbleTime > 0)
	{
		ssk_archer.grappling = false;
		ssk_archer.charge_state = 0;
		ssk_archer.charge_time = 0;
		return;
	}

	ManageGrapple(this, ssk_archer);

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

	SSKRunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	ManageBow(this, ssk_archer, moveVars);
}

bool checkGrappleStep(CBlob@ this, SSKArcherInfo@ ssk_archer, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(ssk_archer.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			ssk_archer.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(ssk_archer, map, dist))
	{
		ssk_archer.grapple_id = 0;

		ssk_archer.grapple_ratio = Maths::Max(0.2, Maths::Min(ssk_archer.grapple_ratio, dist / ssk_archer_grapple_length));

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(ssk_archer.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (ssk_archer.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					ssk_archer.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && b.getShape().isStatic() && !b.hasTag("ignore_arrow"))
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				ssk_archer.grapple_ratio = Maths::Max(0.2, Maths::Min(ssk_archer.grapple_ratio, b.getDistanceTo(this) / ssk_archer_grapple_length));

				ssk_archer.grapple_id = b.getNetworkID();
				if (canSend(this))
				{
					SyncGrapple(this);
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(SSKArcherInfo@ ssk_archer, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(ssk_archer.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(ssk_archer.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(ssk_archer.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(ssk_archer.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(ssk_archer.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, SSKArcherInfo@ ssk_archer, CMap@ map)
{
	return !grappleHitMap(ssk_archer, map) || this.isKeyPressed(key_use);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const s8 charge_time, const bool hasarrow, const u8 arrow_type, const bool legolas)
{
	//time to fire!
	if (hasarrow && canSend(this))  // client-logic
	{
		f32 arrowspeed;

		if (charge_time < SSKArcherParams::ready_time / 2 + SSKArcherParams::shoot_period_1)
		{
			arrowspeed = SSKArcherParams::shoot_max_vel * (1.0f / 3.0f);
		}
		else if (charge_time < SSKArcherParams::ready_time / 2 + SSKArcherParams::shoot_period_2)
		{
			arrowspeed = SSKArcherParams::shoot_max_vel * (4.0f / 5.0f);
		}
		else
		{
			arrowspeed = SSKArcherParams::shoot_max_vel;
		}

		ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), this.getAimPos() + Vec2f(0.0f, -2.0f), arrowspeed, arrow_type, legolas);
	}
}

void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true)
{
	if (canSend(this))
	{
		// player or bot
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		//print("arrowspeed " + arrowspeed);
		CBitStream params;
		params.write_Vec2f(arrowPos);
		params.write_Vec2f(arrowVel);
		params.write_u8(arrow_type);
		params.write_bool(legolas);

		this.SendCommand(this.getCommandID("shoot arrow"), params);
	}
}

CBlob@ getPickupArrow(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "arrow")
			{
				return b;
			}
		}
	}
	return null;
}

bool canPickSpriteArrow(CBlob@ this, bool takeout)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("arrow") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("arrow");
					return true;
				}
			}
		}
	}
	return false;
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("arrow");
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", arrowType);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
	}
	return arrow;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shoot arrow"))
	{
		Vec2f arrowPos = params.read_Vec2f();
		Vec2f arrowVel = params.read_Vec2f();
		u8 arrowType = params.read_u8();
		bool legolas = params.read_bool();

		SSKArcherInfo@ ssk_archer;
		if (!this.get("ssk_archerInfo", @ssk_archer))
		{
			return;
		}

		ssk_archer.arrow_type = arrowType;

		// return to normal arrow - server didnt have this synced
		if (!hasArrows(this, arrowType))
		{
			return;
		}

		if (legolas)
		{
			int r = 0;
			for (int i = 0; i < SSKArcherParams::legolas_arrows_volley; i++)
			{
				if (getNet().isServer())
				{
					CBlob@ arrow = CreateArrow(this, arrowPos, arrowVel, arrowType);
					if (i > 0 && arrow !is null)
					{
						//arrow.Tag("shotgunned");
					}
				}
				this.TakeBlob(arrowTypeNames[ arrowType ], 1);
				arrowType = ArrowType::normal;

				//don't keep firing if we're out of arrows
				if (!hasArrows(this, arrowType))
					break;

				r = r > 0 ? -(r + 1) : (-r) + 1;

				arrowVel = arrowVel.RotateBy(SSKArcherParams::legolas_arrows_deviation * r, Vec2f());
				if (i == 0)
				{
					arrowVel *= 0.9f;
				}
			}
			this.getSprite().PlaySound("BowFire.ogg");
		}
		else
		{
			if (getNet().isServer())
			{
				CreateArrow(this, arrowPos, arrowVel, arrowType);
			}

			this.getSprite().PlaySound("BowFire.ogg");
			this.TakeBlob(arrowTypeNames[ arrowType ], 1);
		}

		ssk_archer.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make arrow
	}
	else if (cmd == this.getCommandID("pickup arrow"))
	{
		CBlob@ arrow = getPickupArrow(this);
		bool spriteArrow = canPickSpriteArrow(this, false); // unnecessary

		if (arrow !is null || spriteArrow)
		{
			if (arrow !is null)
			{
				SSKArcherInfo@ ssk_archer;
				if (!this.get("ssk_archerInfo", @ssk_archer))
				{
					return;
				}
				const u8 arrowType = ssk_archer.arrow_type;
				if (arrowType == ArrowType::bomb)
				{
					arrow.set_u16("follow", 0); //this is already synced, its in command.
					arrow.setPosition(this.getPosition());
					return;
				}
			}

			if (getNet().isServer())
			{
				CBlob@ mat_arrows = server_CreateBlobNoInit('mat_arrows');

				if (mat_arrows !is null)
				{
					mat_arrows.Tag('custom quantity');
					mat_arrows.Init();

					mat_arrows.server_SetQuantity(1); // unnecessary

					if (not this.server_PutInInventory(mat_arrows))
					{
						mat_arrows.setPosition(this.getPosition());
					}

					if (arrow !is null)
					{
						arrow.server_Die();
					}
					else
					{
						canPickSpriteArrow(this, true);
					}
				}
			}

			this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
		}
	}
	else if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		SSKArcherInfo@ ssk_archer;
		if (!this.get("ssk_archerInfo", @ssk_archer))
		{
			return;
		}
		u8 type = ssk_archer.arrow_type;

		int count = 0;
		while (count < arrowTypeNames.length)
		{
			type++;
			count++;
			if (type >= arrowTypeNames.length)
			{
				type = 0;
			}
			if (this.getBlobCount(arrowTypeNames[type]) > 0)
			{
				ssk_archer.arrow_type = type;
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else
	{
		SSKArcherInfo@ ssk_archer;
		if (!this.get("ssk_archerInfo", @ssk_archer))
		{
			return;
		}
		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + arrowTypeNames[i]))
			{
				ssk_archer.arrow_type = i;
				break;
			}
		}
	}
}

// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (arrowTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(arrowTypeNames.length, 2), "Current arrow");

	SSKArcherInfo@ ssk_archer;
	if (!this.get("ssk_archerInfo", @ssk_archer))
	{
		return;
	}
	const u8 arrowSel = ssk_archer.arrow_type;

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			string matname = arrowTypeNames[i];
			CGridButton @button = menu.AddButton(arrowIcons[i], arrowNames[i], this.getCommandID("pick " + matname));

			if (button !is null)
			{
				bool enabled = this.getBlobCount(arrowTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;

				//if (enabled && i == ArrowType::fire && !hasReqs(this, i))
				//{
				//	button.hoverText = "Requires a fire source $lantern$";
				//	//button.SetEnabled( false );
				//}

				if (arrowSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

// auto-switch to appropriate arrow when picked up
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < arrowTypeNames.length; j++)
		{
			if (itemname == arrowTypeNames[j])
			{
				SetHelp(this, "help self action", "ssk_archer", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3);
				if (j > 0 && this.getInventory().getItemsCount() > 1)
				{
					SetHelp(this, "help inventory", "ssk_archer", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2);
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		SSKArcherInfo@ ssk_archer;
		if (!this.get("ssk_archerInfo", @ssk_archer))
		{
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i])
			{
				ssk_archer.arrow_type = i;
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::stab)
	{
		if (damage > 0.0f)
		{

			// fletch arrow
			if (hitBlob.hasTag("tree"))	// make arrow from tree
			{
				if (getNet().isServer())
				{
					CBlob@ mat_arrows = server_CreateBlobNoInit('mat_arrows');
					if (mat_arrows !is null)
					{
						mat_arrows.Tag('custom quantity');
						mat_arrows.Init();

						mat_arrows.server_SetQuantity(fletch_num_arrows);

						if (not this.server_PutInInventory(mat_arrows))
						{
							mat_arrows.setPosition(this.getPosition());
						}
					}
				}
				this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
			}
			else
				this.getSprite().PlaySound("KnifeStab.ogg");
		}

		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);

			SSKStatusVars@ statusVars;
			if (this.get("statusVars", @statusVars))
			{
				statusVars.tumbleTime = 30;

				if (getNet().isServer())
					SyncTumbling(this);
			}	
		}
	}
}

