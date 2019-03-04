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
  this.set_f32("ArrowForce",17.0);
  this.set_f32("Speed",0.3f);
  this.set_f32("SlowFactor",1.2f);
  this.set_u32("ReloadMax",40);
  this.set_u32("Reload",0);
  this.Sync("Reload",true);
  this.set_string("AbilityName","Teleport");
  
  this.set_u32("Reload2Max",70);
  this.set_u32("Reload2",0);
  this.Sync("Reload2",true);
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
  
    if(this.get_u32("Reload2") < this.get_u32("Reload2Max") && this.isKeyPressed(key_action2) && !this.isKeyPressed(key_action1)) 
	{
		this.set_u32("Reload2", this.get_u32("Reload2") + 1);
	}
	else if(this.get_u32("Reload2") >= this.get_u32("Reload2Max") && this.isKeyPressed(key_action2) && !this.isKeyPressed(key_action1))
	{
		if((this.getAimPos() - this.getPosition()).getLength() < 150.0f) 
		{
			this.set_u32("Reload2", 0);
      this.getSprite().PlaySound("WizrobeTeleport.ogg");
			this.setPosition(this.getAimPos());
		}
	}
	else if (this.get_u32("Reload2") < this.get_u32("Reload2Max"))
	{
		this.set_u32("Reload2", this.get_u32("Reload2") + 1);
	}	
  
  

	
    
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
  
  
}


