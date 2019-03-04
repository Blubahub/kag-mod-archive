#include "DecayCommon.as";

#define SERVER_ONLY

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 84; // opt
}

void onTick( CBlob@ this )
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 32, @blobsInRadius))
	{
		int lanternCount = 0;
		int burgerCount = 0;

		Vec2f pos = this.getPosition();
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is this && b.getName() == "lantern")
			{
				lanternCount += 1;
				if (lanternCount > 8)
				{
					b.server_Die();
				}
			}
			else if (b !is this && b.getName() == "burger")
			{
				burgerCount += 1;
				if (burgerCount > 8)
				{
					b.server_Die();
				}
			}
		}
	}
}