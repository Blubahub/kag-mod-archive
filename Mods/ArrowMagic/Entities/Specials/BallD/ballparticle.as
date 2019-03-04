void BallTrailBlue(Vec2f pos, Vec2f vel)
{
	CParticle@ this = ParticlePixelUnlimited(pos, Vec2f(0,0) , SColor(100 + XORRandom(255), 0 , 0 , 0 + XORRandom(255)), true);
	if(this !is null)
	{
		this.gravity = Vec2f(0,0);
		this.rotates = true;
		this.rotation = Vec2f(2,2);
	}
}

void BallTrailRed(Vec2f pos, Vec2f vel)
{
	CParticle@ this = ParticlePixelUnlimited(pos, Vec2f(0,0) , SColor(100 + XORRandom(255), 0 + XORRandom(255) , 0 , 0), true);
	if(this !is null)
	{
		this.gravity = Vec2f(0,0);
		this.rotates = true;
		this.rotation = Vec2f(2,2);
	}
}