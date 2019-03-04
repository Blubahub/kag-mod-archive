#include "Hitters.as";

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 3);
	this.set_f32("damage", 2.0f);
	this.set_u8("hitter", Hitters::muscles);
	this.set_u8("speed",5);
	this.set_f32("speed_modifier",0.95f); //Heavier equipment makes you slower
}