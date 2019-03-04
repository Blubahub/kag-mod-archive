void Particle(Vec2f at, f32 angle, f32 damage, int R, int G, int B)
{	
	for (int i = 0; i < 5; i++)
	{
		if (damage > 2.0) damage = 2.0;
		Vec2f vel = getRandomVelocity(angle, damage * 1.5f, 90.0f);
		vel.y = -Maths::Abs( vel.y ) + Maths::Abs(vel.x)/3.0f - 2.0f - float(XORRandom(100))/100.0f;
		ParticlePixel( at, vel, SColor( 255, R, G, B), false );
	}
}

void DieParticle(Vec2f at, int R, int G, int B)
{
	
	for (int i = 0; i < 30; i++)
	{
		Vec2f vel = getRandomVelocity(-180, 0.5 * 1.3f, 360.0f);
		vel.y = -Maths::Abs( vel.y ) + Maths::Abs(vel.x)/3.0f - 2.0f - float(XORRandom(100))/100.0f;
		ParticlePixel( at, vel, SColor( 255, R, G, B), false );
	}
}