
void onInit(CBlob@ this)
{
	
	switch(XORRandom(4)){
	
		case 0:{
			getRules().set_f32("gravity",4.0f);
		break;}
		
		case 1:{
			getRules().set_f32("gravity",3.0f);
		break;}
		
		case 2:{
			getRules().set_f32("gravity",1.0f);
		break;}
		
		case 3:{
			getRules().set_f32("gravity",0.5f);
		break;}
	
	}
	
	SColor color_red(0xffff0000);
	
	if(getRules().get_f32("gravity") < 2)client_AddToChat("Gravity has started to act up, everything is lighter!", color_red);
	else client_AddToChat("Gravity has started to act up, everthing is heavier!", color_red);
	
	if(getNet().isServer())this.server_SetTimeToDie(30);
}

void onDie(CBlob @ this){

	getRules().set_f32("gravity",2);

}