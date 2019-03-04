#include "PlayerStatsCommon.as"

void onInit( CRules@ this )
{
	this.addCommandID("award");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// stats init
	Stats stats;
	player.set("stats", @stats);
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isClient() && cmd == this.getCommandID("award"))
	{
		Award@[] awards;
		this.set("awards", @awards);

		u16 count = params.read_u16();
		for (uint i = 0; i < count; i++)
		{
			CPlayer@ player = getPlayerByNetworkId(params.read_netid());
			string what = params.read_string();
			printf("got award " + what);
			if (player !is null)
			{
				Award award;
				award.who_name = player.getUsername();
				award.what = what;
				awards.push_back(award);
			}
		}
	}
}
