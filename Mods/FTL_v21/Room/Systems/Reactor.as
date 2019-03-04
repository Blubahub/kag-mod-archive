const Vec2f vent_pos = Vec2f(-10, 12);

void onInit(CBlob@ this)
{
	//this.SetLight(true);
	//this.SetLightRadius(32);
	// this.SetLightColor(SColor(255, 50, 255, 120));
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("/Reactor.ogg");
	this.SetEmitSoundPaused(false);
	this.SetEmitSoundSpeed(1);
	this.SetEmitSoundVolume(0.1f);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u32 time = getGameTime();
	
	blob.SetLightColor(SColor(255, 255, 240, 210));
	
	if (time % 3 == 0)
	{
		makeSteamParticle(blob.getPosition() + vent_pos);
	}
}

void makeSteamParticle(Vec2f pos, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), pos, Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}