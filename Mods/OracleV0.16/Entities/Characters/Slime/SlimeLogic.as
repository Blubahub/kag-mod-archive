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
  this.set_u32("Reload",30);
  this.set_u32("Reload2",300);
  this.set_u32("Reload2Max",300);
  this.set_u32("ReloadMax",60);
  this.set_f32("Speed",0.1f);
  this.set_string("AbilityName","Slime Trap");
  this.set_string("PrimaryName","Strike");
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
  
  if(this.isKeyPressed(key_action2)&& getKnocked(this) < 1) 
  {
    if(this.get_u32("Reload") >= this.get_u32("ReloadMax") && !this.isKeyPressed(key_action1))
    {
      Vec2f Force = Vec2f(600.0f, 0);
      this.getSprite().PlaySound("SlimeStrike.ogg");
      Vec2f Aim = this.getPosition() - this.getAimPos();
      Force = Force.RotateBy( Aim.Angle() );
      this.AddForce( Vec2f(-Force.x, Force.y) );
      this.set_u32("Reload",0);
      this.set_u32("HitTime", 15);
    }
    
  }
  
  if(this.isKeyPressed(key_action1)&& getKnocked(this) < 1) 
  {
    if(this.get_u32("Reload2") >= this.get_u32("Reload2Max") )
    {
      this.getSprite().PlaySound("SlimeTrapShoot.ogg");
      CBlob@ slimetrap = server_CreateBlobNoInit("littleslime");
      if (slimetrap !is null)
      {
        slimetrap.Init();

        slimetrap.SetDamageOwnerPlayer(this.getPlayer());
        slimetrap.server_setTeamNum(this.getTeamNum());
        slimetrap.setPosition(this.getPosition());
        slimetrap.server_SetTimeToDie(10);	
        
        Vec2f Force = Vec2f(4.0f, 0);
        Vec2f Aim = this.getPosition() - this.getAimPos();
        Force = Force.RotateBy( Aim.Angle() );
        slimetrap.AddForce( Vec2f(-Force.x, Force.y) );
      }
      
      this.set_u32("Reload2",0);
    }
    
  }
  if(this.get_u32("HitTime") >= 1)
  {
   this.set_u32("HitTime", this.get_u32("HitTime") - 1);
   int all = this.getTouchingCount();
   for (int i = 0; i < all; i++) 
   {
    CBlob@ b = this.getTouchingByIndex(i);
    f32 enemydam = 0.0f;
		if (this.get_u32("HitTime") > 0 && this.getTeamNum() != b.getTeamNum() && b.hasTag("player"))
		{
			enemydam = 2.0f;
      this.set_u32("HitTime", 0);
      Vec2f Force = Vec2f(300.0f, 0);
      Vec2f Aim = b.getPosition() - this.getPosition();
      Force = Force.RotateBy( Aim.Angle() );
      this.AddForce( Vec2f(-Force.x, Force.y) );
		}

		if (enemydam > 0)
		{
			this.server_Hit(b, this.getPosition(), Vec2f(0, 1) , enemydam, Hitters::stomp);
		}
   }
  }
  if(this.get_u32("Reload") < this.get_u32("ReloadMax"))
  {
   this.set_u32("Reload", this.get_u32("Reload") + 1);
  }
  if(this.get_u32("Reload2") < this.get_u32("Reload2Max"))
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if ( blob is null)
		return;

	Vec2f vel = this.getOldVelocity();
  
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
  
  CBlob@ arrow = server_CreateBlobNoInit("littleslime");
	if (arrow !is null)
	{
		arrow.Init();

		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
    arrow.server_SetTimeToDie(30);	
	}
	return arrow;
}


