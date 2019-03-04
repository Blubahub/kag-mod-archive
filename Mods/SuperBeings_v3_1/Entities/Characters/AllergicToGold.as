#include "Hitters.as";

void onTick(CBlob@ this)
{
	if(XORRandom(10) == 0){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("gold") || b.getName() == "mat_gold")
				{
					if(this.getName() == "darkbeing")this.set_s16("power",this.get_s16("power")-1);
					else {
						this.server_Hit(this, this.getPosition(), Vec2f(), 0.25f, Hitters::suddengib);
					}
				}
			}
		}
	}
}