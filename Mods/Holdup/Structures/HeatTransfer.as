
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
	
	this.set_s16("heat",0);
	this.Tag("takes_heat");
}

void onTick(CBlob@ this)
{

	if(this.get_s16("heat") >= 1){
		CBlob@[] blobsInRadius;	
		if (getMap().getBlobsInRadius(this.getPosition()+Vec2f(0,-32), 8, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("takes_heat")){
					if(b.get_s16("heat") < this.get_s16("heat"))b.set_s16("heat",this.get_s16("heat"));
					if(getNet().isServer())b.Sync("heat",true);
				}
			}
		}
	}
	
	if(this.get_s16("heat") >= 1){
		this.set_s16("heat",this.get_s16("heat")-1);
	}
	
	if(getNet().isServer())this.Sync("heat",true);
}