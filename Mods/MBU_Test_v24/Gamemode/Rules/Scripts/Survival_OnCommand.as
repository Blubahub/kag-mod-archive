#include "AbilityCommon.as";

void onInit(CRules @this){
	this.addCommandID("reset_abilities");
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("reset_abilities"))
	{
		u16 player_id = params.read_netid();

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null)
		{
			return;
		}
		
		removeAbilities(player);

	}
}