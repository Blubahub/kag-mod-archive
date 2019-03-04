void onInit(CBlob@ this)
{
	this.getShape().SetCenterOfMassOffset(Vec2f(-1.5f, 4.5f));
	this.getShape().getConsts().transports = true;
	//this.Tag("medium weight");
	//this.server_SetTimeToDie(4.5);
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	//this.setVelocity(Vec2f(0,-0.36f));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true; //this.getTeamNum() != blob.getTeamNum();
}