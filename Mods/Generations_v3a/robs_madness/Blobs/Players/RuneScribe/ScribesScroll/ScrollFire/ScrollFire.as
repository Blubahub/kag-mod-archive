#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 255, 0));
	
	this.getShape().SetGravityScale(0.0f);
	this.server_SetTimeToDie(10.0f);
	
	this.getSprite().SetVisible(false);
	
	this.set_f32("damage",0.0f);
	
	this.Tag("can_dispell");
}

void onTick(CBlob@ this)
{

	this.getSprite().SetVisible(true);
	
	if(this.isInWater())this.server_Die();
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
	
	if(getNet().isClient()){
		if(this.get_f32("damage") < 2.5f)this.getSprite().SetFrame(0);
		else if(this.get_f32("damage") < 5.0f)this.getSprite().SetFrame(1);
		else if(this.get_f32("damage") < 7.5f)this.getSprite().SetFrame(2);
		else this.getSprite().SetFrame(3);
	}
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

		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, this.get_f32("damage"), Hitters::fire, false);
		this.server_Die();
	}
	if(solid)
	{
		ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
		this.server_Die();
	}
	
}

void onDie( CBlob@ this)
{
	CMap@ map = getMap();
	if (map != null)
	map.server_setFireWorldspace(this.getPosition()-this.getVelocity(), true);
}