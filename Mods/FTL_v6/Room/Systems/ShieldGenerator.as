
void onInit(CBlob @ this){
	this.set_u8("MaxLevel",8);
	this.set_u8("Level",2);
	
	this.set_u16("Recharge",0);
}


void onTick(CBlob @ this)
{
	this.set_u16("Recharge",this.get_u16("Recharge")+this.get_f32("Power")*10.0);
	if(this.get_u16("Recharge") > 1000){
		layShield(this, 1);
		if(this.get_f32("Power") > 2)layShield(this, 2);
		if(this.get_f32("Power") > 4)layShield(this, 3);
		if(this.get_f32("Power") > 6)layShield(this, 4);
		this.set_u16("Recharge",0);
	}
}

void layShield(CBlob @ this, int Level)
{
	int direction = 1;
	
	Vec2f StartPos = this.getPosition()+Vec2f(320*direction+Level*direction*28,0);
	
	for(int i = -(5+Level);i < 5;i += 1){
		
		Vec2f CheckPos = StartPos+Vec2f(0,i*34+17+Level*17-17);
		
		bool MapFree = true;
		
		for(int k = -1;k <= 1;k++)
		for(int l = -1;l <= 1;l++){
			if(getMap().isTileSolid(getMap().getTile(CheckPos+Vec2f(k*8,l*8))))MapFree = false;
		}
		
		if(MapFree){
		
			bool shield = false;
			
			CBlob@[] blobs;
			
			getMap().getBlobsAtPosition(CheckPos, @blobs);
			
			for (u32 k = 0; k < blobs.length; k++)
			{
				CBlob@ blob = blobs[k];
				if(blob.getName() == "shield")shield = true;
			}
			
			if(!shield){
				server_CreateBlob("shield", this.getTeamNum(), CheckPos);
				break;
			}
		
		}
	}
}