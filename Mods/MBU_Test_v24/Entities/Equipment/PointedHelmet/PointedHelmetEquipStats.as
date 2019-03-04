
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 5);
	
	this.Tag("full_helmet");
	
	this.set_u8("defense",2);
	
	this.set_f32("speed_modifier",0.9f); //Heavier equipment makes you slower
}