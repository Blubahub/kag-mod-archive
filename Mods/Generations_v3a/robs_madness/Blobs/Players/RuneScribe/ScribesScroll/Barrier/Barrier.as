

void onTick(CBlob @this){

	if(!this.hasTag("Barrier")){
	
		this.Tag("Barrier");
		
		if(getNet().isServer())this.Sync("Barrier",true);
	}
	
	CSprite@ sprite = this.getSprite();

	if(sprite !is null)
	if(sprite.getSpriteLayer("barrier") is null || sprite.getSpriteLayer("barrieroutter") is null){
		sprite.RemoveSpriteLayer("barrier");
		CSpriteLayer@ barrier = sprite.addSpriteLayer("barrier", "Barrier.png", 32, 32);

		if (barrier !is null)
		{
			Animation@ anim = barrier.addAnimation("default", 4, false);
			int[] frames = {0, 1, 2, 3};
			anim.AddFrames(frames);
			barrier.SetRelativeZ(-1.0f);
			barrier.SetOffset(Vec2f(0,0));
			barrier.setRenderStyle(RenderStyle::additive);
		}
		
		sprite.RemoveSpriteLayer("barrieroutter");
		CSpriteLayer@ barrieroutter = sprite.addSpriteLayer("barrieroutter", "BarrierOutter.png", 32, 32);

		if (barrieroutter !is null)
		{
			Animation@ anim = barrieroutter.addAnimation("default", 4, false);
			int[] frames = {0, 1, 2, 3};
			anim.AddFrames(frames);
			barrieroutter.SetRelativeZ(1.0f);
			barrieroutter.SetOffset(Vec2f(0,0));
		}
	}

	
	if(this.hasTag("BarrierPopped") || this.hasTag("RuneNullify")){
		this.Untag("Barrier");
		this.Untag("BarrierPopped");
		this.RemoveScript("Barrier.as");
		
		Sound::Play("BarrierPop.ogg", this.getPosition());
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("barrier");
			sprite.RemoveSpriteLayer("barrieroutter");
		}
	}
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("barrier");
		sprite.RemoveSpriteLayer("barrieroutter");
	}
	this.Untag("Barrier");
}