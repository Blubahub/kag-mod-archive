#include "RunnerCommon.as";

void onTick(CBlob @this){
	
	if(!this.hasTag("Hasted")){
	
		this.Tag("Hasted");

		if(getNet().isServer())this.Sync("Hasted",true);		
		
		if(!this.exists("haste_timer"))this.set_u32("haste_timer",getGameTime()+30*30);
		if(getNet().isServer())this.Sync("haste_timer",true);

		this.getSprite().PlaySound("CK_Haste", 1.00f, 1.00f);	// Added by TFlippy	
	}
	
	CSprite@ sprite = this.getSprite();
	
	if(sprite !is null){
		CSpriteLayer@ clock_hand = sprite.getSpriteLayer("clock_hand_haste");

		if (clock_hand !is null)
		{
			clock_hand.ResetTransform();
			clock_hand.RotateBy(-360.0f*((this.get_u32("haste_timer")-float(getGameTime()))/(30*30)), Vec2f(0,0));
		} else {
			sprite.RemoveSpriteLayer("clock_hand_haste");
			@clock_hand = sprite.addSpriteLayer("clock_hand_haste", "Haste.png", 23, 23);

			if (clock_hand !is null)
			{
				Animation@ anim = clock_hand.addAnimation("default", 0, false);
				int[] frames = {1};
				anim.AddFrames(frames);
				clock_hand.SetRelativeZ(-1.0f);
				clock_hand.SetOffset(Vec2f(0,-4));
			}
			
			sprite.RemoveSpriteLayer("clock_back_haste");
			CSpriteLayer@ clock_back = sprite.addSpriteLayer("clock_back_haste", "Haste.png", 23, 23);

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

	if(this.get_u32("haste_timer") < getGameTime() || this.hasTag("RuneNullify")){
		this.Untag("Hasted");
		this.RemoveScript("Haste.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("clock_hand_haste");
			sprite.RemoveSpriteLayer("clock_back_haste");
		}
	}
	
	
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	moveVars.walkFactor *= 2.0f;

}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("clock_hand_haste");
		sprite.RemoveSpriteLayer("clock_back_haste");
	}
}