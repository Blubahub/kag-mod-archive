

// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = Vec2f(getScreenWidth()/30,getScreenHeight()/16 + 30);
	if(blob.isMyPlayer())
	{
    if (blob.get_u32("Reload2") == blob.get_u32("Reload2Max"))
    {
			GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 60, 255, 30));
    }
    else
		GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("Reload2"))/ float(blob.get_u32("Reload2Max")));
    GUI::DrawText(blob.get_string("AbilityName") , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);

	
  
    if(blob.exists("PrimaryName"))
    {
      pos.y -= 30;
      if (blob.get_u32("Reload") == blob.get_u32("ReloadMax"))
      {
        GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 60, 255, 30));
      }
      else
      GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("Reload"))/ float(blob.get_u32("ReloadMax")));
      GUI::DrawText(blob.get_string("PrimaryName") , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
    }
  }
}