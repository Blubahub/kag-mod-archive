

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 1);
	this.set_u8("defense",1);
	this.set_f32("speed_modifier",0.99f);

	this.set_string("character_sprite_prefix","cloth");
	
	this.Tag("can_dye");
}