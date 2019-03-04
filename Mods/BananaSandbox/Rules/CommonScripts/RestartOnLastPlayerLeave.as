// Next Map after all players have left

#define SERVER_ONLY

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if(getPlayerCount() == 0)
	{
		LoadNextMap();
		print("ALL PLAYERS LEFT. LOADING NEXT MAP");
	}
}
