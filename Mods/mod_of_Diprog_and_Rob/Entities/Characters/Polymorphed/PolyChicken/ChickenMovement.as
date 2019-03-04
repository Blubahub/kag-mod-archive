// Runner Movement Walking

#include "RunnerCommon.as"
#include "MakeDustParticle.as";
#include "FallDamageCommon.as";
#include "Knocked.as";

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}
	
	moveVars.jumpFactor *= 0.2f;

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	const bool isknocked = isKnocked(blob);

	const bool is_client = getNet().isClient();

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const f32 vellen = shape.vellen;
	const bool onground = blob.isOnGround() || blob.isOnLadder();

	if (is_client && getGameTime() % 3 == 0)
	{
		const string fallscreamtag = "_fallingscream";
		if (vel.y > 0.2f)
		{
			if (vel.y > BaseFallSpeed() * 1.8f)
			{
				if (!blob.hasTag(fallscreamtag))
				{
					blob.Tag(fallscreamtag);
					Sound::Play("man_scream.ogg", pos);
				}
			}
		}
		else
		{
			blob.Untag(fallscreamtag);
		}

		/* unfortunately, this doesn't work with archer bow draw stuff;
			might need to bind separate sounds cause this solution is much better.

			if(vel.y > BaseFallSpeed() * 1.1f)
			{
				if(!blob.hasTag(fallscreamtag))
				{
					blob.Tag(fallscreamtag);

					CSprite@ sprite = blob.getSprite();

					sprite.SetEmitSoundVolume(1.0f);
					sprite.SetEmitSound( "man_scream.ogg" );
					sprite.SetEmitSoundPaused( false );
					sprite.RewindEmitSound();
				}
			}
		}
		else
		{
			blob.Untag(fallscreamtag);
			CSprite@ sprite = blob.getSprite();

			sprite.SetEmitSoundPaused( true );
		}*/
	}

	if (onground || blob.isInWater())  //also reset when vaulting
	{
		moveVars.walljumped_side = Walljump::NONE;
		moveVars.wallrun_start = pos.y;
		moveVars.wallrun_current = pos.y;
		moveVars.fallCount = -1;
	}

	// ladder - overrides other movement completely
	if (blob.isOnLadder() && !blob.isAttached() && !blob.isOnGround() && !isknocked)
	{
		shape.SetGravityScale(0.0f);
		Vec2f ladderforce;

		if (up)
		{
			ladderforce.y -= 1.0f;
		}

		if (down)
		{
			ladderforce.y += 1.2f;
		}

		if (left)
		{
			ladderforce.x -= 1.0f;
		}

		if (right)
		{
			ladderforce.x += 1.0f;
		}

		blob.AddForce(ladderforce * moveVars.overallScale * 100.0f);
		//damp vel
		Vec2f vel = blob.getVelocity();
		vel *= 0.05f;
		blob.setVelocity(vel);

		moveVars.jumpCount = -1;
		moveVars.fallCount = -1;

		CleanUp(this, blob, moveVars);
		return;
	}

	shape.SetGravityScale(1.0f);
	shape.getVars().onladder = false;

	//swimming - overrides other movement partially
	if (blob.isInWater() && !isknocked)
	{
		CMap@ map = getMap();

		const f32 swimspeed = moveVars.swimspeed;
		const f32 swimforce = moveVars.swimforce;
		const f32 edgespeed = moveVars.swimspeed * moveVars.swimEdgeScale;

		Vec2f waterForce;

		moveVars.jumpCount = 50;

		//up and down
		if (up)
		{
			if (vel.y > -swimspeed)
			{
				if (!map.isInWater(pos + Vec2f(0, -8)))
				{
					waterForce.y -= 0.6f;
				}
				else
				{
					waterForce.y -= 0.8f;
				}
			}

			// more push near ledge
			if (vel.y > -(swimspeed * 3.3))
			{
				if (blob.isOnWall())
				{
					moveVars.jumpCount = 0;

					if (blob.isOnMap())
					{
						waterForce.y -= 2.0f;
					}
					else
					{
						waterForce.y -= 1.5f;
					}
				}
			}
		}

		if (down && vel.y < swimspeed)
		{
			waterForce.y += 1;
		}

		//left and right
		if (left && vel.x > -swimspeed)
		{
			waterForce.x -= 1;
		}

		if (right && vel.x < swimspeed)
		{
			waterForce.x += 1;
		}

		waterForce *= swimforce * moveVars.overallScale;
		blob.AddForce(waterForce);


		if (!blob.isOnGround() && !blob.isOnLadder())
		{
			CleanUp(this, blob, moveVars);
			return;				//done for swimming -----------------------

		}
		else
		{
			moveVars.walkFactor *= 0.2f;
			moveVars.jumpFactor *= 0.5f;
		}
	}

	//otherwise, do normal movement :)

	//jumping

	if (moveVars.jumpFactor > 0.01f && !isknocked)
	{

		if (onground)
		{
			moveVars.jumpCount = 0;
		}
		else
		{
			moveVars.jumpCount++;
		}

		if (up && vel.y > -moveVars.jumpMaxVel)
		{
			moveVars.jumpStart = 0.7f;
			moveVars.jumpMid = 0.2f;
			moveVars.jumpEnd = 0.1f;
			bool crappyjump = true;

			//todo what constitutes a crappy jump? maybe carrying heavy?
			if (crappyjump)
			{
				moveVars.jumpStart *= 0.40f;
				moveVars.jumpMid *= 0.35f;
				moveVars.jumpEnd *= 0.30f;
			}

			Vec2f force = Vec2f(0, 0);
			f32 side = 0.0f;

			if (blob.isFacingLeft() && left)
			{
				side = -1.0f;
			}
			else if (!blob.isFacingLeft() && right)
			{
				side = 1.0f;
			}

			// jump
			if (moveVars.jumpCount <= 0)
			{
				force.y -= 1.5f;
			}
			else if (moveVars.jumpCount < 3)
			{
				force.y -= moveVars.jumpStart;
				//force.x += side * moveVars.jumpMid;
			}
			else if (moveVars.jumpCount < 6)
			{
				force.y -= moveVars.jumpMid;
				//force.x += side * moveVars.jumpEnd;
			}
			else if (moveVars.jumpCount < 8)
			{
				force.y -= moveVars.jumpEnd;
			}

			//if (blob.isOnWall()) {
			//  force.y *= 1.1f;
			//}

			force *= moveVars.jumpFactor * moveVars.overallScale * 60.0f;


			blob.AddForce(force);

			// sound

			if (moveVars.jumpCount == 1 && is_client)
			{
				TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;

				if (blob.getMap().isTileGroundStuff(tile))
				{
					blob.getSprite().PlayRandomSound("/EarthJump");
				}
				else
				{
					blob.getSprite().PlayRandomSound("/StoneJump");
				}
			}
		}
	}

	//walking & stopping

	bool stop = true;
	if (!onground)
	{
		if (isknocked)
			stop = false;
		else if (blob.hasTag("dont stop til ground"))
			stop = false;
	}
	else
	{
		blob.Untag("dont stop til ground");
	}

	bool left_or_right = (left || right);
	{
		// carrying heavy
		CBlob@ carryBlob = blob.getCarriedBlob();
		if (carryBlob !is null)
		{
			if (carryBlob.hasTag("medium weight"))
			{
				moveVars.walkFactor *= 0.8f;
				moveVars.jumpFactor *= 0.8f;
			}
			else if (carryBlob.hasTag("heavy weight"))
			{
				moveVars.walkFactor *= 0.6f;
				moveVars.jumpFactor *= 0.5f;
			}
		}

		bool facingleft = blob.isFacingLeft();
		bool stand = blob.isOnGround() || blob.isOnLadder();
		Vec2f walkDirection;
		const f32 turnaroundspeed = 1.3f;
		const f32 normalspeed = 1.0f;
		const f32 backwardsspeed = 0.8f;

		if (right)
		{
			if (vel.x < -0.1f)
			{
				walkDirection.x += turnaroundspeed;
			}
			else if (facingleft)
			{
				walkDirection.x += backwardsspeed;
			}
			else
			{
				walkDirection.x += normalspeed;
			}
		}

		if (left)
		{
			if (vel.x > 0.1f)
			{
				walkDirection.x -= turnaroundspeed;
			}
			else if (!facingleft)
			{
				walkDirection.x -= backwardsspeed;
			}
			else
			{
				walkDirection.x -= normalspeed;
			}
		}

		f32 force = 1.0f;

		f32 lim = 0.0f;

		{
			if (left_or_right)
			{
				lim = moveVars.walkSpeed;
				if (!onground)
				{
					lim = moveVars.walkSpeedInAir;
				}

				lim *= moveVars.walkFactor * Maths::Abs(walkDirection.x);
			}

			Vec2f stop_force;

			bool greater = vel.x > 0;
			f32 absx = greater ? vel.x : -vel.x;

			if (moveVars.walljumped)
			{
				moveVars.stoppingFactor *= 0.5f;
				moveVars.walkFactor *= 0.6f;

				//hack - fix gliding
				if (vel.y > 0 && blob.hasTag("shielded"))
					moveVars.walkFactor *= 0.6f;
			}

			bool stopped = false;
			if (absx > lim)
			{
				if (stop) //stopping
				{
					stopped = true;
					stop_force.x -= (absx - lim) * (greater ? 1 : -1);

					stop_force.x *= moveVars.overallScale * 30.0f * moveVars.stoppingFactor *
					                (onground ? moveVars.stoppingForce : moveVars.stoppingForceAir);

					if (absx > 3.0f)
					{
						f32 extra = (absx - 3.0f);
						f32 scale = (1.0f / ((1 + extra) * 2));
						stop_force.x *= scale;
					}

					blob.AddForce(stop_force);
				}
			}

			if (!isknocked && ((absx < lim) || left && greater || right && !greater))
			{
				force *= moveVars.walkFactor * moveVars.overallScale * 30.0f;
				if (Maths::Abs(force) > 0.01f)
				{
					blob.AddForce(walkDirection * force);
				}
			}
		}

	}

	//falling count
	if (!onground && vel.y > 0.1f)
	{
		moveVars.fallCount++;
	}
	else
	{
		moveVars.fallCount = 0;
	}

	CleanUp(this, blob, moveVars);
}

//some specific helpers

const f32 offsetheight = -1.2f;
bool canVault(CBlob@ blob, CMap@ map, f32 movingside)
{
	Vec2f pos = blob.getPosition();

	f32 tilesize = map.tilesize;
	if (!map.isTileSolid(Vec2f(pos.x + movingside * tilesize, pos.y + tilesize * (offsetheight))) &&
	        !map.isTileSolid(Vec2f(pos.x + movingside * tilesize, pos.y + tilesize * (offsetheight + 1))) &&
	        map.isTileSolid(Vec2f(pos.x + movingside * tilesize, pos.y + tilesize * (offsetheight + 2))))
	{

		bool hasRayFace = map.rayCastSolid(pos + Vec2f(0, -6), pos + Vec2f(movingside * 12, -6));
		if (hasRayFace)
			return false;

		bool hasRayFeet = map.rayCastSolid(pos + Vec2f(0, 6), pos + Vec2f(movingside * 12, 6));

		if (hasRayFeet)
			return true;

		//TODO: fix flags sync and hitting so we dont have to do this
		{
			return !checkForSolidMapBlob(map, pos + Vec2f(movingside * 12, -6)) &&
			       checkForSolidMapBlob(map, pos + Vec2f(movingside * 12, 6));
		}
	}
	return false;
}

//cleanup all vars here - reset clean slate for next frame

void CleanUp(CMovement@ this, CBlob@ blob, RunnerMoveVars@ moveVars)
{
	//reset all the vars here
	moveVars.jumpFactor = 1.0f;
	moveVars.walkFactor = 1.0f;
	moveVars.stoppingFactor = 1.0f;
	moveVars.wallsliding = false;
	moveVars.canVault = true;
}

//TODO: fix flags sync and hitting so we dont need this
bool checkForSolidMapBlob(CMap@ map, Vec2f pos)
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	@_tempBlob = map.getBlobAtPosition(pos);
	if (_tempBlob !is null && _tempBlob.isCollidable())
	{
		@_tempShape = _tempBlob.getShape();
		if (_tempShape.isStatic())
		{
			if (_tempBlob.getName() == "wooden_platform")
			{
				f32 angle = _tempBlob.getAngleDegrees();
				if (angle > 180)
					angle -= 360;
				angle = Maths::Abs(angle);
				if (angle < 30 || angle > 150)
				{
					return false;
				}
			}

			return true;
		}
	}

	return false;
}
