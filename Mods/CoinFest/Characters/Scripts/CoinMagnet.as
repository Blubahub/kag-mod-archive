#include "GetBlobHelpers.as";

void onTick(CBlob@ this)
{
	if (!getNet().isServer())
	{
		return;
	}
	
	const float radius = 35.0f;
	CBlob@[] blobs;
	
	if (getBlobsWithTagInRadius(this.getMap(), this.getPosition(), radius, "floor coin", blobs))
	{
		Vec2f pos = this.getPosition();
		int team = this.getTeamNum();
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ coin = blobs[i];
			if (coin is null)
			{
				continue;
			}
			
			if (coin.getTeamNum() == team)
			{
				continue;
			}
			
			Vec2f coinPos = coin.getPosition();
			Vec2f diff = pos - coinPos;
			
			coin.AddForce(diff * 1.5f);
		}
	}
}