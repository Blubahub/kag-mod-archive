#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == Hitters::muscles)
	if(XORRandom(8) == 0)
	{
		if (getNet().isServer())
		{
			CBlob @ stick = server_CreateBlob("stick", this.getTeamNum(), this.getPosition()-Vec2f(0,XORRandom(48)));
			stick.setVelocity(Vec2f(XORRandom(8)-4,XORRandom(8)-4));
		}
	}
	
	if (customData != Hitters::saw)
	{
		damage = 0.0f;
	}
	
	if (damage > 0.05f || customData == Hitters::muscles) //sound for all damage
	{
		this.getSprite().PlayRandomSound("TreeChop");
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                0, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}

	return damage;
}
