#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	//this.getShape().getConsts().bullet = true;
	this.getShape().SetGravityScale(0.0f);
	this.server_SetTimeToDie(20.0f);
	this.getShape().getConsts().mapCollisions = false;
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 96.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("flesh") && b.getTeamNum() != this.getTeamNum() && b.hasTag("player"))
			{
				Vec2f Vel = b.getPosition()-this.getPosition();
				Vel.Normalize();
				this.AddForce(Vel);
			}
		}
	}
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
//	if(blob.getShape().isStatic())return true;
//	if(!blob.hasTag("flesh"))return false;
//	if(blob.getTeamNum() != this.getTeamNum())return true;
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	if(blob.hasTag("flesh")){
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 0.5f, Hitters::suddengib, false);
	}
}