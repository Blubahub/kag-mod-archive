

void onTick(CBlob @this){

	//this.getCurrentScript().tickFrequency = 1;
	
	if(!this.hasTag("Protected")){
	
		this.Tag("Protected");
	
		CSprite@ sprite = this.getSprite();
	
		if(sprite !is null){
			sprite.RemoveSpriteLayer("holyshield");
			CSpriteLayer@ holyshield = sprite.addSpriteLayer("holyshield", "HolyShield.png", 32, 32);

			if (holyshield !is null)
			{
				Animation@ anim = holyshield.addAnimation("default", 4, false);
				int[] frames = {0, 1, 2, 3};
				anim.AddFrames(frames);
				holyshield.SetRelativeZ(-1.0f);
				holyshield.SetOffset(Vec2f(0,0));
				holyshield.setRenderStyle(RenderStyle::additive);
			}
			
			sprite.RemoveSpriteLayer("holyshieldoutter");
			CSpriteLayer@ holyshieldoutter = sprite.addSpriteLayer("holyshieldoutter", "HolyShieldOutter.png", 32, 32);

			if (holyshieldoutter !is null)
			{
				Animation@ anim = holyshieldoutter.addAnimation("default", 4, false);
				int[] frames = {0, 1, 2, 3};
				anim.AddFrames(frames);
				holyshieldoutter.SetRelativeZ(1.0f);
				holyshieldoutter.SetOffset(Vec2f(0,0));
				holyshieldoutter.setRenderStyle(RenderStyle::additive);
			}
		}
		
		this.set_u32("protection_buff",getGameTime()+2);
	}

	if(this.get_u32("protection_buff") < getGameTime()){
		this.Untag("Protected");
		this.RemoveScript("BuffProtection.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("holyshield");
			sprite.RemoveSpriteLayer("holyshieldoutter");
		}
	}

}