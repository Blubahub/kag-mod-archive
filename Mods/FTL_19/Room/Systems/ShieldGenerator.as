
int ShieldWidth = 2;

void onInit(CBlob @ this){
	this.set_u8("MaxLevel",8);
	this.set_u8("Level",2);
	
	this.set_u16("Recharge",0);
}


void onTick(CBlob @ this)
{
	if(this.get_f32("Power") > 0)this.set_u16("Recharge",this.get_u16("Recharge")+this.get_f32("Power")*10.0);
	if(this.get_u16("Recharge") > 4000){
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
	
	if(this.getTeamNum() != 0)direction = -1;
	
	Vec2f StartPos = this.getPosition()+Vec2f(320*direction+Level*direction*28,0);
	
	for(int i = -(ShieldWidth+Level);i < ShieldWidth;i += 1){
		
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
				if(getNet().isServer())server_CreateBlob("shield", this.getTeamNum(), CheckPos);
				break;
			}
		
		}
	}
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ arm_rest = this.addSpriteLayer("arm_rest", this.getFilename() , 40, 40, blob.getTeamNum(), blob.getSkinNum());

	if (arm_rest !is null)
	{
		Animation@ anim = arm_rest.addAnimation("default", 0, false);
		anim.AddFrame(1);
		//arm_rest.SetOffset(Vec2f(3.0f, -7.0f));
		arm_rest.SetRelativeZ(100);
	}
	
	// this.SetEmitSound("/ShieldGenerator.ogg");
	// this.SetEmitSoundPaused(false);
	// this.SetEmitSoundSpeed(1);
	// this.SetEmitSoundVolume(0.1f);
}