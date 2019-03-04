//Unnecessary?
void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().setDrag(0.0f);
}
void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	vel.RotateBy(4 * (this.isFacingLeft() ? -1 : 1), Vec2f());
	this.setVelocity(vel);
}