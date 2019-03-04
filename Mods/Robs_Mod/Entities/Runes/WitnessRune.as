#include "RuneAffectPlayer.as";

void onInit(CBlob@ this)
{
	this.Tag("witnessrune");
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		return;
	}
	
	

	if(this.get_s16("empowerfire") > 0)this.set_s16("empowerfire",this.get_s16("empowerfire")-1);
	if(this.get_s16("timer") > 15){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") && !b.hasTag("negrunetatoo")){
					givePlayerEffectGood(this, b);
				}
			}
		}
		this.set_s16("timer",0);
	} else this.set_s16("timer",this.get_s16("timer")+1);
	
	
	return;
}