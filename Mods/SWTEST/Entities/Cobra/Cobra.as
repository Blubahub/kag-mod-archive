#include "BarrelCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("fire barrel");
	this.Tag("barrel");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);

	f32 range = 1.0f;
	f32 accuracy = 1.0f;
	this.set_f32("range", range);
	this.set_f32("accuracy", accuracy);
	//Barrel_Setup(this, range, accuracy);

	this.getSprite().getConsts().accurateLighting = true;
	shape.getConsts().waterPasses = true;
}
