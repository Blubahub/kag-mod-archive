// Samurai logic

#include "ThrowCommon.as"
#include "SamuraiCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"


//attacks limited to the one time per-actor before reset.

void samurai_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool samurai_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 samurai_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void samurai_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void samurai_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	SamuraiInfo samurai;

	samurai.state = SamuraiStates::normal;
	samurai.swordTimer = 0;
	samurai.slideTime = 0;
	samurai.doubleslash = false;
	samurai.tileDestructionLimiter = 0;

	this.set("samuraiInfo", @samurai);

	this.set_f32("gib health", -3.0f);
	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
	samurai_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");
	
	this.set_s16("jumps",2);
	this.set_s16("jump_time",0);
	
	this.push("names to activate", "keg");

	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.Tag("super_wallrun");
	
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 13, Vec2f(16, 16));
	}
}


void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);



	if (this.isInInventory())
		return;

	//samurai logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	moveVars.jumpFactor *= 2.0f;
	moveVars.walkFactor *= 1.5f;

	SamuraiInfo@ samurai;
	if (!this.get("samuraiInfo", @samurai))
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

	bool swordState = isSwordState(samurai.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	//with the code about menus and myplayer you can slash-cancel;
	//we'll see if samurais dmging stuff while in menus is a real issue and go from there
	if (knocked > 0)// || myplayer && getHUD().hasMenus())
	{
		samurai.state = SamuraiStates::normal;
		samurai.swordTimer = 0;
		samurai.slideTime = 0;
		samurai.doubleslash = false;

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	else if ((pressed_a1 || swordState))
	{

		if (samurai.state == SamuraiStates::normal ||
		        this.isKeyJustPressed(key_action1) &&
		        (!inMiddleOfAttack(samurai.state)))
		{
			samurai.state = SamuraiStates::sword_drawn;
			samurai.swordTimer = 0;
		}

		if (samurai.state == SamuraiStates::sword_drawn && getNet().isServer())
		{
			samurai_clear_actor_limits(this);
		}

		//responding to releases/noaction
		s32 delta = samurai.swordTimer;
		if (samurai.swordTimer < 32)
			samurai.swordTimer++;

		if (samurai.state == SamuraiStates::sword_drawn && !pressed_a1 &&
		        !(this.isKeyJustReleased(key_action1) || samurai.swordTimer > 4) && delta > SamuraiVars::resheath_time)
		{
			samurai.state = SamuraiStates::normal;
		}
		else if ((this.isKeyJustReleased(key_action1) || samurai.swordTimer > 4) && samurai.state == SamuraiStates::sword_drawn)
		{
			samurai.swordTimer = 0;

			if (delta < 32)
			{
				if (direction == -1)
				{
					samurai.state = SamuraiStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					if (aimpos.y < pos.y)
					{
						samurai.state = SamuraiStates::sword_cut_mid;
					}
					else
					{
						samurai.state = SamuraiStates::sword_cut_mid_down;
					}
				}
				else
				{
					samurai.state = SamuraiStates::sword_cut_down;
				}
			}
			else
			{
				//knock?
			}
		}
		else if (samurai.state >= SamuraiStates::sword_cut_mid &&
		         samurai.state <= SamuraiStates::sword_cut_down) // cut state
		{
			if (delta == DELTA_BEGIN_ATTACK)
			{
				Sound::Play("/SwordSlash", this.getPosition());
			}

			if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
			{
				f32 attackarc = 90.0f;
				f32 attackAngle = getCutAngle(this, samurai.state);

				if (samurai.state == SamuraiStates::sword_cut_down)
				{
					attackarc *= 0.9f;
				}

				DoAttack(this, 1.0f, attackAngle, attackarc, Hitters::sword, delta, samurai);
			}
			else if (delta >= 9)
			{
				samurai.swordTimer = 0;
				samurai.state = SamuraiStates::sword_drawn;
			}
		}

	}
	else if (this.isKeyJustReleased(key_action2) || this.isKeyJustReleased(key_action1) || this.get_u32("samurai_timer") <= getGameTime())
	{
		samurai.state = SamuraiStates::normal;
	}

	if (myplayer)
	{
		// help

		if (this.isKeyJustPressed(key_action1) && getGameTime() > 150)
		{
			SetHelp(this, "help self action", "ninja", "$Slash$ Slash!    $KEY_HOLD$$LMB$", "", 13);
		}
	}
	
	if(this.get_s16("jumps") > 0 && knocked <= 0 && !this.hasTag("cant_jump")){
		this.Untag("DisableTwo");
		if(this.isKeyPressed(key_action2)){
			Vec2f jumpVel = this.getAimPos()-this.getPosition();
			jumpVel.Normalize();
			this.setVelocity(jumpVel*8);
			this.Tag("cant_jump");
		}
	} else this.Tag("DisableTwo");
	
	if(this.isOnGround())this.Untag("cant_jump");

	if (!swordState && getNet().isServer())
	{
		samurai_clear_actor_limits(this);
	}
	
	if (!this.isOnGround())
	{
		Vec2f vel = this.getVelocity();
		if (Maths::Abs(vel.x) > 0.1)
		{
			f32 angle = this.get_f32("angle");
			angle += vel.x * this.getRadius();
			if (angle > 360.0f)
				angle -= 360.0f;
			else if (angle < -360.0f)
				angle += 360.0f;
			this.set_f32("angle", angle);
			this.setAngleDegrees(angle);
		}
	}
	else
	{
		this.setAngleDegrees(0);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//if(customData == Hitters::fall)return 0;

	return damage;
}

/////////////////////////////////////////////////

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, SamuraiInfo@ info)
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
	const bool jab = false;

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

				if (samurai_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				samurai_add_actor_limit(this, b);
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

bool isSliding(SamuraiInfo@ samurai)
{
	return (samurai.slideTime > 0 && samurai.slideTime < 45);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}
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

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	SamuraiInfo@ samurai;
	if (!this.get("samuraiInfo", @samurai))
	{
		return;
	}

	if (customData == Hitters::sword &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            samurai.state == SamuraiStates::sword_cut_mid ||
	            samurai.state == SamuraiStates::sword_cut_mid_down ||
	            samurai.state == SamuraiStates::sword_cut_up ||
	            samurai.state == SamuraiStates::sword_cut_down
	        )
	        && blockAttack(hitBlob, velocity, 0.0f))
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked(this, 30);
	}

	if (customData == Hitters::shield)
	{
		SetKnocked(hitBlob, 10);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}
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
