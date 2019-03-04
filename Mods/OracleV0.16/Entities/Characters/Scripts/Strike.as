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
  this.set_u32("HitTime",0);
  this.Sync("HitTime",true);
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
    GUI::DrawText("Strike" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);

	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  const bool ismyplayer = this.isMyPlayer(); //Is this our player?

	if(ismyplayer && getHUD().hasMenus()) //If this is our player AND we are in a menu...
	{
		return; //...back the heck out!
	}
  
  if ( this.get_u32("Reload") < this.get_u32("ReloadMax") && this.get_u32("HitTime") == 0)
  { 
	this.set_u32("Reload",this.get_u32("Reload") + 1);
  }
  else if (this.isKeyJustPressed(key_action1) && this.get_u32("Reload") >= this.get_u32("ReloadMax"))
  {
    if(this.getName() == "fox")
        this.getSprite().PlaySound("FoxStrike.ogg");
      else 
        this.getSprite().PlaySound("Slash.ogg");
    this.set_u32("HitTime",13);
    this.set_u32("Reload",0);
		Vec2f Force = Vec2f(500.0f, 0);
		Vec2f Aim = this.getPosition() - this.getAimPos();
		Force = Force.RotateBy( Aim.Angle() );
		this.AddForce( Vec2f(-Force.x, Force.y) );
  }
  if(this.get_u32("HitTime") > 0) 
  {
    int all = this.getTouchingCount();
    for (int i = 0; i < all; i++) 
    {
      CBlob@ blob = this.getTouchingByIndex(i);
      if ( blob !is null)
      {
        f32 enemydam = 0.0f;
        if (this.get_u32("HitTime") > 0 && this.getTeamNum() != blob.getTeamNum() && !knight_has_hit_actor(this, blob))
        {
          
          this.set_u32("Reload",this.get_u32("ReloadMax") -40);
          enemydam = 1.0f;
          knight_add_actor_limit( this,blob);
        }

        if (enemydam > 0)
        {
          this.server_Hit(blob, this.getPosition(), Vec2f(0, 0) , enemydam, Hitters::stomp);
        }
      }
    }
    this.set_u32("HitTime",this.get_u32("HitTime") - 1);
  }
  else 
  {
    knight_clear_actor_limits( this);
  }
}
