#include "Hitters.as";

void onTick(CBlob @this){

	if(!this.hasTag("LivingFlame")){
	
		this.Tag("LivingFlame");
	
		CSprite@ sprite = this.getSprite();
	
		if(sprite !is null){
			sprite.RemoveSpriteLayer("living_flame");
			CSpriteLayer@ living_flame = sprite.addSpriteLayer("living_flame", "LivingFlame.png", 32, 32);

			if (living_flame !is null)
			{
				Animation@ anim = living_flame.addAnimation("default", 2, true);
				int[] frames = {0,1,2,3};
				anim.AddFrames(frames);
				living_flame.SetRelativeZ(1.0f);
				living_flame.SetOffset(Vec2f(0,0));
			}
		}
		
		
		this.SetLight(true);
		this.SetLightRadius(64.0f);
		this.SetLightColor(SColor(255, 255, 255, 0));
	}
	
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		CSpriteLayer@ plague = sprite.getSpriteLayer("living_flame");

		if (plague !is null)
		{
			plague.RotateBy(-5,Vec2f(0,0));
			plague.SetFacingLeft(false);
		}
	}

}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("living_flame");
	}
}