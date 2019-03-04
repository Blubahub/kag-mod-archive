
#include "Hitters.as";
#include "ModHitters.as";

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type",2);
	this.set_f32("damage", 2.0f);
	this.set_u8("hitter", Hitters::pick);
	this.set_u8("speed",7);
	this.set_f32("speed_modifier",0.975f); //Heavier equipment makes you slower
	
	this.set_u8("fabric",2);
}