#include "Explosion.as";

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData ){
	if (victim !is null )
	{
		CBlob@ blob = victim.getBlob();
		if (blob !is null && blob.getName() == "wizard")
		{
			if(getNet().isServer())
			{
				victim.lastBlobName = "knight";
				server_CreateBlob( "soulstoneshard", 1, blob.getPosition() );
			}
		}
		else if (blob !is null)
		{
			if (blob.getName() == "heavyknight" || blob.getName() == "crossbowman" || blob.getName() == "druid" || blob.getName() == "Necromancer" || blob.getName() == "hunter" || blob.getName() == "shadowman")
			{
				victim.lastBlobName = "knight";
			}
		}
	}
}