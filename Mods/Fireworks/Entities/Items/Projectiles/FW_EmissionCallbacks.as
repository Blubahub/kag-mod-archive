
#include "FW_Explosion.as"
#include "GameColours.as"

void AddTinyFire(CParticle@ p)
{
    Particles::TinyFires(p.position, 1, Vec2f());
}

void AddTinySmoke(CParticle@ p)
{
    Particles::TinySmokes(p.position, 1, Vec2f());
}