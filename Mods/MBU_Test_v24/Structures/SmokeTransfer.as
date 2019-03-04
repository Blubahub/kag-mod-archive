
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
	
	this.set_s16("smoke",0);
	this.Tag("takes_smoke");
}

void onTick(CBlob@ this)
{

	bool transfered = false;

	if(this.get_s16("smoke") >= 10){
		CBlob@[] blobsInRadius;	
		if (getMap().getBlobsInRadius(this.getPosition()+Vec2f(0,-32), 8, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("takes_smoke")){
					this.set_s16("smoke",this.get_s16("smoke")-10);
					b.set_s16("smoke",b.get_s16("smoke")+10);
					transfered = true;
				}
			}
		}
	} else {
		if(this.get_s16("smoke") >= 1){
			CBlob@[] blobsInRadius;	
			if (getMap().getBlobsInRadius(this.getPosition()+Vec2f(0,-32), 8, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("takes_smoke")){
						this.set_s16("smoke",this.get_s16("smoke")-1);
						b.set_s16("smoke",b.get_s16("smoke")+1);
						
						transfered = true;
					}
				}
			}
		}
	}
	
	if(getNet().isServer())
	if(!transfered && this.get_s16("smoke") >= 1){
		for(int i = 0; i < this.get_s16("smoke"); i++){
			CBlob@ smokey = server_CreateBlobNoInit("smoke");
			smokey.setPosition(this.getPosition() + Vec2f(0, -10));
			smokey.setVelocity(Vec2f((XORRandom(1000)-500.0f)/2000.0f,-1));
			smokey.server_setTeamNum(-1);
			smokey.Init();
			
			this.set_s16("smoke",this.get_s16("smoke")-1);
		}
	}
}