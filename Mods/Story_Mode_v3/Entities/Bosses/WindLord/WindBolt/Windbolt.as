#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().bullet = true;
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(0.0f);
		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
	
	if(this.isInWater())this.server_Die();
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.getTeamNum() != this.getTeamNum())return true;
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	if(blob.hasTag("flesh")){
		this.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 0.5f, Hitters::suddengib, false);
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null)
				if(b.hasTag("flesh") || b.canBePickedUp(b)){
					Vec2f projectileVel = b.getPosition()- this.getPosition();
					projectileVel.Normalize();
					b.setVelocity(projectileVel*-8);
				}
			}
		}
		this.server_Die();
	}
	if(solid){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null)
				if(b.hasTag("flesh") || b.canBePickedUp(b)){
					Vec2f projectileVel = b.getPosition()- this.getPosition();
					projectileVel.Normalize();
					b.setVelocity(projectileVel*12);
					this.server_Hit(b, b.getPosition(), Vec2f(0,0), 0.1f, Hitters::suddengib, false);
				}
			}
		}
		this.server_Die();
	}
	
}