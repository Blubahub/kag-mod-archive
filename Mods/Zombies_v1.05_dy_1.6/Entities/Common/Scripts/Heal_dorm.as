#include "MigrantCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	f32 dorm_heal_amount = getRules().get_f32("dorm_heal_amount");
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius( this.getPosition(), this.getRadius(), @blobsInRadius ))
	{
		const u8 teamNum = this.getTeamNum();
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (isRoomFullOfMigrants(this) && this.getTeamNum() == teamNum && b.getHealth() < b.getInitialHealth() && b.hasTag("flesh") && !b.hasTag("dead"))
			{								  
				b.server_Heal( dorm_heal_amount );
				b.getSprite().PlaySound( "/Heart.ogg" );
			}
		}
	}
}
