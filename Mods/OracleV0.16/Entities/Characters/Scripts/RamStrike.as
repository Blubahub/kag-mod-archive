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
  this.set_u32("ReloadMax",50);
  this.Sync("Reload",true);
  this.set_u32("HitTime",0);
  this.Sync("HitTime",true);
  this.set_f32("ShellHealth",4.0f);
  this.set_f32("ShellHealthMax",4.0f);
  this.set_bool("IsOut",false);
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
		
    if(blob.get_bool("IsOut"))
      GUI::DrawText("Rock" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
    else
      GUI::DrawText("Ram" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
		
		pos.y += 30;
		
		if (blob.get_f32("ShellHealth") == blob.get_f32("ShellHealthMax"))
		{
				GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 15, 70, 255));
		}
		else
			GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), blob.get_f32("ShellHealth")/ blob.get_f32("ShellHealthMax"));
    if(blob.get_bool("IsOut"))
      GUI::DrawText("Rebuildin..." , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);
    else
      GUI::DrawText("Shell" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);

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
  else if (!this.get_bool("IsOut") && this.isKeyJustPressed(key_action1) && this.get_u32("Reload") >= this.get_u32("ReloadMax"))
  {
    this.set_u32("HitTime",15);
    this.set_u32("Reload",0);
    Sound::Play("Slash.ogg", this.getPosition());
		Vec2f Force = Vec2f(350.0f, 0);
		Vec2f Aim = this.getPosition() - this.getAimPos();
		Force = Force.RotateBy( Aim.Angle() );
		this.AddForce( Vec2f(-Force.x, Force.y) );
  }
  else if (this.get_bool("IsOut") && this.isKeyPressed(key_action1) && this.get_u32("Reload") >= this.get_u32("ReloadMax"))
  {
    this.set_u32("Reload",0);
     ShootArrow(this, this.getPosition() , this.getAimPos() , 12.0f , 0.25f); 
  }
  
  if(getGameTime() % 50 == 0 && this.get_f32("ShellHealth") < this.get_f32("ShellHealthMax") && this.get_bool("IsOut")) 
  {
    this.set_f32("ShellHealth", this.get_f32("ShellHealth") + 0.5f);
    if(this.get_f32("ShellHealth") > this.get_f32("ShellHealthMax"))
    {
      this.set_f32("ShellHealthMax", this.get_f32("ShellHealthMax"));
    }
  }
  
  if(this.get_f32("ShellHealth") >= this.get_f32("ShellHealthMax") && this.get_bool("IsOut"))
  {
    this.set_bool("IsOut", false);
    this.getSprite().PlaySound("ShellRegenerate.ogg");
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
        if (this.get_u32("HitTime") > 0 && this.getTeamNum() != blob.getTeamNum() && !knight_has_hit_actor(this, blob) && blob.hasTag("player"))
        {
          enemydam = 1.0f;
          knight_add_actor_limit( this,blob);
          Vec2f Force = Vec2f(300.0f, 0);
          Vec2f Aim = blob.getPosition() - this.getPosition();
          Force = Force.RotateBy( Aim.Angle() );
          this.AddForce( Vec2f(-Force.x, Force.y) );
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

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(!this.get_bool("IsOut") && damage > 0.0f && this.get_f32("ShellHealth") > 0) {
      this.set_f32("ShellHealth", this.get_f32("ShellHealth") - damage);
      if(this.get_f32("ShellHealth") <= 0.0f)
      {
		this.set_bool("IsOut",true);
        this.set_f32("ShieldHealth", 0.0f);
		this.set_u32("HitTime",0);
      }
      return 0.0f;
    }
    return damage;
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
		// fire arrow?
		arrow.set_string("arrow type", this.getName());
    arrow.set_f32("Damage", arrowType);
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
