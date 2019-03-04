#include "Hitters.as"


void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.getBlob().server_SetTimeToDie(60 * 5); // timeout
}

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
}