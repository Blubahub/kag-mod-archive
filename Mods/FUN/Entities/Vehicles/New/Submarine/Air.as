void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius( this.getPosition(), this.getRadius() * 0.3, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.hasTag("flesh") && !b.hasTag("dead"))
			{								  
   				 b.set_s8("air_count", 60);
  			       b.set_u8("drown_timer", 2);

			}
		}
	}
}

