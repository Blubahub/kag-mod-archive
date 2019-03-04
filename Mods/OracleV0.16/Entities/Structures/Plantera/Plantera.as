// Tent logic

#include "StandardRespawnCommand.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
  
  this.set_u32("Tick",0);
  CShape@ shape = this.getShape();
  shape.SetGravityScale(0.0f);
  //shape.SetStatic(true);
   this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
  CSprite@ sprite = this.getSprite();
  
  
  
  if(this.get_u32("Tick") < 32)
  {
    this.set_u32("Tick", this.get_u32("Tick") + 1);
     sprite.SetFrameIndex(0);
  }
  else
  {
    sprite.SetFrameIndex(1);
    this.set_u32("Tick", 0);
    CBlob@ skipper = server_CreateBlobNoInit("skipper");
     if (skipper !is null)
     {
     skipper.Init();
      skipper.server_setTeamNum(59);
      skipper.setPosition(this.getPosition() + Vec2f(0.0f, 16.0f));
      
     }
  }
  this.Sync("Tick",true);
  
}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}
