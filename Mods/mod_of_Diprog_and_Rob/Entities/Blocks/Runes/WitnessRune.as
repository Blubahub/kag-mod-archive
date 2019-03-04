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
	
	int range = 80;
	
	CBlob@[] runes;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @runes)) 
	{
		for (uint i = 0; i < runes.length; i++)
		{
			CBlob@ b = runes[i];
			if(b.hasTag("witnessrune")){
				range = range*2;
			}
		}
	}
	
	if(this.get_s16("timer") > 15){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), range, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if((b.hasTag("flesh") || b.hasTag("plant") || b.hasTag("polymorphed")) && !b.hasTag("negrunetatoo")){
					givePlayerEffectGood(this, b);
				}
			}
		}
		this.set_s16("timer",0);
	} else this.set_s16("timer",this.get_s16("timer")+1);
	
	
	return;
}