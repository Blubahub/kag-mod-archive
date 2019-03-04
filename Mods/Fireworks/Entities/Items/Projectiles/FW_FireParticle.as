
void makeFireParticle(Vec2f pos)
{
	string texture;
	texture = "Entities/Items/Projectiles/particle_fire_tiny.png";

	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 3, 0.01, true);
}

void makeSmokeParticle(Vec2f pos, f32 gravity = 0.0f)
{
	string texture;
	texture = "Entities/Items/Projectiles/particle_firesmoke.png";

	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 3, gravity, true);
}