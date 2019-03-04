//made by vamist
#include "Hitters.as";

void onInit(CBlob@ this)
{
  this.getShape().SetGravityScale(0.0f);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
  return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
  CMap@ map;

  Vec2f pos = this.getPosition();

  if(blob !is null && blob.getTeamNum() != this.getTeamNum())
  {
    this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 2.0f, Hitters::crush, false);
  }
}
