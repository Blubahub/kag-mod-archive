
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
	if (victim !is null)
	{
		if (killer !is null)
		{
			if (killer.getBlob() !is null)
			{
				killer.getBlob().Tag(victim.getUsername());
			}
		}
	}
}