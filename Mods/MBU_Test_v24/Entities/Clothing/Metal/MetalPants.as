

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 2);
	this.set_u8("defense",3);
	this.set_f32("speed_modifier",0.90f); //Heavier equipment makes you slower
	
	this.set_string("character_sprite_prefix","metal");
}