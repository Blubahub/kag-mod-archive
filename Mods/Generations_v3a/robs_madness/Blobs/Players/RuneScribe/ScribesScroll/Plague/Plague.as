#include "Hitters.as";

void onTick(CBlob @this){

	if(!this.hasTag("Plagued")){
	
		this.Tag("Plagued");
		
		if(getNet().isServer())this.Sync("Plagued",true);
		
		this.set_u32("plague_timer",getGameTime()+60);
		
		if(getNet().isServer())this.Sync("plague_timer",true);
		
		this.getSprite().PlaySound("CK_Plague", 0.80f, 1.00f); // Added by TFlippy
	}
	
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 0, 255, 0));
	
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		CSpriteLayer@ plague = sprite.getSpriteLayer("plague");

		if (plague !is null)
		{
			plague.RotateBy(-5,Vec2f(0,0));
		} else {
			sprite.RemoveSpriteLayer("plague");
			CSpriteLayer@ plague = sprite.addSpriteLayer("plague", "PlagueBolt.png", 32, 32);

			if (plague !is null)
			{
				Animation@ anim = plague.addAnimation("default", 0, true);
				int[] frames = {0};
				anim.AddFrames(frames);
				plague.SetRelativeZ(1.0f);
				plague.SetOffset(Vec2f(0,0));
			}
		}
	}
	
	ParticleAnimated("PlagueParticle.png", this.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, 0, 1.0f, 6, 0.0f, true);

	if(this.get_u32("plague_timer") < getGameTime()){
		this.set_u32("plague_timer",getGameTime()+60);
		if(!this.hasTag("undead"))this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.25f, Hitters::suddengib, true);
		if(getNet().isServer()){
			if(XORRandom(3) == 0 || this.hasTag("dead"))server_CreateBlob("plague",-2,this.getPosition()+Vec2f(32,0));
			if(XORRandom(3) == 0 || this.hasTag("dead"))server_CreateBlob("plague",-2,this.getPosition()+Vec2f(-32,0));
		}
		
		this.Untag("Plagued");
		this.RemoveScript("Plague.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("plague");
		}
	}

	if(this.hasTag("Cleanse")){
		this.Untag("Plagued");
		this.RemoveScript("Plague.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("plague");
		}
	}
}