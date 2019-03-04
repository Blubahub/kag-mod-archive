#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
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
	if(!blob.hasTag("flesh"))return false;
	if(blob.getTeamNum() != this.getTeamNum())return true;
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	if(blob.hasTag("flesh")){
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 1.0f, Hitters::suddengib, false);
		if(blob.hasTag("flesh"))this.server_Die();
	}
	if(solid){
		this.server_Die();
	}
	
}