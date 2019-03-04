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
  if(blob !is null && blob.hasTag("player") && blob.getTeamNum() == this.getTeamNum() && blob.getHealth() < blob.getInitialHealth()) {
    blob.server_Heal(1.0f);
    this.server_Die();
  }
}