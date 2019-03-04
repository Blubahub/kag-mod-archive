//============================================
//NOT public interface - used for emission code

#include "ExplosionParticles.as"
#include "Sparks.as"
#include "GameColours.as"

void AddTinyFire(CParticle@ p)
{
    Particles::TinyFires(p.position, 1, Vec2f());
}

void AddFireSmokePuff(CParticle@ p)
{
    Particles::FireSmokePuffs(p.position, 8, p.velocity * 0.5f);
    Particles::TinyFires(p.position, 10, p.velocity);
}

void AddTinySmoke(CParticle@ p)
{
    Particles::TinySmokes(p.position, 1, Vec2f());
}

void AddSmokePuff(CParticle@ p)
{
    Particles::SmokePuffs(p.position, 8, p.velocity * 0.5f);
    Particles::TinySmokes(p.position, 10, p.velocity);
}

Random _r_fw(Time());

void AddSpark(CParticle@ p)
{
    Particles::Sparks(p.position, 2, 5.0f, SColor(_r_fw.Next() | 0xff808080), 20, 60, 0.5f );
    p.gravity *= 0.5f;
    p.velocity.y += -1.5f;
    p.velocity.x += Maths::Sin(getGameTime() * 0.3f) * 3.0f;
}

void FireworkPuff(CParticle@ p)
{
	Sound::Play(Sound::getFileVariation("FireworkExplode?", 1, 3), p.position );

	f32 scale = 0.7f;

	Particles::Sparks(p.position, 50, 40.0f * scale, SColor(Colours::YELLOW), 40, 60, 0.5f );
	Particles::Sparks(p.position, 40, 20.0f * scale, SColor(Colours::RED), 50, 60, 0.3f );

	//circle
	for(u32 i = 0; i < 10; i++)
	{
		Vec2f r(10, 0);
		r.RotateBy(_r_fw.NextFloat() * 360.0f);
		Particles::MicroAirSpecs(p.position + r, 3, r * scale, 1.0f * scale);
		Particles::DirectionalSparks(p.position + r, 1, r * scale * 3.0f, 5.0f * scale);
	}

	Particles::DirectionalSparks(p.position, 5, Vec2f(), 30.0f * scale);
}

//NOT public interface - used for emission code
//============================================
