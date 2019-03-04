//BallThatDoesDamage
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().waterPasses = false;
	this.getShape().SetRotationsAllowed( true );
    this.getSprite().getConsts().accurateLighting = true;
    this.server_SetTimeToDie(60);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{	
	Vec2f vel = this.getVelocity();
	if (vel.x < 1.85f)
	{
		if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	
		if(blob.hasTag("flesh") || blob.hasTag("plant"))
		{
			this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 0.0, Hitters::spikes, true);
			this.server_Die();
		}
		if(solid)
		{
		}
	}
	if (vel.x > 1.85f)
	{
		if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	
		if(blob.hasTag("flesh") || blob.hasTag("plant"))
		{
			this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 10.0, Hitters::spikes, true);
		}
		if(solid)
		{
		}
	}	
}