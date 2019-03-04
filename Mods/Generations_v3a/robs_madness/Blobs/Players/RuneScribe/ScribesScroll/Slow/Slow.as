#include "RunnerCommon.as";


void onTick(CBlob @this){
	
	if(!this.hasTag("Slowed")){
	
		this.Tag("Slowed");

		if(getNet().isServer())this.Sync("Slowed",true);	
		
		this.getSprite().PlaySound("WC3_Slow", 1.00f, 1.00f);// Added by TFlippy
	}
	
	if(!this.exists("slow_timer"))this.set_u32("slow_timer",getGameTime()+30*30);
	if(getNet().isServer())this.Sync("slow_timer",true);	
	
	if(!this.exists("slow_time_amount"))this.set_u32("slow_time_amount",30*30);
	if(getNet().isServer())this.Sync("slow_time_amount",true);
	
	if(!this.exists("slow_amount"))this.set_f32("slow_amount",0.5);
	if(getNet().isServer())this.Sync("slow_amount",true);
	
	CSprite@ sprite = this.getSprite();
	
	if(sprite !is null){
		CSpriteLayer@ clock_hand = sprite.getSpriteLayer("clock_hand");

		if (clock_hand !is null)
		{
			clock_hand.ResetTransform();
			clock_hand.RotateBy(360.0f*((this.get_u32("slow_timer")-float(getGameTime()))/this.get_u32("slow_time_amount")), Vec2f(0,0));
		} else {
			sprite.RemoveSpriteLayer("clock_hand");
			@clock_hand = sprite.addSpriteLayer("clock_hand", "Slow.png", 23, 23);

			if (clock_hand !is null)
			{
				Animation@ anim = clock_hand.addAnimation("default", 0, false);
				int[] frames = {1};
				anim.AddFrames(frames);
				clock_hand.SetRelativeZ(-1.0f);
				clock_hand.SetOffset(Vec2f(0,-4));
			}
			
			sprite.RemoveSpriteLayer("clock_back");
			CSpriteLayer@ clock_back = sprite.addSpriteLayer("clock_back", "Slow.png", 23, 23);

			if (clock_back !is null)
			{
				Animation@ anim = clock_back.addAnimation("default", 0, false);
				int[] frames = {0};
				anim.AddFrames(frames);
				clock_back.SetRelativeZ(-1.5f);
				clock_back.SetOffset(Vec2f(0,-4));
				clock_back.setRenderStyle(RenderStyle::additive);
			}
		}
	}

	if(this.get_u32("slow_timer") < getGameTime() || this.hasTag("Cleanse") || this.hasTag("RuneNullify")){
		this.Untag("Slowed");
		this.RemoveScript("Slow.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("clock_hand");
			sprite.RemoveSpriteLayer("clock_back");
		}
	}
	
	
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	moveVars.jumpFactor *= 1.0f-this.get_f32("slow_amount");
	moveVars.walkFactor *= 1.0f-this.get_f32("slow_amount");

}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("clock_hand");
		sprite.RemoveSpriteLayer("clock_back");
	}
}