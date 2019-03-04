
#include "EnergyCommon.as";

void onTick(CBlob @this){
	
	if(!this.hasTag("RuneNullify")){
	
		this.Tag("RuneNullify");
	
		
		
		this.set_u32("null_buff",getGameTime()+60);
		
		if(getNet().isServer())this.Sync("null_buff",true);
		if(getNet().isServer())this.Sync("RuneNullify",true);
	}

	CSprite@ sprite = this.getSprite();
	
	if(sprite !is null)
	if(sprite.getSpriteLayer("orderbuff") is null){
		sprite.RemoveSpriteLayer("orderbuff");
		CSpriteLayer@ orderbuff = sprite.addSpriteLayer("orderbuff", "BuffOrder.png", 32, 32);

		if (orderbuff !is null)
		{
			Animation@ anim = orderbuff.addAnimation("default", 4, false);
			int[] frames = {0, 1, 2, 3};
			anim.AddFrames(frames);
			orderbuff.SetRelativeZ(1.0f);
			orderbuff.SetOffset(Vec2f(0,0));
			orderbuff.setRenderStyle(RenderStyle::additive);
		}
	}
	
	if(this.get_u32("null_buff") < getGameTime()){
		this.Untag("RuneNullify");
		this.RemoveScript("BuffOrder.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("orderbuff");
		}
	}
	
	setEnergy(this, 0);

}