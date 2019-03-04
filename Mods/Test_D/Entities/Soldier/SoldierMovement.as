#include "SoldierCommon.as"
#include "MapCommon.as"

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);
	Vec2f force;

	if (data.dead && data.healTime > 0){
		data.stunned = true;
	}

	if (getRules().hasTag("pause movement"))
	{
		data.vel.x = 0;
		this.setVelocity(data.vel);
		Soldier::SetCrouching(this, data, data.canCrouch && data.allowCrouch && (data.crouch || data.lockCrouch > 0));
		return;
	}

	if (data.stunned)
	{
		if (!data.inWater)
		{
			this.getShape().SetGravityScale(1.0f);
		}
		return;
	}

	data.canJump = data.jumpCounter == 0 &&
	               (data.onGround || data.inWater || data.ledgeClimb || data.oldLedgeClimb || this.wasOnLadder()) &&
	               (!data.crouching || data.dead) && !data.crosshair && data.allowJump;

	if (data.dead)
	{
		//fix flying :)
		data.ledgeClimb = false;
		data.oldLedgeClimb = false;

		Soldier::SetCrouching(this, data, true);
		if (data.gametime % 10 < 5)
		{
			if (data.left)
			{
				force.x -= Soldier::walkSpeed * 0.71f;
			}
			if (data.right)
			{
				force.x += Soldier::walkSpeed * 0.71f;
			}
		}

		if (data.jump && data.canJump)
		{
			data.jumpCounter = 1;
		}

		if (data.jump && data.onWall && data.vel.y > 0.0f) //climb wall
		{
			data.jumpCounter = 3;
		}

		if (data.jumpCounter > 0)
		{
			data.vel.y = (-Soldier::jumpSpeed / Maths::Sqrt(float(data.jumpCounter) / 0.5f)) * 1.61f * (data.inWater ? 0.5f : 1.0f); // short jump
			data.jumpCounter++;
			if (data.jumpCounter > 6)
			{
				data.jumpCounter = 0;
			}
		}

		data.vel.x -= data.vel.x * 0.4f;
		data.vel += force;
	}
	else
	{
		Soldier::SetCrouching(this, data, data.canCrouch && data.allowCrouch && (data.crouch || data.lockCrouch > 0));

		f32 fa_sign = (data.facingLeft ? -1 : 1);

		f32 ahead_distance = data.map.tilesize * 1.2f;

		f32 foot_offset = 3.0f;
		f32 head_offset = foot_offset - data.map.tilesize;
		f32 above_offset = head_offset - data.map.tilesize;

		//collect the tiles ahead of time
		u8 head_tile = data.map.getTile(data.pos + Vec2f(fa_sign * ahead_distance, head_offset)).type;
		u8 above_tile = data.map.getTile(data.pos + Vec2f(fa_sign * ahead_distance, above_offset)).type;
		u8 foot_tile = data.map.getTile(data.pos + Vec2f(fa_sign * ahead_distance, foot_offset)).type;

		//ensure we're not reading out of bounds
		f32 readx = data.pos.x + fa_sign * ahead_distance;
		if (readx < 0 || readx > data.map.tilemapwidth * data.map.tilesize)
		{
			data.oldLedgeClimb = data.ledgeClimb;
			data.canLedgeClimb = false;
		}
		else
		{
			data.oldLedgeClimb = data.ledgeClimb;
			data.canLedgeClimb = !data.crosshair && !data.crouching && !data.crouch &&
			                     !TWMap::isTileTypeSolid(above_tile) &&
			                     !TWMap::isTileTypeSolid(head_tile) &&
			                     (TWMap::canGroundVault(foot_tile) || !data.onGround && TWMap::isTileTypeSolid(foot_tile));
		}
		data.ledgeClimb = data.canLedgeClimb &&
		                  ((data.left || data.right) && (data.vel.y < 1.5f || data.jump)) &&
		                  !(data.crouch || data.down);

		data.canWalk = !data.crosshair && !data.crouching && data.allowWalk;
		data.oldSliding = data.sliding;
		data.sliding = !data.canWalk && (data.left || data.right) && Maths::Abs(data.vel.x) > 0.95f && data.allowCrouch;

		if (data.ledgeClimb)
		{
			if ((data.left && !data.right && data.facingLeft) ||
			        (data.right && !data.left && !data.facingLeft))
			{
				data.vel.y = -Soldier::ledgeClimbForce;
				data.vel.x = Soldier::ledgeClimbForce * fa_sign;
				data.jumpCounter = 0;
				data.allowJump = true;
			}
		}
		//stopped climbing, slow (so we land sooner)
		else if (data.oldLedgeClimb)
		{
			data.vel.y *= 0.5f;
		}

		// jump

		if (data.jump && data.canJump)
		{
			data.jumpCounter = 1;
			data.allowJump = false; // no rejump
		}

		if (data.jumpCounter > 0)
		{
			data.jumpCounter++;

			// finish early
			if (data.jumpCounter > 5 && !data.jump)
			{
				data.jumpCounter = 0;
				if (!data.onLadder)
				{
					data.sprite.PlayRandomSound("BreathSmall", 1.0f, data.pitch);
				}
			}
			else if (data.jumpCounter <= data.jumpMax)
			{
				if (data.jumpCounter > 5)
					data.vel.y = (-Soldier::jumpSpeed / Maths::Sqrt(Maths::Sqrt(float(data.jumpCounter) / 5.0f))) * (data.inWater ? 0.5f : 1.0f) * data.jumpSpeedModifier; // long jump
				else
					data.vel.y = (-Soldier::jumpSpeed / Maths::Sqrt(float(data.jumpCounter) / 2.0f)) * (data.inWater ? 0.5f : 1.0f) * data.jumpSpeedModifier; // short jump
			}
			else
			{
				data.jumpCounter = 0;
			}

			if (data.jumpCounter == 6 && data.jump && !data.onLadder)
			{
				data.sprite.PlayRandomSound("BreathLoud", 0.65f, data.pitch);
			}
		}

		if (data.canWalk)
		{
			if (data.crouching)
			{
				data.walkSpeedModifier *= 0.66f;
			}

			if (data.left)
			{
				force.x -= data.walkSpeedModifier * Soldier::walkSpeed;
			}
			if (data.right)
			{
				force.x += data.walkSpeedModifier * Soldier::walkSpeed;
			}
		}

		// slide

		if (!data.oldSliding && data.sliding)
		{
			data.vel.x += fa_sign * 0.75f;
		}

		// damp

		data.vel.x -= data.vel.x * ((data.sliding && Maths::Abs(data.vel.x) < 10) ? 0.05f : 0.5f);
		data.vel += force;
	}

	// no rejump
	if (((data.vel.y > -0.1f || data.onLadder) && !data.jump) || (this.getBrain().isActive()))
	{
		data.allowJump = true;
	}

	// ladder

	if (data.onLadder && !data.inWater)
	{
		//jumping off ladders
		if (data.left || data.right)
		{
			data.allowJump = true;
		}

		if (!data.onGround)
		{
			data.vel *= 0.25f;
		}
		const f32 mod = data.dead ? 0.5f : 1.0f;
		if (!data.crosshair)
		{
			if (data.jump || data.up)
			{
				data.vel.y -= 1.2f * Soldier::ladderSpeed * mod;
			}
			if (data.crouch || data.down)
			{
				data.vel.y += 2.3f * Soldier::ladderSpeed * mod;
			}
			if (!data.onGround)
			{
				if (data.left)
				{
					data.vel.x -= 1.0f * Soldier::ladderSpeed * mod;
				}
				if (data.right)
				{
					data.vel.x += 1.0f * Soldier::ladderSpeed * mod;
				}
			}
		}
	}

	if (!data.inWater)
	{
		this.getShape().SetGravityScale(data.onLadder ? 0.0f : 1.0f);
	}
	else
	{
		if (!data.crosshair)
		{
			if (data.crouch || data.down)
			{
				data.vel.y += Soldier::ladderSpeed * 0.25f;
			}

			if (data.jump || data.up)
			{
				data.vel.y -= Soldier::ladderSpeed * 0.25f;
			}
		}

		//data.canJump = true;
	}

	// finally set vel

	this.setVelocity(data.vel);
}
