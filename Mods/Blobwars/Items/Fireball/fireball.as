//fireball
#include "Hitters.as";

void onInit(CBlob@ this)
{
  //tags and syncs
  this.Tag("fireball");
  this.Tag("ability");
  this.Tag("fire source");
  this.Tag("projectile");

  //setting the particle light
  this.SetLight(true); //turns light on
  this.SetLightColor(SColor(0,190,100,0)); //orange
  this.SetLightRadius(20.0f); //small circle

  //other stuff
  this.getShape().SetGravityScale(0.4f);
}

void Fireeee(Vec2f pos)
{
  CMap@ map = getMap();
  if (map is null)
  {
    return;
  }
  map.server_setFireWorldspace(pos, true);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
  return false; //was true for testing
}

void onTick(CBlob@ this)
{
  Vec2f pos = this.getPosition();
  Vec2f vel = this.getVelocity();

  if(this.isInWater() == true || this.isOnGround() == true)//dies if it touches water or ground.
  {
    this.server_Die();
    Fireeee(pos);
  }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
  CMap@ map;

  Vec2f pos = this.getPosition();

  if(blob !is null && blob.getTeamNum() != this.getTeamNum())
  {
    this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 1.0f, Hitters::crush, false);
    Fireeee(pos);
  }
}
