#include "ModuleCommon.as";

void onInit(CBlob@ this)
{
	string projectile = "bullet";
	this.set_string("projectile", projectile);
	Module_Setup(this, projectile, 100);
	this.Tag("module");
	this.getSprite().getConsts().accurateLighting = true;
	//this.getSprite().SetRelativeZ(-10.0f);
	//this.getShape().getConsts().collideWhenAttached = true;
	this.getShape().getConsts().waterPasses = true;

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);
}



bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

