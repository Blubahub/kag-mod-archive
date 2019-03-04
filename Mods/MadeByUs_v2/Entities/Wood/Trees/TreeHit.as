#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(XORRandom(2) == 0)
	{
		if (getNet().isServer())
		{
			CBlob @ stick = server_CreateBlob("stick", this.getTeamNum(), this.getPosition()-Vec2f(0,XORRandom(48)));
			stick.setVelocity(Vec2f(XORRandom(8)-4,XORRandom(8)-4));
		}
	}
	if (damage > 0.05f) //sound for all damage
	{
		this.getSprite().PlayRandomSound("TreeChop");
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                0, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}

	if (customData == Hitters::sword)
	{
		damage *= 0.5f;
	}
	
	if (customData == Hitters::muscles)
	{
		damage *= 0.0f;
	}

	return damage;
}
