// random water particles

namespace Particles
{

    Random _water_r(1248715);

    //ugh, copied from ExplosionParticles
    Vec2f getRandomExtraWaterVel(Vec2f vel, f32 speed, f32 minfac = 0.25f)
    {
        Vec2f myVel( (minfac + _water_r.NextFloat()*(1.0f-minfac)) * speed, 0);
        myVel.RotateBy(_water_r.NextFloat() * 360.0f);

        myVel += vel;

        return myVel;
    }

    void WaterSplash(Vec2f pos, int amount, Vec2f vel)
    {
        for (int j = 0; j < amount; j++)
        {
            Vec2f myVel = getRandomExtraWaterVel(vel, 1.0f);
            myVel *= 0.2f;
            myVel.y *= 0.3f;

            CParticle@ p = ParticleAnimated( "Splash.png",
                                             pos,
                                             myVel,
                                             0.0f,
                                             1.0f,
                                             2 + _water_r.NextRanged(3), //animtime
                                             -0.1f,
                                             true );

            if(p is null) return; //bail if we stop getting particles

            p.damping = 0.85f;

            p.deadeffect = 255;

            p.collides = false;
            p.Z = 1000.0f;
            p.slide = 1.0f;
            p.bounce = 1.0f;

            p.gravity.y = 0.0f;

            p.width = p.height = 2.0f;
        }
    }

    void BubbleSmall(Vec2f pos, int amount, Vec2f vel)
    {
        for (int j = 0; j < amount; j++)
        {
            Vec2f myVel = getRandomExtraWaterVel(vel, 1.0f);

            CParticle@ p = ParticleAnimated( "SmallBubble"+(1+_water_r.NextRanged(1))+".png",
                                             pos,
                                             myVel,
                                             0.0f,
                                             1.0f,
                                             3 + _water_r.NextRanged(3), //animtime
                                             -0.2f,
                                             true );

            if(p is null) return; //bail if we stop getting particles

            p.damping = 0.85f;

            p.deadeffect = 255;

            p.collides = true;
            p.Z = 1000.0f;
            p.slide = 1.0f;
            p.bounce = 1.0f;

            p.width = p.height = 2.0f;
        }
    }

};