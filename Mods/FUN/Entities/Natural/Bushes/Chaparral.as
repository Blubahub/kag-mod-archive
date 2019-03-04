#include "FUNHitters.as";

const int hitSpeed = 1*30; // every 1 sec
void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = hitSpeed;
}

void onTick(CBlob@ this)
{
	CMap@ map = this.getMap();
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius( this.getPosition(), this.getRadius()*2.0f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null && b.hasTag("flesh") && !b.hasTag("dead"))
			{
				if (this.isOverlapping(b))
				{
					this.server_Hit( b, b.getPosition(), b.getVelocity()*-1, 1.0f, FUNHitters::chaparral, true);
				}
			}
		}
	}
}