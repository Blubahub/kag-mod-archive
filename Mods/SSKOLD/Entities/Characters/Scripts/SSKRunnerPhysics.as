// Runner Movement Walking

#include "SSKRunnerCommon.as"
#include "SSKStatusCommon.as"
#include "MakeDustParticle.as"
#include "FallDamageCommon.as"
#include "SSKExplosion.as"

const f32 GRAVITY = 0.5f;
const f32 TERMINAL_VEL = 6.0f;

const f32 FRICTION_FACTOR_TUMBLING = 0.99f;
const f32 GRAVITY_TUMBLING = 0.2f;
const u32 MIN_TUMBLE_TIME_BEFORE_RECOVER = 40;

const f32 FAST_FALL_SPEED = 8.0f;

void onInit(CMovement@ this)
{
	CBlob@ blob = this.getBlob();

	// explosion variables for when hitting walls
	blob.set_f32("map_damage_radius", 12.0f);
	blob.set_f32("map_damage_ratio", 1.0f);
	blob.set_string("custom_explosion_sound", "flame2.ogg");

	this.getCurrentScript().removeIfTag = "dead";

	// add tumble jet sprite layer
	CSprite@ sprite = blob.getSprite();
	sprite.RemoveSpriteLayer("tumblejet");
	CSpriteLayer@ jet = sprite.addSpriteLayer("tumblejet", "fireball1.png", 32, 32);
	if (jet !is null)
	{
		Animation@ anim = jet.addAnimation("default", 2, true);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		jet.SetVisible(false);
		jet.SetRelativeZ(1000.0f);
	}
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	CSprite@ sprite = blob.getSprite();

	SSKStatusVars@ statusVars;
	if (!blob.get("statusVars", @statusVars))
	{
		return;
	}

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	const bool is_client = getNet().isClient();

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const f32 vellen = shape.vellen;
	const bool onground = blob.isOnGround() || blob.isOnLadder();
	const bool inwater = blob.isInWater();

	//hitstun
	bool isHitstunned = statusVars.isHitstunned;
	if (isHitstunned)
	{
		blob.setVelocity(Vec2f_zero);
		return;
	}

	bool inMoveAnimation = statusVars.inMoveAnimation;

	f32 newVelY = vel.y;
	f32 newVelX = vel.x;

	u16 tumbleTime = statusVars.tumbleTime;

	// tumbling physics
	Vec2f tumbleVec = statusVars.tumbleVec;
	f32 tumbleVecLen = tumbleVec.getLength();
	Vec2f tumbleNorm = tumbleVec;
	tumbleNorm.Normalize();
	bool tumblingFast = tumbleTime > 0 && tumbleVecLen >= 8.0f;
	bool showTumbleJet = tumbleTime > 0 && tumbleVecLen >= 12.0f;

	// play homerun sound if force was just applied
	if (!statusVars.isTumbling)
	{
		if (tumbleTime > 0 && !isHitstunned)
		{
			if (getNet().isServer())
			{
				statusVars.isTumbling = true;
				SyncTumbling(blob);
			}
		}
	}
	else if (tumbleTime <= 0)
	{
		if (getNet().isServer())
		{
			statusVars.isTumbling = false;
			SyncTumbling(blob);
		}
	}

	if (statusVars.isTumbling)
	{
		newVelX = tumbleVec.x;
		newVelY = tumbleVec.y;

		// dimensions for checking solid tiles
		const f32 ts = map.tilesize;
		const f32 y_ts = ts * 0.2f;
		const f32 x_ts = ts * 1.4f;

		bool bounce = false;
		f32 effectAngle = 0;

		// if player touching a suface, then bounce him
		if (tumbleVec.y > 1.0f)
		{
			bool surface_below = map.isTileSolid(pos + Vec2f(y_ts, x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, x_ts));
			bool surface_below_diagonal = map.isTileSolid(pos + Vec2f(y_ts*4.0f, x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts*4.0f, x_ts));
			if (surface_below || surface_below_diagonal)
			{
				//print("surface_below");
				bounce = true;

				tumbleVec.y = -Maths::Abs(tumbleVec.y)*0.8f;
				newVelY = tumbleVec.y;

				// impact effect variables
				effectAngle = 0;
			}
		}
		if (tumbleVec.y < -1.0f)
		{
			bool surface_above = map.isTileSolid(pos + Vec2f(y_ts, -x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, -x_ts));
			if (surface_above)
			{
				//print("surface_above");
				bounce = true;

				tumbleVec.y = Maths::Abs(tumbleVec.y)*0.8f;
				newVelY = tumbleVec.y;

				// impact effect variables
				effectAngle = 180;				
			}
		}
		if (tumbleVec.x < -1.0f)
		{
			bool surface_left = map.isTileSolid(pos + Vec2f(-x_ts, y_ts - map.tilesize)) || map.isTileSolid(pos + Vec2f(-x_ts, y_ts));
			if (surface_left)
			{
				//print("surface_left");
				bounce = true;

				tumbleVec.x = Maths::Abs(tumbleVec.x)*0.8f;
				newVelX = tumbleVec.x;

				// impact effect variables
				effectAngle = 90;
			}
		}
		if (tumbleVec.x > 1.0f)
		{
			bool surface_right = map.isTileSolid(pos + Vec2f(x_ts, y_ts - map.tilesize)) || map.isTileSolid(pos + Vec2f(x_ts, y_ts));
			if (surface_right)
			{
				//print("surface_right");
				bounce = true;

				tumbleVec.x = -Maths::Abs(tumbleVec.x)*0.8f;
				newVelX = tumbleVec.x;

				// impact effect variables
				effectAngle = 270;
			}
		}
		/*
		if (showTumbleJet && !bounce)	// if tumbling at very high velocity, check for collisions in a different way for safety
		{
			bool surface_forward = map.rayCastSolidNoBlobs(pos, pos + tumbleNorm*7.5f + tumbleVec);	// tumbleNorm compensates for blob radius
			if (surface_forward)
			{
				print("surface_forward");
				bounce = true;

				tumbleVec = getRandomVelocity(0, tumbleVecLen, 360)*0.8f;
				newVelX = tumbleVec.x;
				newVelY = tumbleVec.y;

				effectAngle = tumbleVec.getAngleDegrees();
			}
		}
		*/

		if (bounce)
		{
			statusVars.hitstunTime = 4;
			statusVars.isHitstunned = true;
			if (getNet().isServer())
			{
				statusVars.tumbleVec = tumbleVec;
				
				CBitStream bt;
				bt.write_u8( statusVars.hitstunTime );
				bt.write_bool( statusVars.isHitstunned );
				bt.write_Vec2f( statusVars.tumbleVec );	
				bt.write_f32( effectAngle );

				blob.SendCommand(blob.getCommandID("sync bounce"), bt);
			}

			newVelX = 0;
			newVelY = 0;


		}

		tumbleVec.y += GRAVITY_TUMBLING;

		tumbleVec *= FRICTION_FACTOR_TUMBLING;

		/*
		// after a certain period, let the player regain control if reached an apex
		if ( statusVars.dazeTime <= 0 && Maths::Abs(tumbleVec.y) <= GRAVITY_TUMBLING )
		{
			statusVars.isTumbling = false;
			statusVars.tumbleTime = 0;

			if (getNet().isServer())
				SyncTumbling(blob);
		}
		*/

		// tumble smoke effects
		if (!tumblingFast && getGameTime() % 3 == 0)
			ParticleAnimated("tumblesmoke4.png", pos, Vec2f(0, 0), XORRandom(360), 1.0f, 4, 0.0f, true);
		else if (tumblingFast && getGameTime() % 2 == 0)
			ParticleAnimated("tumblesmoke6.png", pos, Vec2f(0, 0), XORRandom(360), 1.0f, 4, 0.0f, true);

		statusVars.tumbleVec = tumbleVec;
		// print("tumbleVecX: " + tumbleVec.x + " tumbleVecY: " + tumbleVec.y);
	}

	// render tumbling jet sprite if tumbling
	CSpriteLayer@ jet = sprite.getSpriteLayer("tumblejet");
	if (jet !is null)
	{
		jet.SetVisible(showTumbleJet);
		if (showTumbleJet)
		{
			jet.ResetTransform();
			f32 jetRot = -tumbleVec.getAngleDegrees() - blob.getAngleDegrees();
			f32 rotOffset = sprite.isFacingLeft() ? 180.0f : 0.0f;
			jet.RotateBy(jetRot + rotOffset, Vec2f());
			// jet.SetOffset(Vec2f(-16.0f, 0).RotateBy(jetRot));
		}
	}

	// regular gravity
	shape.SetGravityScale(0.0f);
	
	bool fastFalling = statusVars.fastFalling;
	
	if (tumbleTime == 0)	// lower gravity while tumbling
	{
		if ( (down && !onground && !inwater) || fastFalling)
		{
			newVelY = FAST_FALL_SPEED;

			if (fastFalling == false && !inMoveAnimation) 
			{
				statusVars.fastFalling = true;

				ParticleAnimated("sparkle1.png", pos + Vec2f(0, 4.0f), Vec2f(newVelX, newVelY), 0, 0.5f, 2, 0.0f, true);
				sprite.PlaySound("crouch1.ogg", 2.0f);
			}
		}
		else
		{
			f32 gravity = GRAVITY;
			newVelY = Maths::Min(newVelY + GRAVITY, TERMINAL_VEL);
		}
	}

	// stop fast falling if runner has landed
	if ( (onground || inwater) )
	{
		if (fastFalling)
			statusVars.fastFalling = false;

		if (!inMoveAnimation)
			statusVars.fallSpecial = false;
	}

	bool noPhysics = false;
	if (inMoveAnimation)
	{
		MoveAnimation@ moveAnim = statusVars.currMoveAnimation;
		if (moveAnim !is null)
		{
			if (moveAnim.currFrameIndex < moveAnim.moveFrames.length())
			{
				MoveFrame@ currMoveFrame = moveAnim.moveFrames[moveAnim.currFrameIndex];
				noPhysics = currMoveFrame.noPhysics;
			}
		}
	}

	// set final move vector
	if (noPhysics)
	{

	}
	else
	{
		blob.setVelocity( Vec2f(newVelX, newVelY) );
	}
}