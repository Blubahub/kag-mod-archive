#include "Hitters.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.05f) //sound for all damage
	{
		if (hitterBlob !is this)
		{
			this.getSprite().PlayRandomSound("/BodyGibFall", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
		}

    	//makeGibParticle("Entities/Items/BananaGibs.png", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), XORRandom(4), 0, Vec2f(8, 8), 0.01f, 0, "/BodyGibFall", 0);
	}

	return damage;
}


void onGib(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 1.0f;
	CParticle@ p1 = makeGibParticle("Entities/Items/BananaGibs.png", pos, vel + getRandomVelocity(90, 1.8f, 80), 0, 0, Vec2f(10, 10), 2.0f, 20, "/BodyGibFall", 0);
	CParticle@ p2 = makeGibParticle("Entities/Items/BananaGibs.png", pos, vel + getRandomVelocity(90, 2, 80), 1, 0, Vec2f(10, 10), 2.0f, 20, "/BodyGibFall", 0);
	CParticle@ p3 = makeGibParticle("Entities/Items/BananaGibs.png", pos, vel + getRandomVelocity(90, 2.2f, 80), 2, 0, Vec2f(10, 10), 2.0f, 0, "/BodyGibFall", 0);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid)
	{
		return;
	}

	f32 vellen = this.getShape().vellen;
	// sound
	const f32 soundbase = 2.5f;
	const f32 sounddampen = soundbase * 2.0f;

	if (vellen > soundbase)
	{
		f32 volume = Maths::Min(1.25f, Maths::Max(0.2f, (vellen - soundbase) / soundbase));
        this.getSprite().PlayRandomSound("/BodyGibFall", volume);
	}

	// damage
	if (!this.hasTag("ignore fall"))
	{
		const f32 base = 7.0f;
		const f32 ramp = 1.2f;

		if (getNet().isServer() && vellen > base) // server only
		{
			if (vellen > base * ramp)
			{
				f32 damage = 0.0f;

				if (vellen < base * Maths::Pow(ramp, 1))
				{
					damage = 0.5f;
				}
				else if (vellen < base * Maths::Pow(ramp, 2))
				{
					damage = 1.0f;
				}
				else if (vellen < base * Maths::Pow(ramp, 3))
				{
					damage = 2.0f;
				}
				else if (vellen < base * Maths::Pow(ramp, 3))
				{
					damage = 3.0f;
				}
				else //very dead
				{
					damage = 100.0f;
				}

				// check if we aren't touching a trampoline
				CBlob@[] overlapping;

				if (this.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ b = overlapping[i];

						if (b.hasTag("no falldamage"))
						{
							return;
						}
					}
				}

				this.server_Hit(this, point1, normal, damage, Hitters::fall);
			}
		}
	}
}
