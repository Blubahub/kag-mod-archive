
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type",9);
	this.set_f32("damage", 1.0f);
	this.set_u8("speed",1);
	this.set_f32("speed_modifier",0.95f); //Heavier equipment makes you slower
}