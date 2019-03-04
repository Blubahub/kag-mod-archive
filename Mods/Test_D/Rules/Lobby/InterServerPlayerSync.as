/////////////////////////////////////
// inter-server player choice
//  synchronisation functions

//internal helpers
namespace internal
{
	const string separator = "}&&{";
	const string mini_separator = ":||:";

	CPlayer@ getPlayerByCharacterName(string charname)
	{
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);

			if(p.getCharacterName() == charname)
				return p;
		}
		return null;
	}

	string _BuildPlayerSyncStringFrom(CPlayer@ p)
	{
		string username = p.getUsername();

		//if(isFreeBuild())
		//	username = p.getCharacterName();

		u8 pickedclass = 255;
		u32 bet = 0;
		CBlob@ b = p.getBlob();
		if (b !is null)
		{
			pickedclass = b.get_u8("class pick");
			bet = b.get_u32("bet");
		}
		return username + mini_separator + pickedclass + mini_separator + p.getTeamNum() + mini_separator + bet;
	}

	void _ApplyPlayerSyncString(string syncstring)
	{
		string[] chunks = syncstring.split(mini_separator);
		if (chunks.length < 4)
		{
			warn("bad player sync string : " + syncstring);
			return;
		}

		//get the player by username
		string username = chunks[0];

		CPlayer@ p = getPlayerByUsername(username);

		//if(isFreeBuild())
		//	@p = getPlayerByCharacterName(username);

		if (p is null) return;

		p.Tag("joined");

		//read the class number
		u8 classnum = parseInt(chunks[1]);
		p.set_u8("class pick", classnum);
		p.server_setClassNum(classnum);

		//read the team number
		u8 teamnum = parseInt(chunks[2]);
		if (teamnum == 255)
		{
			p.server_setTeamNum(getPlayerIndex(p)); //skirmish style teams
		}
		else
		{
			p.server_setTeamNum(teamnum); 			//teams synced from lobby (campaign)
		}

		//read the players bet
		u32 bet = parseInt(chunks[3]);
		p.set_u32("bet", bet);
	}

	void _KickPlayersNotInChunks(string[]@ chunks)
	{
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);

			if (p.isBot()) continue;

			bool found = false;
			for (uint j = 0; j < chunks.length; j++)
			{
				if(chunks[j] == "") continue;

				string[] sub_chunks = chunks[j].split(mini_separator);
				if (sub_chunks[0] == p.getUsername())
				{
					found = true;
					break;
				}
				/*if (isFreeBuild() && sub_chunks[0] == p.getCharacterName())
				{
					found = true;
					break;
				}*/
			}
			if (!found)
			{
				Backend::RedirectPlayerBackToLobby(getRules(), p);
			}
		}
	}
}

//actual interface

string BuildPlayerSyncStringFrom(CPlayer@[]@ players)
{
	string[] ret;
	for (uint i = 0; i < players.length; i++)
	{
		ret.push_back(internal::_BuildPlayerSyncStringFrom(players[i]));
	}
	return join(ret, internal::separator);
}

void ApplyPlayersSyncString(string syncstring)
{
	if (syncstring == "") return;

	string[] chunks = syncstring.split(internal::separator);
	for (uint i = 0; i < chunks.length; i++)
	{
		if (chunks[i] != "")
		{
			internal::_ApplyPlayerSyncString(chunks[i]);
		}
	}
	internal::_KickPlayersNotInChunks(chunks);
}

u32 countPlayersInSyncString(string syncstring)
{
	if (syncstring == "") return 0;

	return syncstring.split(internal::separator).length;
}
