

// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{ 
  this.set_u32("FairyCount",0);
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
  
  pos.y += 30;
	if(blob.isMyPlayer())
	{
    if (blob.get_u32("Reload2") == blob.get_u32("Reload2Max"))
    {
			GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 60, 255, 30));
    }
    else
		GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("Reload2"))/ float(blob.get_u32("Reload2Max")));
    GUI::DrawText("Fairies: " + blob.get_u32("FairyCount") , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
    

	}
  
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  if(this.isKeyPressed(key_action2) && this.get_u32("Reload2") >= this.get_u32("Reload2Max") && this.get_u32("FairyCount") > 0) 
  {
    this.set_u32("Reload2", 0);
    this.set_u32("FairyCount", this.get_u32("FairyCount") - 1);
    CBlob@ fairy = server_CreateBlobNoInit("healfairy");
    if (fairy !is null)
    {
      fairy.Init();
      fairy.server_setTeamNum(this.getTeamNum());
      fairy.setPosition(this.getPosition());
      fairy.server_SetTimeToDie(10);	
        
      Vec2f Force = Vec2f(13.0f, 0);
      Vec2f Aim = this.getPosition() - this.getAimPos();
      Force = Force.RotateBy( Aim.Angle() );
      fairy.AddForce( Vec2f(-Force.x, Force.y) );
    }
  }
  else if (this.get_u32("Reload2") < this.get_u32("Reload2Max") && !this.isKeyPressed(key_action2))
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
    arrow.set_string("arrow type", "fairyheal");
    arrow.set_f32("Damage", arrowType);
    
    
		
    arrow.set_Vec2f("start",this.getPosition());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);	
    
    arrow.server_SetTimeToDie(7);	
    
	}
	return arrow;
}