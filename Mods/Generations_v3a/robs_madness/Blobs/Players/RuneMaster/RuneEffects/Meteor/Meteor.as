#include "/Entities/Common/Attacks/Hitters.as";
#include "BombCommon.as";


void onInit(CBlob @ this)
{
	this.server_setTeamNum(-1);
	this.Tag("medium weight");

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	Sound::Play("FireRoarQuiet.ogg");
}

void onTick(CBlob@ this)
{
	for(int i = 0; i < 5; i += 1){
		if(XORRandom(2) == 0)makeSteamParticle(this, Vec2f(), "SmallSmoke" + (1 + XORRandom(2)),this.getPosition());
		else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(), "SmallFire" + (1 + XORRandom(2)),this.getPosition());
		else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(), "SmallExplosion" + (1 + XORRandom(3)),this.getPosition());
		else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(), "Explosion.png",this.getPosition());
		else makeSteamParticle(this, Vec2f(), "LargeSmoke.png",this.getPosition());
	}
	
	ShakeScreen(300, 300, this.getPosition());
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam", Vec2f pos = Vec2f(0,0))
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), pos + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid)
	{
		SetupBomb(this, 2, 64.0f, 8.0f, 48.0f, 1.0f, true);
		this.getSprite().SetEmitSoundPaused(true);
		SetScreenFlash(100, 255, 255, 255);
		Sound::Play("FireRoar.ogg");
		this.server_Die();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

//sprite

void onInit(CSprite@ this)
{
	this.animation.frame = (this.getBlob().getNetworkID() % 4);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
