
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("item");
	this.Tag("weapon");
	this.Tag("melee");
	this.set_f32("damage", 2);
	this.set_string("type", "Cut Damage");
	this.set_u32("cooldown", 13);
	this.set_u32("accuracy", 70);
	this.set_u32("value", 50);
	this.getSprite().ScaleBy(Vec2f(0.4f, 0.4f));


}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	print("attached");
	attached.set_u32("cooldown", this.get_u32("cooldown"));
	attached.set_f32("damage", this.get_f32("damage"));
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	print("detached");
	detached.set_u32("cooldown", detached.get_u32("hit_rate"));
	detached.set_f32("damage", detached.get_f32("hit_power"));
}

void onTick(CBlob@ this)
{
}

void onDie(CBlob@ this)
{

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
}

void onInit(CSprite@ this)
{
}
