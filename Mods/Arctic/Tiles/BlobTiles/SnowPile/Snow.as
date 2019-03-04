#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.Tag("snow");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.05f) //sound for all damage
	{
		if (hitterBlob !is this)
		{
			this.getSprite().PlaySound("cut_grass", 1.0f, 0.7f);
		}
		
		SColor[] colors = {	SColor(255, 255, 255, 255),
							SColor(255, 239, 239, 239),
							SColor(255, 206, 206, 206)};
		
		int amount = 3 + XORRandom(3);
		for (int i = 0; i < amount; i++)
		{
			Vec2f temp = this.getPosition();
			switch(XORRandom(4))
			{
				case 0:
					temp += Vec2f(4, 0);
					break;
				case 1:
					temp += Vec2f(8, 4);
					break;
				case 2:
					temp += Vec2f(0, 4);
					break;
				case 3:
					temp += Vec2f(4, 8);
					break;
			}
			Vec2f vel = getRandomVelocity( 0.6f, 1.2f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-float(XORRandom(100))/100.0f;

			ParticlePixel(temp, vel, colors[XORRandom(3)], false);
			makeGibParticle("SnowParts.png", temp, vel, 0, XORRandom(4)+1, Vec2f(4.0f, 4.0f), 2.0f, 1, "bone_fall2.ogg");
		}
	}

	return damage;
}


void onGib(CSprite@ this)
{
	this.PlaySound("cut_grass", 1.0f, 0.7f);
}