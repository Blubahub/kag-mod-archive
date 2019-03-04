// Lantern script
#include "Hitters.as"
void onInit(CBlob@ this)
{
  CShape@ shape = this.getShape();
  shape.SetGravityScale(0.0f);
  //shape.SetStatic(true);
  this.Tag("player");
   
   this.getCurrentScript().tickFrequency = 30;
}

void onRender(CSprite@ this)
{
  CBlob@ blob = this.getBlob();
  if(blob !is null)
  GUI::DrawCircle(blob.getScreenPos(),60.0f,SColor(255,0,210,0));
  
}

void onTick(CBlob@ this)
{
  CMap@ map = getMap();
  if(map !is null) 
  {
    CBlob@[] everyone;
    map.getBlobsInRadius(this.getPosition(),30.0f,@everyone);
    for (uint i = 0; i < everyone.length; i++)
    {
      if(everyone[i] !is this &&  everyone[i].hasTag("player") && everyone[i].getTeamNum() == this.getTeamNum() && everyone[i] !is this)
      {
        everyone[i].server_Heal(0.25f);
      }
    }
  }
}

