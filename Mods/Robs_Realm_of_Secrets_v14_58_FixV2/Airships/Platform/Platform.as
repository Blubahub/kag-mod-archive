
void onInit(CBlob@ this)
{
	this.getShape().SetOffset(Vec2f(0, 7));
	this.getShape().SetCenterOfMassOffset(Vec2f(0.0f, 0));
	this.getShape().getConsts().transports = true;
	this.Tag("heavy weight");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (this.isOnGround() || this.isOnWall());
}