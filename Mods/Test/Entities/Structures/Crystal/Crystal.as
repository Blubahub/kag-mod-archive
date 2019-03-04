#include "MapFlags.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetStatic(true);
    this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().SetZ(-20); //background

	this.Tag("builder always hit");

	this.SetLight(true);
	this.SetLightRadius(256.0f);
	this.SetLightColor(SColor(255, 45 + XORRandom(25), 125 + XORRandom(100), 220 + XORRandom(35)));

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;	
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}