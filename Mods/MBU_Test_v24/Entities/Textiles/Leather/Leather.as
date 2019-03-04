#include "Hitters.as"

void onTick(CSprite@ this)
{
	this.SetZ(100.0f);
}

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	
}