void onInit( CBlob@ this )
{
	this.getShape().getConsts().collideWhenAttached = true;
	this.getShape().SetOffset(Vec2f(0.0,-6.0));
}