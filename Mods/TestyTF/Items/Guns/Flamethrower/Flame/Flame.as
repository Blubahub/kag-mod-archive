#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.4f);
	this.server_SetTimeToDie(2 + XORRandom(3));
	
	this.getCurrentScript().tickFrequency = 4;
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
}

void onTick(CBlob@ this)
{
	if (getNet().isServer() && this.getTickSinceCreated() > 5) getMap().server_setFireWorldspace(this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), true);
}

void onTick(CSprite@ this)
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher("SmallFire").getFirst(), this.getBlob().getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, 0), 0, 1.0f, 2, 0.25f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (getNet().isServer())
	{
		if (getGameTime() % 2 != 0) return;
	
		if (solid) 
		{
			getMap().server_setFireWorldspace(this.getPosition(), true);
		}
		else if (blob !is null && blob.isCollidable())
		{
			if (this.getTeamNum() != blob.getTeamNum()) this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 0.50f, Hitters::fire, false);
		}
	}
}