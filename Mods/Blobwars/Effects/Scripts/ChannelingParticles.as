void FireballChannel(Vec2f pos)
{
	CParticle@ this = ParticleAnimated("fireball_channel.png", pos, Vec2f(0,0), 1.0f, 1.0f, 5, 0.0f, true);
	if(this !is null)
	{
		this.Z = 10;
	}
}

void CoolEffect(Vec2f pos, Vec2f vel, SColor colour)
{
	CParticle@ this = ParticlePixelUnlimited(pos, vel, colour, true);
	if(this !is null)
	{
		this.Z = 10;
	}
}
