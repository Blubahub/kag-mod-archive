

// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{ 
  this.set_u32("Reload",0);
  this.Sync("Reload",true);
  this.set_u32("Reload2",0);
  this.Sync("Reload2",true);
  this.set_s16("HarpID",0);
  this.Sync("HarpID",true);
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
    if( this.get_u32("Reload") < this.get_u32("ReloadMax") ) 
    {
      this.set_u32("Reload",this.get_u32("Reload") + 1);
      
    }
    if(getKnocked(this) < 1  && this.get_u32("Reload") == this.get_u32("ReloadMax") && this.isKeyPressed(key_action1) && !this.isKeyPressed(key_action2))
    {
       
      //Sound::Play("PigShoot.ogg", this.getPosition());
      this.set_u32("Reload",0);
      if(getNet().isServer())
      {
        ShootArrow(this, this.getPosition() , this.getAimPos() , 7.0f , 0.15f); 
        ShootArrow(this, this.getPosition() , this.getAimPos() , 7.0f , 0.15f,5); 
        ShootArrow(this, this.getPosition() , this.getAimPos() , 7.0f , 0.15f,15); 
        ShootArrow(this, this.getPosition() , this.getAimPos() , 7.0f , 0.15f,-5); 
        ShootArrow(this, this.getPosition() , this.getAimPos() , 7.0f , 0.15f,-15); 
      }
    }
 
  if(this.isKeyPressed(key_action2)&& getKnocked(this) < 1) 
  {
    if(this.get_u32("Reload2") >= this.get_u32("Reload2Max") )
    {
      this.set_u32("Reload2",0);
      Vec2f Force = Vec2f(15.0f, 0);
      Vec2f Aim = this.getPosition() - this.getAimPos();
      Force = Force.RotateBy( Aim.Angle() );
      
      if(getNet().isServer())
      {
        CBlob@ harp = server_CreateBlobNoInit("harp");
        if (harp !is null)
        {
          harp.Init();

          harp.server_setTeamNum(this.getTeamNum());
          harp.setPosition(this.getPosition() + Vec2f( -Force.x, Force.y));
          if(this.get_s16("HarpID") != 0)
          {
            CBlob@ otherharp = getBlobByNetworkID(this.get_s16("HarpID"));
            if (otherharp !is null)
            {
               otherharp.server_Die();
               this.set_s16("HarpID",harp.getNetworkID());
            }
            else
              this.set_s16("HarpID",harp.getNetworkID());
          }
          else
            this.set_s16("HarpID",harp.getNetworkID());
          
        }
        this.Sync("HarpID",true);
      }
      
      
    }
    
  }
  else if(this.get_u32("Reload2") < this.get_u32("Reload2Max"))
  {
    if(this.get_s16("HarpID") != 0)
    {
      CBlob@ otherharp = getBlobByNetworkID(this.get_s16("HarpID"));
      if (otherharp is null)
      {
        this.set_u32("Reload2", this.get_u32("Reload2") + 1);
      }
    }
    else
      this.set_u32("Reload2", this.get_u32("Reload2") + 1);
  }
  
}
  
  
	
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
  
  
void onDie( CBlob@ this )
{
  if(this.get_s16("HarpID") != 0)
  {
    CBlob@ othersnake = getBlobByNetworkID(this.get_s16("HarpID"));
    if (othersnake !is null)
    {
      othersnake.server_Die();
    }
  }
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
    arrow.server_SetTimeToDie(2);	
	}
	return arrow;
}