#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("lightrune");
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer() || this.isAttached())
	{
		return;
	}

	if(this.get_s16("timer") > 15){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") && !b.hasTag("negrunetatoo")){
				if(b.hasTag("evil"))
					this.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::suddengib, false);
				}
			}
		}
		this.set_s16("timer",0);
	} else this.set_s16("timer",this.get_s16("timer")+1);
	
	
	return;
}