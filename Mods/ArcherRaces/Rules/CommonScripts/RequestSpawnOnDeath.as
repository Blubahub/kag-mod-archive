
// local player requests a spawn right after death

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (victim !is null && victim.isMyPlayer())
	{
		if (victim.getBlob() !is null)
		{
			victim.getBlob().ClearMenus();
		}

		victim.client_RequestSpawn();
	}
}

void onPlayerRequestSpawn( CRules@ this, CPlayer@ player )
{
	if (player !is null && player.isMyPlayer())
	{
		if (player.getBlob() !is null)
		{
			player.getBlob().ClearMenus();
		}

		player.client_RequestSpawn();
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	player.server_setTeamNum(newTeam);
}