void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.RemoveSpriteLayer("forebush");
	CSpriteLayer@ forebush = this.addSpriteLayer("forebush", "NaturesGrave.png" , 98, 89, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (forebush !is null)
	{
		Animation@ anim = forebush.addAnimation("default", 0, false);
		anim.AddFrame(1);
		forebush.SetRelativeZ(1000.0f);
	}
}