
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type",10);
	this.set_f32("damage", 4.0f);
	this.set_f32("speed_modifier",0.97f); //Heavier equipment makes you slower
	
	this.set_f32("range", 240.0f);
	this.set_s8("bullets",0);
	this.set_s8("bullet_max",6);
	this.set_string("sound_fire","RevolverFire.ogg");
	this.set_string("sound_reload","RevolverReload.ogg");
	this.set_Vec2f("barrel_offset",Vec2f(12,-3));
}