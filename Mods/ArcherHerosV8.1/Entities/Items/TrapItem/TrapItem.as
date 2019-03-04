// Keg logic
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("medium weight");
}

void onTick(CBlob@ this)
{
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && blob.hasTag("player") && blob.getTeamNum() != this.getTeamNum())
	{
    this.server_Die();
    blob.set_u32("trapped",180);
  
  }
}

//sprite update
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
  return false;
}


