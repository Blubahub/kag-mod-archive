#include "MapFlags.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().mapCollisions = false;
    this.getSprite().getConsts().accurateLighting = true;  
	// this.getSprite().SetZ(800); //background

	this.Tag("builder always hit");
	this.Tag("ignore blocking actors");

	this.SetLight(true);
	this.SetLightRadius(72.0f);
	this.SetLightColor(SColor(255, 255, 240, 210));
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}