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
  if(blob.isMyPlayer())
	{
	Vec2f pos = Vec2f(getScreenWidth()/30,getScreenHeight()/16);
	Vec2f pos2 = Vec2f(getScreenWidth()/30,getScreenHeight()/16 + 30);
    if (blob.get_u32("Index") == 0)
    {
			GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("ClipReload") - blob.get_u32("Reload"))/ float(blob.get_u32("ClipReload")));
    }
    else
		GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), float(blob.get_u32("Clipsize") - blob.get_u32("Index"))/ float(blob.get_u32("Clipsize")));
    GUI::DrawText("Ammo" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
  }
  
  if(blob.get_Vec2f("Linepos") != Vec2f(0,0))
  {
     GUI::DrawLine(blob.get_Vec2f("Shootfrom"), blob.get_Vec2f("Linepos"), SColor(255,255,255,255));
  blob.set_Vec2f("Linepos",Vec2f(0,0));
  
  }
	
  
}

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
  
  this.set_u32("Index",0);
  this.Sync("Index", true);
  this.set_u32("Line",0);
  this.set_Vec2f("Linepos",Vec2f(0,0));
  this.set_Vec2f("Shootfrom",Vec2f(0,0));
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
  f32 exact_aimangle = (this.getAimPos() - this.getPosition()).Angle();
	if(this.isInInventory()) //Are we in an inventory? 
		return; //Yes? Back the heck out. We can't use abilities in inventories.
    Vec2f from = Vec2f(16.0f, 0);
          from = from.RotateBy( -exact_aimangle );
          this.set_Vec2f("Shootfrom",this.getPosition() + from );

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
  if(this.isKeyPressed(key_action1)&& getKnocked(this) < 1) 
  {
    if(this.get_u32("Reload") < 1 )
    {
       
       CMap@ map = this.getMap();

      //get the actual aim angle
      
      // this gathers HitInfo objects which contain blob or tile hit information
      HitInfo@[] hitInfos;
      if (map.getHitInfosFromRay(this.getPosition(), -exact_aimangle, 300.0f, this, @hitInfos))
      {
        HitInfo@ hi = hitInfos[0];
        if (hi !is null)
        {
          CBlob@ b = hi.blob;
          if (b !is null) // blob
          {
            
           this.server_Hit(b, hi.hitpos, Vec2f(0,0), 1.0f, Hitters::arrow, true);  // server_Hit() is server-side only

          }
          this.set_Vec2f("Linepos",hi.hitpos);
          
        }
        
      }
      else
        {
          Vec2f Force = Vec2f(300.0f, 0);
          Force = Force.RotateBy( -exact_aimangle );
          this.set_Vec2f("Linepos",this.getPosition() + Force);
        }
      
      if(this.get_u32("Index") != this.get_u32("Clipsize"))
      {
        this.set_u32("Index", this.get_u32("Index") + 1);
        this.set_u32("Reload",this.get_u32("ReloadMax"));
      }
      else 
      {
        this.set_u32("Index", 0);
        this.set_u32("Reload",this.get_u32("ClipReload"));
      }
    }
  }
  
  if(this.get_u32("Line") >= 1)
  {
    GUI::DrawLine(this.getPosition(), this.get_Vec2f("Linepos"), SColor(255,255,255,255));
   this.set_u32("Line", this.get_u32("Line") - 1);
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
		arrow.set_u8("arrow type", arrowType);
    arrow.set_f32("dmgmult", this.get_f32("dmgmult"));
    arrow.set_Vec2f("start",this.getPosition());
    arrow.set_u16("reloadid",this.getNetworkID());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
    arrow.set_u16("reloadid",this.getNetworkID());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
	}
	return arrow;
}