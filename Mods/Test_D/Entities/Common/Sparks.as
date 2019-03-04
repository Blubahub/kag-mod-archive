// random sparks particles

namespace Particles
{

    Random _sprk_r;
    void Sparks(Vec2f pos, int amount, f32 speed, SColor color, int lifetime = 20, int lifebonus = 20, f32 grav = 1.0f )
    {
    	for (int i = 0; i < amount; i++)
        {
            Vec2f vel(_sprk_r.NextFloat() * speed, 0);
            vel.RotateBy(_sprk_r.NextFloat() * 360.0f);
            vel.y -= speed * 0.5f;

            CParticle@ p = ParticlePixel( pos, vel, color, true );

            if(p is null) return; //bail if we stop getting particles

            p.gravity.y = grav;

            p.timeout = lifetime + _sprk_r.NextRanged(lifebonus);
            p.scale = 1.0f + _sprk_r.NextFloat();
            
            p.growth = -(f32(p.scale) / (f32(p.timeout) + 1.0f) );

            p.damping = 0.85f;
        }
    }
    
}