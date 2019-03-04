// Shield hit - make sure to set up the shield vars elsewhere

#include "ShieldCommon.as";

#include "ParticleSparks.as";

#include "HittersNew.as";

bool canBlockThisType(u8 type) // this function needs to use a tag on the hitterBlob, like ("bypass shield")
{
	return type == HittersNew::stomp ||
	       type == HittersNew::builder ||
	       type == HittersNew::sword ||
	       type == HittersNew::hammer ||
	       type == HittersNew::shield ||
	       type == HittersNew::arrow ||
	       type == HittersNew::bite ||
	       type == HittersNew::stab ||
	       isExplosionHitterNew(type);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("dead") ||
	        !this.hasTag("shielded") ||
	        !canBlockThisType(customData) ||
	        this is hitterBlob)
	{
		//print("dead " + this.hasTag("dead") + "shielded " + this.hasTag("shielded") + "cant " + canBlockThisType(customData));
		print("wasn't shielded");
		return damage;
	}

	//no shield when stunned
	if (this.get_u8("knocked") > 0)
	{
		print("was knocked, so no shield");
		return damage;
	}

	if (blockAttack(this, velocity, 0.0f))
	{
		if (isExplosionHitterNew(customData)) //bomb jump
		{
			Vec2f vel = this.getVelocity();
			this.setVelocity(Vec2f(0.0f, Maths::Min(0.0f, vel.y)));

			Vec2f bombforce = Vec2f(0.0f, ((velocity.y > 0) ? 0.7f : -1.3f));

			bombforce.Normalize();
			bombforce *= 2.0f * Maths::Sqrt(damage) * this.getMass();
			bombforce.y -= 2;

			if (!this.isOnGround() && !this.isOnLadder())
			{
				if (this.isFacingLeft() && vel.x > 0)
				{
					bombforce.x += 50;
					bombforce.y -= 80;
				}
				else if (!this.isFacingLeft() && vel.x < 0)
				{
					bombforce.x -= 50;
					bombforce.y -= 80;
				}
			}
			else if (this.isFacingLeft() && vel.x > 0)
			{
				bombforce.x += 5;
			}
			else if (!this.isFacingLeft() && vel.x < 0)
			{
				bombforce.x -= 5;
			}

			this.AddForce(bombforce);
			this.Tag("dont stop til ground");

		}
		else if (exceedsShieldBreakForce(this, damage) && customData != HittersNew::arrow)
		{
			knockShieldDown(this);
			this.Tag("force_knock");
		}

		Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", worldPoint);
		const f32 vellen = velocity.Length();
		sparks(worldPoint, -velocity.Angle(), Maths::Max(vellen * 0.05f, damage));
		return 0.0f;
	}
	print("had shield, but didn't block anything");
	return damage; //no block, damage goes through
}
