#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(0.0f);
		this.server_SetTimeToDie(5.0f);
		this.getCurrentScript().tickFrequency = 10;
	}
	
	if(this.isInWater())this.server_Die();
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
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
		this.getSprite().PlaySound("/OrbExplosion", 1.50f, 1.00f);
		ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
	
	
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 1.0f, Hitters::fire, false);
		if(blob.hasTag("flesh") || blob.hasTag("plant"))this.server_Die();
	}
	if(solid)
	{
		this.getSprite().PlaySound("/OrbExplosion", 1.50f, 1.00f);
		ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
	
		CMap@ map = getMap();
		if (map != null)
		map.server_setFireWorldspace(this.getPosition()-this.getVelocity(), true);
		this.server_Die();
	}
	
}