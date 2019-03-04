#include "LobbyStatsCommon.as"

#define SERVER_ONLY

u32 today = Time_MonthDate();

void onInit(CRules@ this)
{
	//ensure init
	getStats();
}

void onTick(CRules@ this)
{
	LobbyStats@ s = getStats();

	//update one player per tick (avoid flooding stats on full server)
	s32 plen = getPlayersCount();
	if (plen > 0)
	{
		CPlayer@ p = getPlayer(getGameTime() % plen);
		Seen(p);
	}

	//day ticked over?
	u32 day = Time_MonthDate();
	if (day != today)
	{
		today = day;
		s.newDay();
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Seen(player);
}

void Seen(CPlayer@ player)
{
	LobbyStats@ s = getStats();
	//if (isFreeBuild()) //free build cant rely on usernames
	//{
		s.seenPlayer(player.getCharacterName());
	//}
	//else
	//{
	//	s.seenPlayer(player.getUsername());
	//}
}
