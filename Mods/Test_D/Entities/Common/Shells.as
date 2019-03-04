namespace Particles
{

    Random _Shell_r;
    void Shell(Vec2f pos, Vec2f vector, SColor baseColor )
    {
        float range = 10.0f;
        vector.RotateBy(-range*0.5f + _Shell_r.NextFloat() * range);

        CParticle@ p = ParticlePixel( pos, vector, baseColor, true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 60 + _Shell_r.NextRanged(20);
        p.damping = 0.85f;
        p.bounce = 1.0f;
        Particle_SetCollideSound( p, CFileMatcher( "ShellDrop" ).getRandom() );
    }

}