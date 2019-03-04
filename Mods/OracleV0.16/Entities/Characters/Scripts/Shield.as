

// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{  
  this.set_f32("ShieldHealth",this.get_f32("SheildHealthMax"));
  this.Sync("ShieldHealth",true);
  
  this.set_u32("Reload2",0);
  this.Sync("Reload2",true);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = Vec2f(getScreenWidth()/30,getScreenHeight()/16 + 30);
	if(blob.isMyPlayer())
	{
    if (blob.get_f32("ShieldHealth") == blob.get_f32("ShieldHealthMax"))
    {
			GUI::DrawPane(pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 15, 70, 255));
    }
    else
		GUI::DrawProgressBar(pos, Vec2f(pos.x + 80, pos.y + 20), blob.get_f32("ShieldHealth")/ blob.get_f32("ShieldHealthMax"));
    GUI::DrawText("Shield" , pos, Vec2f(pos.x + 80, pos.y + 20), SColor(255, 255, 255, 255), false, false);

	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{ 
  if(!this.exists("ShieldHealthMax") || !this.exists("ShieldHealth") ) 
  return;
  
  if(this.isKeyPressed(key_action2)&& getKnocked(this) < 1 && !this.isKeyPressed(key_action1) ) 
  {
    this.set_u32("Reload2",0);
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars))
    {
      return;
    }
    moveVars.walkFactor *= this.get_f32("SlowFactor");
  }
  else 
  {
    if(this.get_f32("ShieldHealth") < this.get_f32("ShieldHealthMax") && this.get_u32("Reload2") < 75) 
    {
      this.set_u32("Reload2",this.get_u32("Reload2") + 1);
    }
    else if (this.get_f32("ShieldHealth") < this.get_f32("ShieldHealthMax") && this.get_u32("Reload2")>= 75) 
    {
      this.set_f32("ShieldHealth", this.get_f32("ShieldHealth") + 0.5f);
      if(this.get_f32("ShieldHealth") > this.get_f32("ShieldHealthMax"))
      {
        this.set_f32("ShieldHealth", this.get_f32("ShieldHealthMax"));
      }
      this.set_u32("Reload2",0);
    }
  }
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(damage > 0.0f && this.get_f32("ShieldHealth") > 0 && this.isKeyPressed(key_action2)) {
      this.set_f32("ShieldHealth", this.get_f32("ShieldHealth") - damage);
      if(this.get_f32("ShieldHealth") < 0.0f)
      {
        this.set_f32("ShieldHealth", 0.0f);
      }
      return 0.0f;
    }
    return damage;
}