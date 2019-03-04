#include "Hitters.as";

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
	
	this.Tag("gold");
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(1.0f);
		this.server_SetTimeToDie(3);

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && !blob.hasTag("evil") && blob.hasTag("player") && (blob.getName() != "goldenbeing"))
	{
		blob.server_Heal(1);
	}
	if(solid)this.server_Die();
}