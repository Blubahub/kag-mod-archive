
void onInit(CSprite @this){
	this.SetZ(10.0f);

	CSpriteLayer@ ring = this.addSpriteLayer("ring", "db.png" , 64, 64, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (ring !is null)
	{
		Animation@ anim = ring.addAnimation("default", 0, false);
		anim.AddFrame(4);
		ring.SetRelativeZ(1.0f);
	}
}

void onTick(CSprite@ this)
{

	CSpriteLayer@ ring = this.getSpriteLayer("ring");
	if (ring !is null)
	{
		ring.RotateBy(-16, Vec2f(0,0));
	}
	CBlob@ blob = this.getBlob();
	
	if(getMap().getTile(blob.getPosition()).light <= 64 || blob.isInWater()){
		this.setRenderStyle(RenderStyle::shadow);
	} else {
		this.setRenderStyle(RenderStyle::normal);
	}
	
}