#include "RunnerCommon.as"
#include "Hitters.as"
#include "Knocked.as"

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
    
  CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
    CBlob@ bop = getLocalPlayerBlob();
	
	if(bop !is null )
	{
		CPlayer@ p = bop.getPlayer();
		if(p !is null && p.getUsername() == " asfsd")
		{
			
			this.SetVisible(true);
			return;
		}
	}
    CMap@ map = getMap();
		if(bop !is null && blob.get_u32("Invis") > 0 && bop.getTeamNum()  != blob.getTeamNum())
    {
      this.getSpriteLayer("invis").SetVisible(false);
      this.SetVisible(false);
      return;
    }
    else 
    {
      if( blob.get_u32("Invis") > 0)
      {
        this.getSpriteLayer("invis").SetVisible(true);
      }
      else
        this.getSpriteLayer("invis").SetVisible(false);
      this.SetVisible(true);
    }
	}
  else
  {
    if( blob.get_u32("Invis") > 0)
    {
      this.getSpriteLayer("invis").SetVisible(true);
    }
    else
      this.getSpriteLayer("invis").SetVisible(false);
    this.SetVisible(true);
    
  }
	
}

void onInit(CBlob@ this)
{

this.set_u32("Slow",0);
this.Sync("Slow",true);

this.set_u32("Stun",0);
this.Sync("Stun",true);

this.set_u32("Poison",0);
this.set_u32("PoisonID",0);
this.Sync("Poison",true);
this.Sync("PoisonID",true);

this.set_u32("Invis",0);
this.Sync("Invis",true);
this.getSprite().SetZ(500.0f);
}

void onTick(CBlob@ this)
{
  RunnerMoveVars@ moveVars;
  if (!this.get("moveVars", @moveVars))
  {
    return;
  }
      moveVars.walkFactor *= this.get_f32("Speed");
	if(this.get_u32("Slow") > 0){
		this.set_u32("Slow",this.get_u32("Slow")-1);
    this.Sync("Slow",true);
    moveVars.walkFactor *= 0.2f;
	}	
  
  if(this.get_u32("Stun") > 0){
		this.set_u32("Stun",this.get_u32("Stun")-1);
    this.Sync("Stun",true);
    moveVars.walkFactor *= 0.0f;
	}	
  
  if(this.get_u32("Invis") > 0){
		this.set_u32("Invis",this.get_u32("Invis")-1);
    this.Sync("Invis",true);
	}	
  
  if(this.get_u32("Poison") > 0){
    if (this.get_u32("Poison") % 20 == 0) {
      CBlob@ hitter = getBlobByNetworkID(this.get_u32("PoisonID"));
      if(hitter !is null && this.get_u32("PoisonID") != 0)
      {
        hitter.server_Hit(this, this.getPosition(), Vec2f(0, 0) , 0.2f, Hitters::stomp);
      }
      else
        this.server_Hit(this, this.getPosition(), Vec2f(0, 0) , 0.2f, Hitters::stomp);
    }
		this.set_u32("Poison",this.get_u32("Poison")-1);
    this.Sync("Poison",true);
	}	
  
  
}


void onInit(CSprite@ this)
{
	{
		this.RemoveSpriteLayer("poison");
		CSpriteLayer@ effect = this.addSpriteLayer("poison", "EffectCommon.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(2);
			effect.SetOffset(Vec2f(0,0));
			effect.SetAnimation("default");
			effect.SetVisible(false);
			effect.SetRelativeZ(4.0f);
		}
	}
  
  {
		this.RemoveSpriteLayer("stun");
		CSpriteLayer@ effect = this.addSpriteLayer("stun", "EffectCommon.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(3);
			effect.SetOffset(Vec2f(0,0));
			effect.SetAnimation("default");
			effect.SetVisible(false);
			effect.SetRelativeZ(4.0f);
		}
	}
  {
		this.RemoveSpriteLayer("slow");
		CSpriteLayer@ effect = this.addSpriteLayer("slow", "EffectCommon.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(1);
			effect.SetOffset(Vec2f(0,0));
			effect.SetAnimation("default");
			effect.SetVisible(false);
			effect.SetRelativeZ(4.0f);
		}
	}
  {
		this.RemoveSpriteLayer("invis");
		CSpriteLayer@ effect = this.addSpriteLayer("invis", "EffectCommon.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(4);
			effect.SetOffset(Vec2f(0,0));
			effect.SetAnimation("default");
			effect.SetVisible(false);
			effect.SetRelativeZ(4.0f);
		}
	}
	
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	this.getSpriteLayer("poison").SetVisible(false);
	if(blob.get_u32("Poison") > 0)
	{
		this.getSpriteLayer("poison").SetVisible(true);
	}
  this.getSpriteLayer("stun").SetVisible(false);
	if(blob.get_u32("Stun") > 0)
	{
		this.getSpriteLayer("stun").SetVisible(true);
	}
  this.getSpriteLayer("slow").SetVisible(false);
	if(blob.get_u32("Slow") > 0)
	{
		this.getSpriteLayer("slow").SetVisible(true);
	}
  
	
} 





