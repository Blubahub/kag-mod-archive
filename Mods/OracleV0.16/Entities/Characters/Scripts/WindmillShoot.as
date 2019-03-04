

// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{ 
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16)); //This basically sets our score board icon.
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = Vec2f(getScreenWidth()/30,getScreenHeight()/16);
	if(blob.isMyPlayer())
	{
    if (blob.get_u32("Reload") == blob.get_u32("ReloadMax"))
    {
			GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 60, 255, 30));
    }
    else
		GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("Reload"))/ float(blob.get_u32("ReloadMax")));
    GUI::DrawText("Primary" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
    
    pos.y += 30;
    
    if (blob.get_u32("Reload2") == blob.get_u32("Reload2Max"))
    {
			GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 60, 255, 30));
    }
    else
		GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("Reload2"))/ float(blob.get_u32("Reload2Max")));
    GUI::DrawText("Pull" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);

	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  if(this.isKeyPressed(key_action1) && this.get_u32("Reload") >= this.get_u32("ReloadMax"))
  {
    this.set_u32("Reload",0);
    if(getNet().isServer())
    {
      ShootArrow(this, this.getPosition() , this.getAimPos() , 12.0f , 0.15f,XORRandom(12)-6); 
    }
  }
  else if (this.get_u32("Reload") < this.get_u32("ReloadMax"))
    this.set_u32("Reload", this.get_u32("Reload") + 1);
  
  if(this.isKeyJustPressed(key_action2) && this.get_u32("Reload2") >= this.get_u32("Reload2Max"))
  {
    this.set_u32("Reload2",0);
    if(getNet().isServer())
    {
      CBlob@ windmill = server_CreateBlobNoInit("windmillmill");
      if (windmill !is null)
      {
        windmill.Init();
        
        windmill.server_setTeamNum(this.getTeamNum());
        windmill.setPosition(this.getPosition());
        windmill.server_SetTimeToDie(30);	
      }
    }
  }
  else if (this.get_u32("Reload2") < this.get_u32("Reload2Max"))
    this.set_u32("Reload2", this.get_u32("Reload2") + 1);
}
  
	
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////




void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const f32 arrow_type, const f32 legolas = 0)
{
  
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
    CreateArrow(this, arrowPos, arrowVel.RotateBy(legolas), arrow_type);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, f32 arrowType, bool stun = false)
{
  CBlob@ arrow = server_CreateBlobNoInit("bitproj");
	if (arrow !is null)
	{
    arrow.set_string("arrow type", this.getName());
    arrow.set_f32("Damage", arrowType);
    
    
		
    arrow.set_Vec2f("start",this.getPosition());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);	
    
    arrow.server_SetTimeToDie(1);	
    
	}
	return arrow;
}