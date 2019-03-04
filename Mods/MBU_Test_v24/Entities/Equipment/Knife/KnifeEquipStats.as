
#include "Hitters.as";
#include "ModHitters.as";

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 8);
	this.set_f32("damage", 2);
	this.set_u8("hitter", Hitters::stab);
	this.set_u8("speed",6);
	this.set_f32("speed_modifier",0.99f);
	
	this.set_u8("fabric",1);
}