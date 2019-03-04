#include "GamemodeCommon.as"

void onRestart(CRules@ this)
{
	SpawnBotPlayers(this);
}

void SpawnBotPlayers(CRules@ this)
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.isBot() || player.getControls() is null)
		{
			SpawnPlayer(this, player, getSpawnPosition(player.getTeamNum()));
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (player.isBot())
	{
		SpawnPlayer(this, player, getSpawnPosition(player.getTeamNum()));
	}
}