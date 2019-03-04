
#include "Health.as";

void onTick(CBlob @this){

	//this.getCurrentScript().tickFrequency = 1;
	
	if(!this.hasTag("RegenVines")){
	
		this.Tag("RegenVines");
		if(getNet().isServer())this.Sync("RegenVines",true);
		
		this.set_u32("regen_buff",getGameTime()+(30*30));
		if(getNet().isServer())this.Sync("regen_buff",true);
	}

	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		CSpriteLayer@ regen_vines = sprite.getSpriteLayer("regen_vines");

		if (regen_vines !is null)
		{
			regen_vines.RotateBy(-15,Vec2f(0,0));
		} else {
			sprite.RemoveSpriteLayer("regen_vines");
			@regen_vines = sprite.addSpriteLayer("regen_vines", "RegenVines.png", 32, 32);

			if (regen_vines !is null)
			{
				Animation@ anim = regen_vines.addAnimation("default", 0, false);
				int[] frames = {0};
				anim.AddFrames(frames);
				regen_vines.SetRelativeZ(1.0f);
				regen_vines.SetOffset(Vec2f(0,0));
			}
		}
	}
	
	if(getGameTime() % 30 == 0){
		Heal(this,0.25f);
	}
	if(getGameTime() % 5 == 0)ParticleAnimated("HealParticle.png", this.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 1.0f, 5, -0.1f, true);
	
	if(this.get_u32("regen_buff") < getGameTime() || this.hasTag("RuneNullify")){
		this.Untag("RegenVines");
		this.RemoveScript("RegenVines.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("regen_vines");
		}
	}

}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("stone_shield");
	}
}