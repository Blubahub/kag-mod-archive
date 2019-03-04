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
  
  //this.getBrain().server_SetActive(true);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
  this.set_u32("Reload",0);
  this.set_u32("ReloadMax",70);
  this.set_u32("Reload2",0);
  this.set_u32("Reload2Max",520);
  this.set_f32("Speed",0.6f);
  this.set_string("AbilityName","Portal");
  this.set_string("PrimaryName","Splash");
  this.Sync("Reload",true);
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
  
  
  
  if(this.isKeyPressed(key_action1)&& getKnocked(this) < 1 && this.get_u32("Reload") >= this.get_u32("ReloadMax")) 
  {
      this.set_u32("Reload",0);
      if(getNet().isServer())
      {
        CBlob@ splash = server_CreateBlobNoInit("splash");
        if (splash !is null)
        {
          splash.Init();

          splash.SetDamageOwnerPlayer(this.getPlayer());
          splash.server_setTeamNum(this.getTeamNum());
          splash.setPosition(this.getAimPos());
          splash.server_SetTimeToDie(10);	
        }
      }
     
      
    
    
  }
  else if(this.get_u32("Reload") < this.get_u32("ReloadMax"))
  {
   this.set_u32("Reload", this.get_u32("Reload") + 1);
  }
  
  if(this.isKeyPressed(key_action2)&& getKnocked(this) < 1) 
  {
    if(this.get_u32("Reload2") >= this.get_u32("Reload2Max") )
    {
      this.set_u32("Reload2",0);
      Vec2f Force = Vec2f(16.0f, 0);
      Vec2f Aim = this.getPosition() - this.getAimPos();
      Force = Force.RotateBy( Aim.Angle() );
      this.getSprite().PlaySound("ElderPortal.ogg");
      
      
      if(getNet().isServer())
      {
        CBlob@ portal1 = server_CreateBlobNoInit("portal");
        if (portal1 !is null)
        {
          portal1.Init();

          portal1.server_setTeamNum(this.getTeamNum());
          portal1.setPosition(this.getPosition() );
          portal1.set_Vec2f("Go",this.getAimPos());
          portal1.server_SetTimeToDie(15);	
          
          CBlob@ portal2 = server_CreateBlobNoInit("portal");
          if (portal2 !is null)
          {
            portal2.Init();

            portal2.server_setTeamNum(this.getTeamNum());
            portal2.setPosition(this.getAimPos());
            portal2.set_Vec2f("Go",this.getPosition() );
            portal2.server_SetTimeToDie(15);	
          }
        }
      }
      
      
    }
    
  }
  else if(this.get_u32("Reload2") < this.get_u32("Reload2Max"))
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



