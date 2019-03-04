
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 3);
	this.set_f32("damage", 5.0f);
	this.set_u8("speed",1);
	this.set_f32("speed_modifier",0.8f); //Heavier equipment makes you slower
}