void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{  
  knight_actorlimit_setup(this);
  this.set_u32("Reload",0);
  this.Sync("Reload",true);
  this.set_u32("SlashTime",0);
  this.Sync("SlashTime",true);
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

	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  if(!this.exists("ReloadMax") || !this.exists("SlashArc") || !this.exists("SlashForce") || !this.exists("SlashDamage") || !this.exists("SlowFactor")) 
  return;
  
  if(this.isKeyPressed(key_action1) && !this.isKeyPressed(key_action2) ) 
  {
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars))
    {
      return;
    }
    moveVars.walkFactor *= this.get_f32("SlowFactor");
    moveVars.jumpFactor *= this.get_f32("SlowFactor");
    
    if ( this.get_u32("Reload") < this.get_u32("ReloadMax"))
    {
      this.set_u32("Reload",this.get_u32("Reload") + 1);
    }
  }
  else if (this.isKeyJustReleased(key_action1) && this.get_u32("Reload") >= this.get_u32("ReloadMax"))
  {
    this.set_u32("SlashTime",13);
    if(this.getName() == "link")
      this.getSprite().PlaySound("LinkSlash.ogg");
    else if(this.getName() == "windbird")
      this.getSprite().PlaySound("WindBirdSlash.ogg");
    else 
      this.getSprite().PlaySound("Slash.ogg");
    
		Vec2f Force = Vec2f(this.get_f32("SlashForce"), 0);
		Vec2f Aim = this.getPosition() - this.getAimPos();
		Force = Force.RotateBy( Aim.Angle() );
		this.AddForce( Vec2f(-Force.x, Force.y) );
  }
  else 
  {
    this.set_u32("Reload",0);
  }
  if(this.get_u32("SlashTime") > 0) 
  {
    Vec2f vec;
    const int direction = this.getAimDirection(vec);
    f32 radius = this.getRadius();
    f32 aimangle = -(vec.Angle());
    if (aimangle < 0.0f)
    {
      aimangle += 360.0f;
    }
    CMap@ map = this.getMap();
    Vec2f vel = this.getVelocity();
    Vec2f thinghy(1, 0);
    thinghy.RotateBy(aimangle);
    Vec2f blobPos = this.getPosition();
    Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
    vel.Normalize();
    
    
    HitInfo@[] hitInfos;
    if (map.getHitInfosFromArc(pos, aimangle, this.get_f32("SlashArc"), radius + 18.0f, this, @hitInfos))
    {
      for (uint i = 0; i < hitInfos.length; i++)
      {
        HitInfo@ hi = hitInfos[i];
        CBlob@ b = hi.blob;
        
        if (b !is null && b.hasTag("player") && b.getTeamNum() != this.getTeamNum() && !knight_has_hit_actor(this, b))  // blob
        {
          knight_add_actor_limit( this,b);
          Vec2f velocity = b.getPosition() - pos;
          if(this.getName() == "windbird")
          {
            Vec2f force = velocity * 20;
            b.AddForce( force );
          }
         
          this.server_Hit(b, hi.hitpos, velocity, this.get_f32("SlashDamage"), Hitters::sword, true); 
        }
      }
    }
    this.set_u32("Reload",0);
    this.set_u32("SlashTime",this.get_u32("SlashTime") - 1);
    
    /*CBlob@[] nearBlobs; // -------Mutations!
    this.getMap().getBlobsInRadius( this.getPosition(), 20.0f, @nearBlobs );
    bool facingleft = this.getAimPos().x < this.getPosition().x ;
		for(int step = 0; step < nearBlobs.length; ++step)
		{ 
      if(nearBlobs[step].hasTag("player"))
      {
        if(this.getPosition().x < nearBlobs[step].getPosition().x && facingleft) 
        {
          this.server_Hit(nearBlobs[step], this.getPosition(), Vec2f(0.0f,0.0f), 1.0f, Hitters::arrow);
        }
        else if (this.getPosition().x > nearBlobs[step].getPosition().x && !facingleft) 
        {
          this.server_Hit(nearBlobs[step], this.getPosition(), Vec2f(0.0f,0.0f), 1.0f, Hitters::arrow);
        }
      }
    }*/
  }
  else 
  {
    knight_clear_actor_limits( this);
  }
  
	
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
}