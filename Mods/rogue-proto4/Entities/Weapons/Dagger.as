
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("item");
	this.Tag("weapon");
	this.Tag("melee");
	this.set_f32("damage", 2);
	this.set_string("type", "Cut Damage");
	this.set_u32("cooldown", 16);
	this.set_u32("accuracy", 70);
	this.set_u32("value", 50);
	this.getSprite().ScaleBy(Vec2f(0.4f, 0.4f));


}