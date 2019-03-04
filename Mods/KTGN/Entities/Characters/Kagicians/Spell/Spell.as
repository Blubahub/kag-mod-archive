void onInit(CBlob@ this)
{
	//Nothing yet.
	if(getNet().isServer())
	{
		this.server_SetTimeToDie(7.0f);
	}
	this.getShape().getConsts().bullet = true;
	CSprite@ sprite = this.getSprite();
	Animation@ anim = sprite.addAnimation("Explode", 0, false);
	anim.AddFrame(3);
}
void onTick(CBlob@ this)
{
	if(!this.isOnGround() && !this.getShape().isStatic())
	{
		this.setAngleDegrees(this.getVelocity().Angle() * -1 + (this.isFacingLeft() ? 180 : 0));
	}
}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("player") || blob.hasTag("flesh") || this.getName() == blob.getName())
	{
		return false;
	}
	else
	{
		return true;
	}
}