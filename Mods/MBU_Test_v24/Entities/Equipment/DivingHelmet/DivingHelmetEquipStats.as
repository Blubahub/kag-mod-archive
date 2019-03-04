
void onInit(CBlob @ this){

	this.set_u8("equip_slot", 5);
	
	this.Tag("full_helmet");
	this.Tag("air_proof");
	
	this.set_u8("defense",1);
	
	this.set_f32("speed_modifier",0.9f); //Heavier equipment makes you slower
}