
#include "LoadEvent.as";

void onInit(CBlob @ this){

	this.set_string("filename","event"+XORRandom(11)+".png");
	this.set_u8("team",1);
	
	if(getNet().isServer())this.Sync("filename",true);
	
	this.set_u8("Y",0);
}

void onTick(CBlob @ this){

	this.set_u16("timer",this.get_u16("timer")+1);

	
	if(this.get_u16("timer") == 10*30){
		Sound::Play("ftl_jump.ogg");
		SetScreenFlash(255, 255, 255, 255);
	}
	if(this.get_u16("timer") >= 10*30 && this.get_u8("Y") < getMap().tilemapheight){
		wipeWorld(getMap(),this.get_u8("Y"),this.get_u8("Y")+5);
		
		
		this.set_u8("Y",this.get_u8("Y")+5);
	}
	
	
	
	if(this.get_u16("timer") == 20*30){
		SetScreenFlash(255, 255, 255, 255);
		loadEvent(getMap(),this.get_string("filename"),this.get_u8("team"));
		
		CBlob@[] blobs;
	
		getBlobsByName("reactorroom", blobs);
		getBlobsByName("turret", blobs);
		
		for(int i = 0;i < blobs.length();i++){
			if(blobs[i].getName() == "reactorroom")blobs[i].set_u16("FTLDrive",0);
			if(blobs[i].getName() == "turret")blobs[i].set_u16("charge_time",0);
		}

		Sound::Play("ftl_end.ogg");
		
		if(getNet().isServer())this.server_Die();
	}
}