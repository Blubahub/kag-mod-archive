// BallPlayer logic

#include "ThrowCommon.as"
#include "BeachVolleyPlayerCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"

//attacks limited to the one time per-actor before reset.
void ballplayer_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool ballplayer_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 ballplayer_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void ballplayer_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void ballplayer_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	BallPlayerInfo BallPlayer;

	BallPlayer.state = BallPlayerStates::normal;
	BallPlayer.smackTimer = 0;

	this.set("BallPlayerInfo", @BallPlayer);

	this.set_f32("gib health", -1.5f);
	this.getShape().SetRotationsAllowed(false);
	ballplayer_actorlimit_setup(this);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");
	this.set_bool("hasSwung", false);

	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
	}
}


void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);

	if (this.isInInventory())
		return;

	//BallPlayer logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	BallPlayerInfo@ BallPlayer;
	if (!this.get("BallPlayerInfo", @BallPlayer))
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

	bool smackState = isSmackState(BallPlayer.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();
	s32 delta = BallPlayer.smackTimer;	

	if (BallPlayer.state != BallPlayerStates::normal) // timer counts all the way through to end of cooldown
	{			
		if (BallPlayer.smackTimer < 128)
			BallPlayer.smackTimer++;	
	}

	//with the code about menus and myplayer you can smack-cancel;
	//we'll see if BallPlayers dmging stuff while in menus is a real issue and go from there
	if (knocked > 0)// || myplayer && getHUD().hasMenus())
	{
		BallPlayer.state = BallPlayerStates::normal;
		BallPlayer.smackTimer = 0;
		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;
	}
	else if (BallPlayer.state == BallPlayerStates::normal &&
	        pressed_a1 && (!smackState))
	{
		this.set_bool("can do smack", true);
		BallPlayer.state = BallPlayerStates::smack_drawn;
		BallPlayer.chargeAmount = 0;
		BallPlayer.smackTimer = 0;

		if (getNet().isServer())
		{
			ballplayer_clear_actor_limits(this);
		}	
	}	
	else if ((BallPlayer.state == BallPlayerStates::smack_drawn) && pressed_a1 && this.get_bool("can do smack"))   //no attacking during a slide
	{

		if (getNet().isClient())
		{
		//	if (BallPlayer.smackTimer == BallPlayerVars::smack_charge)
		//	{
		//		//Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
		//	}
		//	else if (BallPlayer.smackTimer == BallPlayerVars::smack_charge_level2)
		//	{
		//		Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
		//	}
		}

		Vec2f aiming_direction = (aimpos-pos);
		aiming_direction.Normalize();
		BallPlayer.smack_direction = aiming_direction;

		if (BallPlayer.smackTimer >= BallPlayerVars::smack_charge_limit+12)
		{
			Sound::Play("/Oof", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked(this, 15);
		}

		if (!inair)
		{
			this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
		}	
		
		moveVars.canVault = false;
	}
	else if (this.isKeyJustReleased(key_action1) && BallPlayer.state == BallPlayerStates::smack_drawn && this.get_bool("can do smack"))
	{		
		if (delta >= 15)
		{			
			Sound::Play("/ArgShort", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.6f);
		}	

	//	Vec2f aiming_direction = (aimpos-pos);
	//	BallPlayer.smack_direction = aiming_direction;

		BallPlayer.chargeAmount = BallPlayer.smackTimer;
		BallPlayer.state = BallPlayerStates::smack_ing;
		this.set_bool("can do smack",false); // smack is underway, wait till full reset before we can charge again.	
	}

	else if (BallPlayer.state == BallPlayerStates::smack_ing)
	{			
		s32 chargedelta = BallPlayer.chargeAmount;

		if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK+(chargedelta)+10)
		{
			CBlob@[] blobsInRadius;

			if (this.getMap().getBlobsInRadius(this.getPosition(), ATTACK_DISTANCE+2.0f, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					{
						if (b !is this && !b.isAttached() && !b.getShape().isStatic())
						{								
							f32 aimangle = BallPlayer.smack_direction.Angle();						
							DoAttack(this, -aimangle, 115.0f, BallPlayer.chargeAmount, BallPlayer);
							//BallPlayer.state = BallPlayerStates::smack_coolingdown;
						}
					}
				}
			}
		}
		else //if (delta >= 9)
		{
			BallPlayer.state = BallPlayerStates::smack_coolingdown;
		}
	}
	else if (BallPlayer.state == BallPlayerStates::smack_coolingdown)// && )
	{
		if (delta > BallPlayer.chargeAmount +9)
		{
			BallPlayer.state = BallPlayerStates::normal;
		}
	}
	else
	{ 
		BallPlayer.state = BallPlayerStates::normal; 
		this.Untag("HeavySlap");
	}

	//special smack movement
	if (BallPlayer.state == BallPlayerStates::smack_ing &&
		BallPlayer.chargeAmount > 9  &&
	    delta < (BallPlayer.chargeAmount + BallPlayerVars::smack_move_time) )
	{

		if (Maths::Abs(vel.x) < BallPlayerVars::smack_move_max_speed &&
		        vel.y > -BallPlayerVars::smack_move_max_speed)
		{
			Vec2f aiming_direction = (aimpos - pos);
			aiming_direction.Normalize();

			Vec2f smack_vel =  aiming_direction * this.getMass() * BallPlayer.chargeAmount*0.02f;
			this.AddForce(smack_vel);
		}
	}	
	
	if (myplayer)
	{
		if (!getHUD().hasButtons())
		{
			int frame = 0;
			if (BallPlayer.state == BallPlayerStates::smack_drawn)
			{
				frame = float(BallPlayer.smackTimer)/6;
			}
			getHUD().SetCursorFrame(frame);
		}
	}
}

void DoAttack(CBlob@ this, f32 aimangle, f32 arcdegrees, f32 chargeAmount, BallPlayerInfo@ info)
{
	if (!getNet().isServer()) { return; }

	if (aimangle < 0.0f) { aimangle += 360.0f; }

	Vec2f blobPos = this.getOldPosition(); // old position helps
	Vec2f myvel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + myvel;
	bool dontHitMore = false;
	const f32 minHitAmount = 5.4f; // quick jabs always get some height.

	CMap@ map = this.getMap();

	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, ATTACK_DISTANCE, this, @hitInfos))
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore)
			{
				if (ballplayer_has_hit_actor(this, b))
				{
					dontHitMore = true;
					continue;
				}

				ballplayer_add_actor_limit(this, b);
				Vec2f velocity = thinghy*(minHitAmount+(chargeAmount*0.03));

				Vec2f bvel = b.getOldVelocity();
				bvel.y = (bvel.y/2);
				
				Vec2f hitVelocity = bvel/2+(velocity+myvel);	

				hitVelocity.x = Maths::Min(hitVelocity.x, 12.0f);
				hitVelocity.y = Maths::Min(hitVelocity.y, 12.0f);
				hitVelocity.x = Maths::Max(hitVelocity.x, -12.0f);
				hitVelocity.y = Maths::Max(hitVelocity.y, -12.0f);
				//print("hitVelocity.x "+hitVelocity.x);

				if (!dontHitMore) //&& ballplayer_hit_actor_count(this) == 0)
				{			
					this.server_Hit(b, hi.hitpos, hitVelocity, 0.0f, 0, true);
				}
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	//if (damage == 0.0f)
	{		
		if (hitBlob.hasTag("volleyball"))
		{				
			hitBlob.getSprite().PlaySound("/BallHit"+(1+XORRandom(3))+".ogg");
			hitBlob.setVelocity(velocity);
		}
		else if (hitBlob.hasTag("flesh"))
		{			
			f32 vellen = velocity.Length();	

			if (vellen > 8.5f )
			{
				this.Tag("HeavySlap");
				if ( hitBlob.getName() == "beachvolleyplayer" && hitBlob.hasTag("HeavySlap")
					 && hitBlob.getTeamNum() == this.getTeamNum() && (this.isFacingLeft() != hitBlob.isFacingLeft()) )
				{
					hitBlob.getSprite().PlaySound("/SlapEcho"+(1+XORRandom(2))+".ogg");
				}
				else
				{
					hitBlob.getSprite().PlaySound("/Slap"+(1+XORRandom(4))+".ogg");					
				}	
				hitBlob.AddForce(velocity);			
				Sweaty(hitBlob);
			}
			else if (vellen > 6.7f )
			{
				hitBlob.getSprite().PlaySound("/SlapQuiet"+(1+XORRandom(3))+".ogg");
				hitBlob.AddForce(velocity);
				Sweaty(hitBlob);
			}
		}
		else
		{
			hitBlob.AddForce(velocity);
		}
	}
}

void Sweaty(CBlob@ blob)
{
	//sweaty bitch
	for (uint i = 0; i < 5; i++)
	{
		Vec2f randVel = getRandomVelocity(10, -10.0f, 90.0f);

		CParticle@ sweat = ParticlePixel(blob.getPosition(), randVel, SColor(255,120,200,200+XORRandom(55)), false, 3 + XORRandom(20));
        if(sweat is null) return;

        //sweat.timeout = 20 + XORRandom(100);
        sweat.scale = 0.85f + (XORRandom(15)*0.1f);
        sweat.damping = 0.90f;
        //sweat.rotates = true;
       	sweat.growth = -0.1f;
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

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{
	//if (b.hasTag("invincible")) // slaps dont do damage anyway
	//	return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{
		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead")) return true;

	return b.getTeamNum() != this.getTeamNum();

}
