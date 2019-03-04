void mapSparks(Vec2f at, f32 angle, f32 damage)
{
	int amount = 10 + XORRandom(5);
	for (int i = 0; i < amount; i++)
	{
		Vec2f vel = Vec2f(-4+XORRandom(8), -4+XORRandom(8));
		ParticlePixel(at, vel, SColor(255, 175+XORRandom(80), 175+XORRandom(80), 175+XORRandom(80)), true);	
	}
}
