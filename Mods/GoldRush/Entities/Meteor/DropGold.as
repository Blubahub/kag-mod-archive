#include "GR_Common.as";

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		CBlob@ gold = server_CreateBlob( "mat_gold", -1, this.getPosition());
		if (gold !is null)
		{
			gold.server_SetQuantity(XORRandom(necro_drop()));
		}
	}
		
}