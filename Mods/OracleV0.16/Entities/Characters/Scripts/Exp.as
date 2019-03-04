//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.
#include "ProfilesCommon.as"; //Movement scripts.
#include "ExpCommon.as"; //Movement scripts.

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
  if(!blob.isMyPlayer())
  return;
	Vec2f pos = Vec2f(getScreenWidth()/30,getScreenHeight()/16);
	Vec2f pos2 = Vec2f(getScreenWidth()/30,getScreenHeight()/16 + 60);
  if(blob.exists("Exp"))
  {
    GUI::DrawProgressBar(pos2, Vec2f(pos2.x + 80, pos2.y + 20), float(blob.get_u32("Exp") % 10 )/ float(10));
    GUI::DrawText("Level: " + (Maths::Floor(float(blob.get_u32("Exp") )/ float(10))), pos2, Vec2f(pos2.x + 80, pos2.y + 20), SColor(255, 255, 255, 255), false, false);
  }
  
  pos2.y += 30;
  if(blob.exists("BestGuy"))
  {
    GUI::DrawPane(pos2, Vec2f(pos2.x + 160, pos2.y + 35));
    GUI::DrawText("Best " + blob.getName() + ": " + blob.get_string("BestGuy") + ", level " +  blob.get_u32("BestLevel"), pos2, Vec2f(pos2.x + 160, pos2.y + 35), SColor(255, 255, 255, 255), false, false, false);
  }
  
  pos2.y += 45;
  GUI::DrawPane(pos2, Vec2f(pos2.x + 160, pos2.y + 32), SColor(255,75,0,130));
  GUI::DrawText("Press 'P' to join the Discord Server!" , pos2, Vec2f(pos2.x + 160, pos2.y + 20), SColor(255, 255, 120, 255), false, false, false);

  
}

void onInit(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  CPlayer@ p = this.getPlayer();
    if( p !is null)
    {
      PlayerProfile@ pro =  server_getProfileByName(p.getUsername());
      if (pro !is null)
      {
        setStuffByBlobName(pro, this);
        getLeaderboard(pro, this);
      }
    
    }
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  if(this.hasTag("dead") ) 
  return;

  if(this.isMyPlayer() && !this.hasTag("dead") ){
		CControls@ controls = getControls();
		if(controls !is null){
			if (controls.isKeyJustPressed(KEY_KEY_P)   )OpenWebsite("https://discord.gg/EGA6ExQ");
		}
	}
  
  
  if(!this.exists("Exp"))
  {
    CPlayer@ p = this.getPlayer();
    if( p !is null)
    {
      PlayerProfile@ pro =  server_getProfileByName(p.getUsername());
      if (pro !is null)
      {
        setStuffByBlobName(pro, this);
      }
    
    }
    
    
  
  }
  
}


