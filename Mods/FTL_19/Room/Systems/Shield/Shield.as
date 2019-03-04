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
	this.SetLightColor(SColor(255, 152, 216, 254));

	if(this.getSprite() !is null)
	this.getSprite().setRenderStyle(RenderStyle::additive);
	
	this.server_SetTimeToDie(80);
	
	//Sound::Play("shield_generate.ogg"); //So irriating
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}