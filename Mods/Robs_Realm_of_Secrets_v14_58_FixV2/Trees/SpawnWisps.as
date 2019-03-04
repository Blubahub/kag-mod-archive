void onTick(CBlob@ this)
{
	if(getNet().isServer())
	if(XORRandom(100000) == 0){
		int wisps = 0;
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "wisp" || b.getName() == "caged_wisp")
				{
					wisps += 1;
				}
			}
		}
		
		if(XORRandom(wisps*100) == 0){
			if (getNet().isServer())server_CreateBlob("wisp", this.getTeamNum(), this.getPosition()); 
		}
	}
}