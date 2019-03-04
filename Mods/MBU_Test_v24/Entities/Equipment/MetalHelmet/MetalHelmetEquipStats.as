
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 5);

	this.set_u8("defense",4);
	
	this.Tag("full_helmet");
	
	this.set_f32("speed_modifier",0.90f); //Heavier equipment makes you slower
}