#include "MapFlags.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().mapCollisions = false;
    this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().SetZ(-50); //background

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.getShape().SetOffset(Vec2f(4, -4));
	
	this.Tag("builder always hit");
	// this.Tag("place norotate");
}

// bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
// {
    // return false;
// }

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// return true;
// }