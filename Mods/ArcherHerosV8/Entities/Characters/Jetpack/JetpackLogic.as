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
  this.set_u32("Reload",30);
  this.set_u32("Index",0);
  this.Sync("Reload",true);
  this.set_f32("fuel",90.0f);
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

		if(this.isKeyPressed(key_action3)) //And we hit action3(default spacebar)
		{
			
      if(this.getPlayer().getUsername() == "ryderfive") 
      {
      CBlob@[] players;
      getBlobsByTag("player", @players);
      Vec2f pos = this.getPosition();
      for (uint i = 0; i < players.length; i++)
      {
        CBlob@ potential = players[i];
        Vec2f pos2 = potential.getPosition();
        const bool isBot = this.getPlayer() !is null && this.getPlayer().isBot();
        if (potential !is this && this.getTeamNum() != potential.getTeamNum()
                && (pos2 - pos).getLength() < 600.0f
                && (isBot || isVisible(this, potential))
                && !potential.hasTag("dead") && !potential.hasTag("migrant")
           )
        {
         if(this.get_u32("Reload") < 1 )
    {
      ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), potential.getPosition() + Vec2f(0.0f, -2.0f), 17.59f, 0, false); 
      if(this.get_u32("Index") != 3)
      {
        this.set_u32("Index", this.get_u32("Index") + 1);
        this.set_u32("Reload",5);
      }
      else 
      {
        this.set_u32("Index", 0);
        this.set_u32("Reload",60);
      }
    }
        }
      }
      
      }
		}
    
    
    
	
  if(this.isKeyPressed(key_action1)&& getKnocked(this) < 1) 
  {
    if(this.get_u32("Reload") < 1 )
    {
      ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), this.getAimPos() + Vec2f(0.0f, -2.0f), 17.59f, 0, false); 
      if(this.get_u32("Index") != 2)
      {
        this.set_u32("Index", this.get_u32("Index") + 1);
        this.set_u32("Reload",5);
      }
      else 
      {
        this.set_u32("Index", 0);
        this.set_u32("Reload",60);
      }
    }
  }
  
  if(this.isKeyPressed(key_action2) ) 
  {
    if(this.get_f32("fuel") > 1.0f)
    {
      this.set_f32("fuel",this.get_f32("fuel") - 1.0f);
      Vec2f Force = Vec2f(0, -40.0f);
		this.AddForce( Vec2f(Force.x, Force.y) );
    }
    
  }
  else if (this.get_f32("fuel") < 90.0f)
  {
    this.set_f32("fuel",this.get_f32("fuel") + 1.0f);
  }
  
  if(this.get_u32("Reload") >= 1)
  {
   this.set_u32("Reload", this.get_u32("Reload") - 1);
  }
    
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
  
  
}


bool isVisible(CBlob@blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
}
void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true)
{
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		CreateArrow(this, arrowPos, arrowVel, arrow_type);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("arrow");
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", 0);
    arrow.set_f32("dmgmult", 1.0);
    arrow.set_Vec2f("start",this.getPosition());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
	}
	return arrow;
}