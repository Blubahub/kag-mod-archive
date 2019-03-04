void onDie(CBlob@ this)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getName() == "wisp")
			{
				if(XORRandom(10) == 0)b.Tag("tree_merge");
			}
		}
	}
}