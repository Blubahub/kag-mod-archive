
#include "Health.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(this.getPosition(), this.getRadius(), @blobsInRadius))
	{
		const u8 teamNum = this.getTeamNum();
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (this.getTeamNum() == teamNum && Health(b) < MaxHealth(b) && b.hasTag("flesh") && !b.hasTag("dead"))
			{
				Heal(b,1);
				b.getSprite().PlaySound("/Heart.ogg");
			}
		}
	}
}
