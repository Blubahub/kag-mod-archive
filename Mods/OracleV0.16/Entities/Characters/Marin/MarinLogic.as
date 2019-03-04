// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f); //When the class/blob reaches negative 3 hp, it explodes into gore.

	this.Tag("player"); //This is a player
	this.Tag("flesh"); //This class is also flesh. Tags like plant/stone/metal don't work unless you code them yourself

	CShape@ shape = this.getShape(); //Getting our physics variable
	shape.SetRotationsAllowed(false); //Let's not roll all over the place.
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
  
  this.set_bool("hasBow",true);
  this.set_f32("ArrowDamage",0.5f);
  this.set_f32("ArrowForce",7.0f);
  this.set_f32("Speed",0.9f);
  this.set_f32("SlowFactor",0.6f);
  this.set_u32("ReloadMax",55);
  this.set_string("AbilityName","Sing");
  this.set_u32("Reload",0);
  this.Sync("Reload",true);
  this.set_u32("Reload2Max",1);
  this.set_u32("Reload2",0);
  this.Sync("Reload2",true);
  
}

void onRender(CSprite@ this)
{
    
  CBlob@ blob = this.getBlob();
  
  if(blob.isMyPlayer())
  {
    GUI::DrawCircle(blob.getScreenPos(),100.0f,SColor(0,60,120,60));
  }
    
	
	if(blob.isKeyPressed(key_action2) ) 
  {
    CMap@ map = getMap();
    if(map !is null) 
    {
      CBlob@[] everyone;
      map.getBlobsInRadius(blob.getPosition(),50.0f,@everyone);
      for (uint i = 0; i < everyone.length; i++)
      {
        if(everyone[i].getTeamNum() == blob.getTeamNum() && everyone[i].hasTag("player"))
        {
          GUI::DrawLine(blob.getPosition(), everyone[i].getPosition(), SColor(0,60,120,60));
        }
      }
    }
  }
	
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16)); //This basically sets our score board icon.
	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{
	if(this.isInInventory()) //Are we in an inventory? 
		return; //Yes? Back the heck out. We can't use abilities in inventories.

	const bool ismyplayer = this.isMyPlayer(); //Is this our player?

	if(ismyplayer && getHUD().hasMenus()) //If this is our player AND we are in a menu...
	{
		return; //...back the heck out!
	}

	// activate/throw
	if(ismyplayer) //If this is our player
	{

		if(this.isKeyJustPressed(key_action3)) //And we hit action3(default spacebar)
		{
			CBlob@ carried = this.getCarriedBlob(); //Get what we are carrying
			if(carried is null) //If we are carrying something...
			{
				client_SendThrowOrActivateCommand(this); //...throw it! Or activate it.
			}
		}
	}
  
  if (getGameTime() % 150 == 0)
    this.server_Heal(0.25f);
  
  if(this.isKeyPressed(key_action2) && getGameTime() % 30 == 0) 
  {
    CMap@ map = getMap();
    if(map !is null) 
    {
      CBlob@[] everyone;
      map.getBlobsInRadius(this.getPosition(),50.0f,@everyone);
      for (uint i = 0; i < everyone.length; i++)
      {
        if(everyone[i].getTeamNum() == this.getTeamNum() && everyone[i].hasTag("player"))
        {
          if(everyone[i] !is this)
            everyone[i].server_Heal(0.5f);
        }
      }
    }
  }
  
  if (this.isKeyPressed(key_action2))
  {
    this.set_u32("Reload2",1);
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars))
    {
      return;
    }
    moveVars.walkFactor *= 0.0f;
    
  }
  else
    this.set_u32("Reload2",0);
  
  
	
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
}

void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const f32 arrow_type, const f32 legolas = 0)
{
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		CreateArrow(this, arrowPos, arrowVel.RotateBy(legolas), arrow_type);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, f32 arrowType)
{
  string typelol = "ralpharrow";
  if(this.getName() == "mutantrat")
  {
    typelol = "cata_rock";
  }
  else if(this.getName() == "dwarfbrawler")
  {
    typelol = "boulder";
  }
  CBlob@ arrow = server_CreateBlobNoInit(typelol);
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", 0);
    arrow.set_f32("dmgmult", arrowType);
    arrow.set_Vec2f("start",this.getPosition());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
    arrow.server_SetTimeToDie(5);	
	}
	return arrow;
}