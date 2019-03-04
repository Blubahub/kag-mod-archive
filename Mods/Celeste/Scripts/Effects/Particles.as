void DashEffectTemp(Vec2f pos)
{
	CParticle@ this = ParticleAnimated("DashEffectTest.png", pos, Vec2f(0,0), 0, 1.0f, 50, 0.0f, true);
	if(this !is null)
	{
		this.Z = -10;
	}
}
