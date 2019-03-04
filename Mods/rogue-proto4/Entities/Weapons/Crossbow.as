
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("item");
	this.Tag("weapon");
	this.Tag("ranged");
	this.set_f32("damage", 3.0f);
	this.set_string("type", "Cut Damage");
	this.set_u32("cooldown", 40);
	this.set_u32("accuracy", 70);
	this.set_u32("value", 50);
	this.set_u32("range", 30);
	this.getSprite().ScaleBy(Vec2f(0.4f, 0.4f));
	this.set_string("projectile", "bolt");
}