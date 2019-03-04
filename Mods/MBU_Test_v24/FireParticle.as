//spawning a generic fire particle

void makeFireParticle(Vec2f pos, int smokeRandom = 1)
{
	string texture = "SmallFire1.png";

	switch (XORRandom(XORRandom(smokeRandom) == 0 ? 4 : 2))
	{
		case 0: texture = "Entities/Effects/Sprites/SmallFire1.png"; break;

		case 1: texture = "Entities/Effects/Sprites/SmallFire2.png"; break;

		case 2: texture = "Entities/Effects/Sprites/SmallSmoke1.png"; break;

		case 3: texture = "Entities/Effects/Sprites/SmallSmoke2.png"; break;
	}

	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 5, -0.1, true);
}

void makeSmokeParticle(Vec2f pos, f32 gravity = -0.06f)
{
	string texture = "SmallSmoke1.png";

	switch (XORRandom(2))
	{
		case 0: texture = "Entities/Effects/Sprites/SmallSmoke1.png"; break;

		case 1: texture = "Entities/Effects/Sprites/SmallSmoke2.png"; break;
	}

	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 5, gravity, true);
}

CParticle@ makeFireParticleOnly(Vec2f pos)
{
	string texture = "SmallFire1.png";

	switch (XORRandom(2))
	{
		case 0: texture = "Entities/Effects/Sprites/SmallFire1.png"; break;

		case 1: texture = "Entities/Effects/Sprites/SmallFire2.png"; break;
	}

	CParticle @ p = ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 5, -0.1, true);
	
	if(p is null)return null;
	
	return p;
}

void makeFireParticleStill(Vec2f pos)
{
	string texture = "SmallFire1.png";

	switch (XORRandom(2))
	{
		case 0: texture = "Entities/Effects/Sprites/SmallFire1.png"; break;

		case 1: texture = "Entities/Effects/Sprites/SmallFire2.png"; break;
	}

	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 5, 0, true);
}