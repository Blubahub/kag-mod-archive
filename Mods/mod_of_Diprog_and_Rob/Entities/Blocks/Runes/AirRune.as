void onInit(CBlob@ this)
{
	this.Tag("airrune");
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer() || this.isAttached())
	{
		return;
	}
	
	
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("flesh") && !b.hasTag("negrunetatoo")){
				if(b.get_s16("highjumplvl2") < 60)b.set_s16("highjumplvl2",60);
				if(b.get_s16("highjump") < 300)b.set_s16("highjump",300);
			}
		}
	}
	
	
	return;
}