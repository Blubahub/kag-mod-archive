

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 1);
	this.set_u8("defense",0);
	this.set_f32("speed_modifier",0.97f); //Heavier equipment makes you slower

	this.set_string("character_sprite_prefix","flax");
}