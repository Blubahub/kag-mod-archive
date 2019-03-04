
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
	
	this.getSprite().setRenderStyle(RenderStyle::normal);
	this.getSprite().SetLighting(false);
	
	this.set_u16("created",getGameTime());
	
	this.server_SetTimeToDie(10);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	this.getSprite().SetVisible(!(getLocalPlayer() is null || !getLocalPlayer().hasTag("blood_sight")));
	this.getSprite().SetZ(1000.0f);
	
	if(!(getLocalPlayer() is null || !getLocalPlayer().hasTag("blood_sight")))
	if(XORRandom(10) == 0)ParticleBlood(this.getPosition()+Vec2f(XORRandom(5)-2,XORRandom(5)-2), this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1), SColor(255, 126, 0, 0));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}
