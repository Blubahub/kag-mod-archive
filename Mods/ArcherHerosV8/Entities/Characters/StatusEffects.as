#include "RunnerCommon.as"
#include "Hitters.as"
#include "Knocked.as"

void onInit(CBlob@ this)
{
this.set_u32("heal",0);
this.Sync("heal",true);
}

void onTick(CBlob@ this)
{
	if(this.get_u32("heal") > 0){
		this.set_u32("heal",this.get_u32("heal")-1);
    this.Sync("heal",true);
	}	
  if(this.get_u32("trapped") > 1)
  {
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars))
    {
      return;
    }
    moveVars.walkFactor *= 0.00f;
    moveVars.jumpFactor *= 0.00f;
   this.set_u32("trapped", this.get_u32("trapped") - 1);
  
  }
  
}


void onInit(CSprite@ this)
{
	{
		this.RemoveSpriteLayer("heal");
		CSpriteLayer@ effect = this.addSpriteLayer("heal", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(0);
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
	this.getSpriteLayer("heal").SetVisible(false);
	if(blob.get_u32("heal") > 0)
	{
		this.getSpriteLayer("heal").SetVisible(true);
	}
	
} 





