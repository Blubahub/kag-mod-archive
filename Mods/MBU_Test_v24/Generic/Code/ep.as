//dripping dripping down the wall, a disgusting mess is this all

void ep(Vec2f pos, bool invisible, Vec2f vel = Vec2f(0,0))
{
	if(getLocalPlayer() is null)return;
	if(!getLocalPlayer().hasTag("death_sight") && invisible)return;

	CParticle @part = makeGibParticle("ep.png", pos, vel, 0, XORRandom(5), Vec2f(6,7), 0.001f, 0, "s.ogg");
	
	if(part !is null){
		part.bounce = 0.0001f;
		part.rotates = false;
		part.damping = 0.95f;
		part.scale = 0.8;
	}
}

void hp(Vec2f pos, bool invisible, Vec2f vel = Vec2f(0,0))
{
	if(getLocalPlayer() is null)return;
	if(!getLocalPlayer().hasTag("blood_sight") && invisible)return;
	
	ParticleAnimated("hp.png", pos, vel+Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
}

void lp(Vec2f pos, bool invisible, Vec2f vel = Vec2f(0,0))
{
	if(getLocalPlayer() is null)return;
	if(!getLocalPlayer().hasTag("life_sight") && invisible)return;
	
	ParticleAnimated("lp.png", pos, vel, 90.0f, 1.0f, 6, -0.0f, true);
}

void ltp(Vec2f pos, Vec2f vel = Vec2f(0,0))
{
	ParticleAnimated("ltp.png", pos, vel, 90.0f, 1.0f, 2, -0.0f, true);
}

void cpr(Vec2f pos, Vec2f vel = Vec2f(0,0))
{
	ParticleAnimated("cpr.png", pos, vel, 90.0f, 1.0f, 5, -0.0f, true);
}