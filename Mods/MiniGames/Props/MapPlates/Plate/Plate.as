void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.2f);
	this.Tag("heavy weight");
	//this.getShape().SetCenterOfMassOffset(Vec2f(0.0f, 6.0f));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

