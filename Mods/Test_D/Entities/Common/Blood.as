// random sparks particles

#include "GameColours.as"
#include "Sparks.as"

namespace Particles
{

    void Blood(Vec2f pos, int amount, f32 speed )
    {
    	Particles::Sparks( pos + Vec2f(-4.0f + XORRandom(8), -4.0f + XORRandom(8)), amount, speed, Colours::RED, 200 );
    }

    void WaterBlood(Vec2f pos, int amount, f32 speed )
    {
    	Particles::Sparks( pos + Vec2f(-4.0f + XORRandom(8), -4.0f + XORRandom(8)), amount, speed, Colours::RED, 200, 50, 0.01f);
    }
    
}