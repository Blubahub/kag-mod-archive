

void onInit(CBlob @ this){

	this.set_u8("equip_slot", 2);
	this.set_u8("defense",0);
	this.set_f32("speed_modifier",1.00f); //Heavier equipment makes you slower
	
	this.Tag("can_dye");

}