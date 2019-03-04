// Ninja logic

#include "ThrowCommon.as"
#include "NinjaCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"


//attacks limited to the one time per-actor before reset.

void ninja_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool ninja_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 ninja_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void ninja_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void ninja_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	NinjaInfo ninja;

	ninja.state = NinjaStates::normal;
	ninja.swordTimer = 0;
	ninja.slideTime = 0;
	ninja.doubleslash = false;
	ninja.tileDestructionLimiter = 0;

	this.set("ninjaInfo", @ninja);

	this.set_f32("gib health", -3.0f);
	ninja_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");

	this.addCommandID("get bomb");
	this.addCommandID(grapple_sync_cmd);

	this.push("names to activate", "keg");

	this.set_u8("bomb type", 255);
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		this.addCommandID("pick " + bombTypeNames[i]);
	}

	//centered on bomb select
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//SetHelp(this, "help self action", "ninja", "$Jab$Jab        $LMB$", "", 4);
	//SetHelp(this, "help self action2", "ninja", "$Shield$Shield    $KEY_HOLD$$RMB$", "", 4);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 6, Vec2f(16, 16));
	}
}

void ManageGrapple(CBlob@ this, NinjaInfo@ ninja)
{
	CSprite@ sprite = this.getSprite();
	u8 charge_state = ninja.swordTimer;
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);
	if (right_click)
	{
		// cancel charging
		if (charge_state > NinjaVars::slash_charge)
		{
			charge_state = 0;
			sprite.SetEmitSoundPaused(true);
			sprite.PlaySound("PopIn.ogg");
		}
		else if (canSend(this)) //otherwise grapple
		{
			ninja.grappling = true;
			ninja.grapple_id = 0xffff;
			ninja.grapple_pos = pos;

			ninja.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				ninja.grapple_vel = direction * ninja_grapple_throw_speed;
			}
			else
			{
				ninja.grapple_vel = Vec2f_zero;
			}

			SyncGrapple(this);
		}

		ninja.swordTimer = charge_state;
	}

	if (ninja.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if (!this.isKeyPressed(key_action2))
		{
			if (canSend(this))
			{
				ninja.grappling = false;
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 ninja_grapple_range = ninja_grapple_length * ninja.grapple_ratio;
			const f32 ninja_grapple_force_limit = this.getMass() * ninja_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (ninja.grapple_ratio > 0.2f)
				ninja.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = ninja.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - ninja_grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * ninja_grapple_stiffness);
					force *= Maths::Min(ninja_grapple_force_limit, Maths::Max(0.0f, offdist + ninja_grapple_slack) * ninja_grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? close grapple
			if (ninja.grapple_pos.x < map.tilesize || ninja.grapple_pos.x > (map.tilemapwidth - 1)*map.tilesize)
			{
				if (canSend(this))
				{
					SyncGrapple(this);
					ninja.grappling = false;
				}
			}
			else if (ninja.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(ninja.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				ninja.grapple_vel = (ninja.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = ninja.grapple_pos + ninja.grapple_vel;
				next -= offset;

				Vec2f dir = next - ninja.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
					{
						ninja.grapple_pos += dir * step;
					}
					else
					{
						ninja.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, ninja, map, dist);
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
					Vec2f dif = pos - ninja.grapple_pos;
					if (this.getVelocity().y > 0 &&
					        dif.y > -10.0f &&
					        dif.Length() < 24.0f)
					{
						//need move vars
						RunnerMoveVars@ moveVars;
						if (this.get("moveVars", @moveVars))
						{
							moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
						}
					}
				}

				CBlob@ b = null;
				if (ninja.grapple_id != 0)
				{
					@b = getBlobByNetworkID(ninja.grapple_id);
					if (b is null)
					{
						ninja.grapple_id = 0;
					}
				}

				if (b !is null)
				{
					ninja.grapple_pos = b.getPosition();
					if (b.isKeyJustPressed(key_action1) ||
					        b.isKeyJustPressed(key_action2) ||
					        this.isKeyPressed(key_use))
					{
						if (canSend(this))
						{
							SyncGrapple(this);
							ninja.grappling = false;
						}
					}
				}
				else if (shouldReleaseGrapple(this, ninja, map))
				{
					if (canSend(this))
					{
						SyncGrapple(this);
						ninja.grappling = false;
					}
				}

				this.AddForce(force);
				Vec2f target = (this.getPosition() + offset);
				if (!map.rayCastSolid(this.getPosition(), target))
				{
					this.setPosition(target);
				}

				if (b !is null)
					b.AddForce(-force * (b.getMass() / this.getMass()));

			}
		}

	}
}

void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);

	if (this.isInInventory())
		return;

	//ninja logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	NinjaInfo@ ninja;
	if (!this.get("ninjaInfo", @ninja))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	bool swordState = isSwordState(ninja.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	//with the code about menus and myplayer you can slash-cancel;
	//we'll see if ninjas dmging stuff while in menus is a real issue and go from there
	if (knocked > 0)// || myplayer && getHUD().hasMenus())
	{
		ninja.state = NinjaStates::normal; //cancel any attacks or shielding
		ninja.swordTimer = 0;
		ninja.grappling = false;
		ninja.slideTime = 0;
		ninja.doubleslash = false;

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	else if ((pressed_a1 || swordState) && !moveVars.wallsliding)   //no attacking during a slide
	{
		if (getNet().isClient())
		{
			if (ninja.swordTimer == NinjaVars::slash_charge_level2)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
			else if (ninja.swordTimer == NinjaVars::slash_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
		}

		if (ninja.swordTimer > NinjaVars::slash_charge_limit)
		{
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked(this, 15);
		}

		bool strong = (ninja.swordTimer > NinjaVars::slash_charge_level2);
		moveVars.jumpFactor *= (strong ? 0.6f : 0.8f);
		moveVars.walkFactor *= (strong ? 0.8f : 0.9f);
		//ninja.shieldTimer = 0;

		if (!inair)
		{
			this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
		}

		if (ninja.state == NinjaStates::normal ||
		        this.isKeyJustPressed(key_action1) &&
		        !inMiddleOfAttack(ninja.state) )
		{
			ninja.state = NinjaStates::sword_drawn;
			ninja.swordTimer = 0;
		}

		if (ninja.state == NinjaStates::sword_drawn && getNet().isServer())
		{
			ninja_clear_actor_limits(this);
		}

		//responding to releases/noaction
		s32 delta = ninja.swordTimer;
		if (ninja.swordTimer < 128)
			ninja.swordTimer++;

		if (ninja.state == NinjaStates::sword_drawn && !pressed_a1 &&
		        !this.isKeyJustReleased(key_action1) && delta > NinjaVars::resheath_time)
		{
			ninja.state = NinjaStates::normal;
		}
		else if (this.isKeyJustReleased(key_action1) && ninja.state == NinjaStates::sword_drawn)
		{
			ninja.swordTimer = 0;

			if (delta < NinjaVars::slash_charge)
			{
				if (direction == -1)
				{
					ninja.state = NinjaStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					if (aimpos.y < pos.y)
					{
						ninja.state = NinjaStates::sword_cut_mid;
					}
					else
					{
						ninja.state = NinjaStates::sword_cut_mid_down;
					}
				}
				else
				{
					ninja.state = NinjaStates::sword_cut_down;
				}
			}
			else if (delta < NinjaVars::slash_charge_level2)
			{
				ninja.state = NinjaStates::sword_power;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				ninja.slash_direction = aiming_direction;
			}
			else if (delta < NinjaVars::slash_charge_limit)
			{
				ninja.state = NinjaStates::sword_power_super;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				ninja.slash_direction = aiming_direction;
			}
			else
			{
				//knock?
			}
		}
		else if (ninja.state >= NinjaStates::sword_cut_mid &&
		         ninja.state <= NinjaStates::sword_cut_down) // cut state
		{
			if (delta == DELTA_BEGIN_ATTACK)
			{
				Sound::Play("/SwordSlash", this.getPosition());
			}

			if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
			{
				f32 attackarc = 90.0f;
				f32 attackAngle = getCutAngle(this, ninja.state);

				if (ninja.state == NinjaStates::sword_cut_down)
				{
					attackarc *= 0.9f;
				}

				DoAttack(this, 1.0f, attackAngle, attackarc, Hitters::sword, delta, ninja);
			}
			else if (delta >= 9)
			{
				ninja.swordTimer = 0;
				ninja.state = NinjaStates::sword_drawn;
			}
		}
		else if (ninja.state == NinjaStates::sword_power ||
		         ninja.state == NinjaStates::sword_power_super)
		{

			//attacking + noises
			if (delta == 2)
			{
				Sound::Play("/ArgLong", this.getPosition());
				Sound::Play("/SwordSlash", this.getPosition());
			}
			else if (delta > DELTA_BEGIN_ATTACK && delta < 10)
			{
				DoAttack(this, 2.0f, -(vec.Angle()), 120.0f, Hitters::sword, delta, ninja);
			}
			else if (delta >= NinjaVars::slash_time ||
			         (ninja.doubleslash && delta >= NinjaVars::double_slash_time))
			{
				ninja.swordTimer = 0;

				if (ninja.doubleslash)
				{
					ninja_clear_actor_limits(this);
					ninja.doubleslash = false;
					ninja.state = NinjaStates::sword_power;
				}
				else
				{
					ninja.state = NinjaStates::sword_drawn;
				}
			}
		}

		//special slash movement

		if ((ninja.state == NinjaStates::sword_power ||
		        ninja.state == NinjaStates::sword_power_super) &&
		        delta < NinjaVars::slash_move_time)
		{

			if (Maths::Abs(vel.x) < NinjaVars::slash_move_max_speed &&
			        vel.y > -NinjaVars::slash_move_max_speed)
			{
				Vec2f slash_vel =  ninja.slash_direction * this.getMass() * 0.5f;
				this.AddForce(slash_vel);
			}
		}

		moveVars.canVault = false;

	}
	else if (this.isKeyJustReleased(key_action2) || this.isKeyJustReleased(key_action1) || this.get_u32("ninja_timer") <= getGameTime())
	{
		ninja.state = NinjaStates::normal;
	}

	//throwing bombs

	if (myplayer)
	{
		// space

		if (this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			bool holding = carried !is null;// && carried.hasTag("exploding");

			CInventory@ inv = this.getInventory();
			bool thrown = false;
			u8 bombType = this.get_u8("bomb type");
			if (bombType == 255)
			{
				SetFirstAvailableBomb(this);
				bombType = this.get_u8("bomb type");
			}
			if (bombType < bombTypeNames.length)
			{
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ item = inv.getItem(i);
					const string itemname = item.getName();
					if (!holding && bombTypeNames[bombType] == itemname)
					{
						if (bombType >= 2)
						{
							this.server_Pickup(item);
							client_SendThrowOrActivateCommand(this);
							thrown = true;
						}
						else
						{
							CBitStream params;
							params.write_u8(bombType);
							this.SendCommand(this.getCommandID("get bomb"), params);
							thrown = true;
						}
						break;
					}
				}
			}

			if (!thrown)
			{
				client_SendThrowOrActivateCommand(this);
				SetFirstAvailableBomb(this);
			}
		}

		// help

		if (this.isKeyJustPressed(key_action1) && getGameTime() > 150)
		{
			SetHelp(this, "help self action", "ninja", "$Slash$ Slash!    $KEY_HOLD$$LMB$", "", 13);
		}
	}

	ManageGrapple(this, ninja);

	if (!swordState && getNet().isServer())
	{
		ninja_clear_actor_limits(this);
	}
}

bool checkGrappleStep(CBlob@ this, NinjaInfo@ ninja, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(ninja.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			ninja.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(ninja, map, dist))
	{
		ninja.grapple_id = 0;

		ninja.grapple_ratio = Maths::Max(0.2, Maths::Min(ninja.grapple_ratio, dist / ninja_grapple_length));

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(ninja.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (ninja.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					ninja.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && b.getShape().isStatic())
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				ninja.grapple_ratio = Maths::Max(0.2, Maths::Min(ninja.grapple_ratio, b.getDistanceTo(this) / ninja_grapple_length));

				ninja.grapple_id = b.getNetworkID();
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

bool grappleHitMap(NinjaInfo@ ninja, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(ninja.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(ninja.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(ninja.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(ninja.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(ninja.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, NinjaInfo@ ninja, CMap@ map)
{
	return !grappleHitMap(ninja, map) || this.isKeyPressed(key_use);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("get bomb"))
	{
		const u8 bombType = params.read_u8();
		if (bombType >= bombTypeNames.length)
			return;

		const string bombTypeName = bombTypeNames[bombType];
		this.Tag(bombTypeName + " done activate");
		if (hasItem(this, bombTypeName))
		{
			if (bombType == 0)
			{
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
					}
				}
			}
			else if (bombType == 1)
			{
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("waterbomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio", 0.0f);
						blob.set_f32("explosive_damage", 0.0f);
						blob.set_f32("explosive_radius", 92.0f);
						blob.set_bool("map_damage_raycast", false);
						blob.set_string("custom_explosion_sound", "/GlassBreak");
						blob.set_u8("custom_hitter", Hitters::water);
					}
				}
			}
			else
			{
			}

			SetFirstAvailableBomb(this);
		}
	}
	else if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		u8 type = this.get_u8("bomb type");
		int count = 0;
		while (count < bombTypeNames.length)
		{
			type++;
			count++;
			if (type >= bombTypeNames.length)
				type = 0;
			if (this.getBlobCount(bombTypeNames[type]) > 0)
			{
				this.set_u8("bomb type", type);
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else if (cmd == this.getCommandID("activate/throw"))
	{
		SetFirstAvailableBomb(this);
	}
	else
	{
		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + bombTypeNames[i]))
			{
				this.set_u8("bomb type", i);
				break;
			}
		}
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// play cling sound if other ninja attacked us
	// dmg could be taken out here if we ever want to

	if (hitterBlob.getPosition().x < this.getPosition().x && (hitterBlob.getName() == "ninja" || hitterBlob.getName() == "knight")) // ninja and the left one (to play only once)
	{
		CSprite@ sprite = this.getSprite();
		CSprite@ hsprite = hitterBlob.getSprite();

		if (hsprite.isAnimation("strike_power_ready") || hsprite.isAnimation("strike_mid") ||
		        hsprite.isAnimation("strike_mid_down") || hsprite.isAnimation("strike_up") ||
		        hsprite.isAnimation("strike_down") || hsprite.isAnimation("strike_up"))
		{
			if (sprite.isAnimation("strike_power_ready") || sprite.isAnimation("strike_mid") ||
			        sprite.isAnimation("strike_mid_down") || sprite.isAnimation("strike_up") ||
			        sprite.isAnimation("strike_down") || sprite.isAnimation("strike_up"))
			{
				this.getSprite().PlaySound("SwordCling");
			}
		}
	}

	return damage; //no block, damage goes through
}

/////////////////////////////////////////////////

bool isJab(f32 damage)
{
	return damage < 1.5f;
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, NinjaInfo@ info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), MAX_ATTACK_DISTANCE);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = isJab(damage);

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (ninja_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				ninja_add_actor_limit(this, b);
				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, type, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap && (deltaInt == DELTA_BEGIN_ATTACK + 1))
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab
							if (jab) //fake damage
							{
								info.tileDestructionLimiter++;
								canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);
							}
							else //reset fake dmg for next time
							{
								info.tileDestructionLimiter = 0;
							}

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								map.server_DestroyTile(hi.hitpos, 0.1f, this);
							}
						}
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool isSliding(NinjaInfo@ ninja)
{
	return (ninja.slideTime > 0 && ninja.slideTime < 45);
}

// shieldbash

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}

	// ninja hit
}


//a little push forward

void pushForward(CBlob@ this, f32 normalForce, f32 pushingForce, f32 verticalForce)
{
	f32 facing_sign = this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	    (facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	    (facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force = normalForce;

	if (pushing_in_facing_direction)
	{
		force = pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign , verticalForce));
}

//bomb management

bool hasItem(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		return hasRequirements(inv, reqs, missing);
	}
	else
	{
		warn("our inventory was null! NinjaLogic.as");
	}

	return false;
}

void TakeItem(CBlob@ this, const string &in name)
{
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	{
		if (carried.getName() == name)
		{
			carried.server_Die();
			return;
		}
	}

	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		if (hasRequirements(inv, reqs, missing))
		{
			server_TakeRequirements(inv, reqs);
		}
		else
		{
			warn("took a bomb even though we dont have one! NinjaLogic.as");
		}
	}
	else
	{
		warn("our inventory was null! NinjaLogic.as");
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	NinjaInfo@ ninja;
	if (!this.get("ninjaInfo", @ninja))
	{
		return;
	}

	if (customData == Hitters::sword &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            ninja.state == NinjaStates::sword_cut_mid ||
	            ninja.state == NinjaStates::sword_cut_mid_down ||
	            ninja.state == NinjaStates::sword_cut_up ||
	            ninja.state == NinjaStates::sword_cut_down
	        )
	        && blockAttack(hitBlob, velocity, 0.0f))
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked(this, 30);
	}

	if (customData == Hitters::shield)
	{
		SetKnocked(hitBlob, 20);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}
}



// bomb pick menu

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (bombTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(bombTypeNames.length, 2), "Current bomb");
	u8 weaponSel = this.get_u8("bomb type");

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			string matname = bombTypeNames[i];
			CGridButton @button = menu.AddButton(bombIcons[i], bombNames[i], this.getCommandID("pick " + matname));

			if (button !is null)
			{
				bool enabled = this.getBlobCount(bombTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;
				if (weaponSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		if (attached.getName() == bombTypeNames[i])
		{
			this.set_u8("bomb type", i);
			break;
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string itemname = blob.getName();
	if (this.isMyPlayer() && this.getInventory().getItemsCount() > 1)
	{
		for (uint j = 1; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				SetHelp(this, "help inventory", "ninja", "$Help_Bomb1$$Swap$$Help_Bomb2$         $KEY_TAP$$KEY_F$", "", 2);
				break;
			}
		}
	}

	if (this.getInventory().getItemsCount() == 0 || itemname == "mat_bombs")
	{
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				this.set_u8("bomb type", j);
				return;
			}
		}
	}
}

void SetFirstAvailableBomb(CBlob@ this)
{
	u8 type = 255;
	if (this.exists("bomb type"))
		type = this.get_u8("bomb type");

	CInventory@ inv = this.getInventory();

	bool typeReal = (uint(type) < bombTypeNames.length);
	if (typeReal && inv.getItem(bombTypeNames[type]) !is null)
		return;

	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		const string itemname = inv.getItem(i).getName();
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				type = j;
				break;
			}
		}

		if (type != 255)
			break;
	}

	this.set_u8("bomb type", type);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}


// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}
