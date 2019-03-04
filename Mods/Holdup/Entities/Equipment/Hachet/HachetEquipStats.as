
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type",7);
	this.set_f32("damage", 1.0f);
	this.set_f32("speed_modifier",0.9f); //Heavier equipment makes you slower
}