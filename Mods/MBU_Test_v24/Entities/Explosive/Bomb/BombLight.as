

void onTick(CBlob@ this)
{
	if(!this.hasTag("lit") && this.hasTag("activated")){
		this.AddScript("Bomb.as");
		this.AddScript("BombTimer.as");
		
		if(this.getSprite() !is null){
			s32 timer = 120;
		
			this.getSprite().SetAnimation("fuse");
			this.getSprite().animation.frame = this.getSprite().animation.getFramesCount() * (1.0f - (90 / 220.0f));
		}
	}
}
