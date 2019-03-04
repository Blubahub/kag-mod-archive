void ParticleTest(Vec2f pos)
{
    CParticle@ this = ParticleAnimated("Test4.png", pos, Vec2f(0,0), 3.0f, 3.0f, 40, 0.0f, true);
    if(this !is null)
    {
        this.Z = -10; //background, will it overlap player (not with this number it wont)
        this.gravity = Vec2f(0,0);
    } 
}