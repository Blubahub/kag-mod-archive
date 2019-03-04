
#include "Hitters.as";
#include "ModHitters.as";

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 1);
	this.set_f32("damage", 1.0f);
	this.set_u8("hitter", Hitters::blunt);
	this.set_u8("speed",5);
	this.Tag("two_handed");
}