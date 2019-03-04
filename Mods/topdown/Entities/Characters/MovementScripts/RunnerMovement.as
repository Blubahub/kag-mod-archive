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
/*
	if(blob.hasTag("NPC"))
	{
		moveVars.walkFactor *= 0.35f;
		moveVars.jumpFactor *= 0.5f;
		
	}*/
	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	
	const bool isknocked = isKnocked(blob);
	

	if (!isknocked)
	{/*
		if (blob.getShape() !is null)
		{
			blob.getShape().SetGravityScale(0.0f);
		} */
		Vec2f flightforce;

		if (up)
		{
			flightforce.y -= 2.0f;
		}

		if (down)
		{
			flightforce.y += 2.0f;
		}

		if (left)
		{
			flightforce.x -= 2.0f;
		}

		if (right)
		{
			flightforce.x += 2.0f;
		}

			

		blob.AddForce(flightforce * moveVars.overallScale * 100.0f);
		//damp vel

		Vec2f vel = blob.getVelocity();
		vel *= 0.25f;
		blob.setVelocity(vel);

		moveVars.jumpCount = -1;
		moveVars.fallCount = -1;

		CleanUp(this, blob, moveVars);
		return;
	}
			
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
