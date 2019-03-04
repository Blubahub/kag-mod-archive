
void onInit(CBlob@ this)
{
	
	switch(XORRandom(2)){
		
		case 0:{
			getRules().set_f32("gravity",1.0f);
		break;}
		
		case 1:{
			getRules().set_f32("gravity",0.5f);
		break;}
	
	}
	
	SColor color_red(0xffff0000);
	client_AddToChat("Gravity has started to act up, everything is lighter!", color_red);
	
	if(getNet().isServer()){
		this.server_SetTimeToDie(30);
		this.Sync("gravity",true);
	}
}

void onDie(CBlob @ this){
	getRules().set_f32("gravity",2);
	if(getNet().isServer())this.Sync("gravity",true);
}