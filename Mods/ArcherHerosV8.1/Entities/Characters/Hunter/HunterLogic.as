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
  this.set_u32("Reload2",30);
  this.set_u16("turretid",0);
  this.set_bool("Mode",true);
  this.Sync("Reload",true);
  this.Sync("Reload2",true);
  this.set_bool("made",false);
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
  if(this.isKeyPressed(key_action1) ) 
  {
    if(this.get_u32("Reload") < 1 && !this.isKeyPressed(key_action2)&& getKnocked(this) < 1)
    {
      ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), this.getAimPos() + Vec2f(0.0f, -2.0f),  18.0f, 0, false); 
      this.set_u32("Reload",50);
    }
    
  }
  else if(this.isKeyPressed(key_action2))
  {
    if(this.get_u32("Reload2") < 1 )
    {
      CBlob@ turret1 = getBlobByNetworkID(this.get_u16("turretid"));
      if(turret1 !is null) 
      {
        turret1.server_Die();
      }
      CBlob@ turret = server_CreateBlobNoInit("trapitem");
      if (turret !is null)
      {
        // fire arrow?
        turret.set_u16("ownerid", this.getNetworkID());
        turret.Init();
        turret.setPosition(this.getPosition());
        turret.server_setTeamNum(this.getTeamNum());
        this.set_u16("turretid",turret.getNetworkID());
        Vec2f Force = Vec2f(900.0f, 0);
        Vec2f Aim = this.getPosition() - this.getAimPos();
        Force = Force.RotateBy( Aim.Angle() );
        turret.AddForce( Vec2f(-Force.x, Force.y) );
       }
       this.set_bool("made",true);
      this.set_u32("Reload2",300);
    }
  }
  if(this.get_u32("Reload") >= 1)
  {
   this.set_u32("Reload", this.get_u32("Reload") - 1);
  }
  
  if(this.get_u32("Reload2") >= 1)
  {
   this.set_u32("Reload2", this.get_u32("Reload2") - 1);
  }
    
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
  
  
}

void onDie( CBlob@ this )
{
if(this.get_bool("made"))
{
  CBlob@ turret1 = getBlobByNetworkID(this.get_u16("turretid"));
  if(turret1 !is null) 
  {
    turret1.server_Die();
  }
  
 }

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
    arrow.set_f32("dmgmult", 2.0);
    arrow.set_bool("hunter",true);
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