#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
	
	this.getShape().SetGravityScale(0.0f);
	this.server_SetTimeToDie(0.5f);
	
	this.getSprite().SetVisible(false);
}

void onTick(CBlob@ this)
{

	this.getSprite().SetVisible(true);
	
	if(this.isInWater())this.server_Die();
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
	
	if(XORRandom(5) == 0)ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition()+Vec2f(XORRandom(5)-3,XORRandom(5)-3), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.getShape().isStatic())return true;
	if(!blob.hasTag("flesh") && !blob.hasTag("plant"))return false;
	if(blob.getTeamNum() != this.getTeamNum())return true; 
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	
	if(blob.hasTag("flesh") || blob.hasTag("plant"))
	{
		ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);

		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 0.05f, Hitters::fire, false);
		this.server_Die();
	}
	if(solid)
	{
		ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
		
		//CMap@ map = getMap();
		//if (map != null)
		//map.server_setFireWorldspace(this.getPosition()-this.getVelocity(), true);
		
		this.server_Die();
	}
	
}