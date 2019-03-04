void onInit(CBlob@ this)
{
	this.Tag("hasterune");
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
				if(b.get_s16("hastelvl2") < 20)b.set_s16("hastelvl2",20);
				if(b.get_s16("haste") < 300)b.set_s16("haste",300);
			}
		}
	}
	
	
	return;
}