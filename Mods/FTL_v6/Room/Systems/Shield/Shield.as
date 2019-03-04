#include "Hitters.as";

void onInit(CBlob@ this)
{

	CShape@ shape = this.getShape();
	if (shape is null) return;

	shape.SetRotationsAllowed(false);
	shape.SetStatic(true);
	
	ShapeConsts@ consts = shape.getConsts();
	if (consts is null) return;

	consts.collideWhenAttached = false;
	consts.waterPasses = true;
	consts.mapCollisions = false;
	
	this.SetLight(true);
	this.SetLightRadius(16);
	this.SetLightColor(SColor(255, 0, 255, 255));

	if(this.getSprite() !is null)
	this.getSprite().setRenderStyle(RenderStyle::additive);
	
	this.server_SetTimeToDie(20);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}