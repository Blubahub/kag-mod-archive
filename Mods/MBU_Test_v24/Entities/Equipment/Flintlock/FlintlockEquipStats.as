
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type",10);
	this.set_f32("damage", 2.0f);
	this.set_f32("speed_modifier",0.98f); //Heavier equipment makes you slower
	
	this.set_f32("range", 300.0f);
	this.set_s8("bullets",0);
	this.set_s8("bullet_max",1);
	this.set_string("sound_fire","FlintlockPistolFire.ogg");
	this.set_string("sound_reload","FlintlockPistolReload.ogg");
	this.set_Vec2f("barrel_offset",Vec2f(12,-3));
}