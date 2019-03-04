#include "Hitters.as";

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		//this.getShape().SetGravityScale(0.5f);

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.hasTag("flesh") && !blob.hasTag("plant"))return false;
	if(blob.getTeamNum() != this.getTeamNum())return true;
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	if(blob.hasTag("flesh") || blob.hasTag("plant")){
		this.server_Hit(blob, blob.getPosition()-this.getVelocity(), this.getVelocity()*-0.5f, 0.5f, Hitters::boulder, false);
		this.server_Die();
	}
	if(solid){
		this.server_Die();
	}
	
}