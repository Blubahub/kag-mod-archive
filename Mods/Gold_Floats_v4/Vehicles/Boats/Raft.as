// Boat logic

const f32 SPEED = 30.0f;

void onInit(CBlob@ this)
{
	this.getShape().SetOffset(Vec2f(0, 7));
	this.getShape().SetCenterOfMassOffset(Vec2f(0.0f, 0));
	this.getShape().getConsts().transports = true;
	// override icon
	AddIconToken("$" + this.getName() + "$", "VehicleIcons.png", Vec2f(16, 16), 6);
	this.Tag("heavy weight");
	
	getMap().server_AddMovingSector(Vec2f(0.0f, 0.0f), Vec2f(24.0f, 48.0f), "ladder", this.getNetworkID());
	this.Tag("MadeSector");
}

void onTick(CBlob@ this)
{
	// just drift in the general direction
	if (this.isInWater())
	{
		this.AddForce(Vec2f(this.isFacingLeft() ? -SPEED : SPEED, 0.0f));
	}
	if(this.isAttached()){
		getMap().RemoveSectorsAtPosition(this.getPosition());
		this.Untag("MadeSector");
	} else if(!this.hasTag("MadeSector")){
		getMap().server_AddMovingSector(Vec2f(0.0f, 0.0f), Vec2f(24.0f, 64.0f), "ladder", this.getNetworkID());
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.isOnGround() || this.isOnWall();
}

