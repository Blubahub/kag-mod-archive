// Lantern script
#include "Hitters.as"
void onInit(CBlob@ this)
{
   this.set_u32("hi",2);
   CShape@ shape = this.getShape();
   shape.SetGravityScale(0.0f);
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid ) 
{
  if(blob !is null && blob.hasTag("player") && blob.getTeamNum() != this.getTeamNum() ) {
    blob.set_u32("Slow",50);
    this.server_Hit(blob, this.getPosition(), Vec2f(0, 0) , 0.5f, Hitters::stomp);
    this.server_Die();
  }
}