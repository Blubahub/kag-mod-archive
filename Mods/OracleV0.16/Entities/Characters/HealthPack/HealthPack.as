// Lantern script
#include "Hitters.as"
void onInit(CBlob@ this)
{
  this.set_u32("Tick",0);
  CShape@ shape = this.getShape();
  shape.SetGravityScale(0.0f);
  //shape.SetStatic(true);
   this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
  CSprite@ sprite = this.getSprite();
  if(this.get_u32("Tick") == 0)
    sprite.SetFrameIndex(0);
  else if(this.get_u32("Tick") == 4)
    sprite.SetFrameIndex(1);
  else if(this.get_u32("Tick") == 8)
    sprite.SetFrameIndex(2);
  else if(this.get_u32("Tick") == 12)
    sprite.SetFrameIndex(3);
  else if(this.get_u32("Tick") == 16)
    sprite.SetFrameIndex(4);
  
  if(this.get_u32("Tick") < 16)
  this.set_u32("Tick", this.get_u32("Tick") + 1);
  
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid ) 
{
  if(blob !is null && blob.hasTag("player") && blob.getHealth() < blob.getInitialHealth() && this.get_u32("Tick") == 16 && this.getTeamNum() == blob.getTeamNum()) {
    blob.server_Heal(1.0f);
    this.set_u32("Tick", 0);
  }
}