
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 5);
	
	this.set_f32("speed_modifier",0.8f); //Heavier equipment makes you slower

	this.Tag("can_dye");
	
	this.Tag("two_handed");
}