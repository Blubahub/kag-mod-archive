// Lantern script
#include "Hitters.as"

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	GUI::DrawCircle(blob.getScreenPos(),24.0f,SColor(255,255,255,255));
}

void onInit(CBlob@ this)
{
   this.set_u32("Tick",30);
   CShape@ shape = this.getShape();
   shape.SetGravityScale(0.0f);
   //this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
  if(this.get_u32("Tick") == 0)
  {
    CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("hit");
    //adsprite.PlaySound("SplashHit.ogg");
    CMap@ map = getMap();
    if(map !is null) 
    {
      CBlob@[] everyone;
      map.getBlobsInRadius(this.getPosition(),12.0f,@everyone);
      for (uint i = 0; i < everyone.length; i++)
      {
        if(everyone[i].getTeamNum() != this.getTeamNum() && everyone[i].hasTag("player"))
        {
          this.server_Hit(everyone[i], everyone[i].getPosition(), Vec2f_zero , 0.5f, Hitters::arrow);
          everyone[i].getSprite().PlaySound("SplashHit.ogg");
        }
      }
    }
    this.server_Die();	
  }
  else
  {
    this.set_u32("Tick", this.get_u32("Tick") - 1);
  }
}