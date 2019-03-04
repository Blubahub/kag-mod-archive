shared class LobbyStats
{
	//direct read access vars
	u32 gamesToday;

	//indirect access vars - use the functions below for these
	u32 _games_cache;
	u32[] _gametimes_cache;

	string[] _players_cache;
	int[] _players_times_cache;

	u32[] _classes_cache;
	u32[] _teams_cache;

	//we need a way to call this once each day..
	void newDay()
	{
		//cycle
		_games_cache += gamesToday;
		gamesToday = 0;

		_players_cache.clear();
		_players_times_cache.clear();

		_gametimes_cache.clear();

		for(u32 i = 0; i < 5; i++)
			_classes_cache[i] = 0;
		for(u32 i = 0; i < 2; i++)
			_teams_cache[i] = 0;
	}

	//indirect access methods
	void gameStarted()
	{
		gamesToday++;
		_gametimes_cache.push_back(Time());
		if (_gametimes_cache.length > 5)
		{
			_gametimes_cache.removeAt(0);
		}
	}

	void seenPlayer(string username)
	{
		int i = _players_cache.length;
		while(i-- > 0)
		{
			//shred, we want to be at the back
			if (_players_cache[i] == username)
			{
				_players_cache.removeAt(i);
				_players_times_cache.removeAt(i);
				break;
			}
		}

		_players_cache.push_back(username);
		_players_times_cache.push_back(Time());
	}

	void SeenClass(u8 classnum)
	{
		if(classnum < _classes_cache.length)
			_classes_cache[classnum]++;
	}

	void SeenTeam(u8 teamnum)
	{
		if(teamnum < _teams_cache.length)
			_teams_cache[teamnum]++;
	}

	void GameWithPlayers(CPlayer@[]@ players, bool careaboutteams)
	{
		for(u32 i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i];
			CBlob@ b = p.getBlob();
			u8 pickedclass = 255;
			if(b !is null)
				pickedclass = b.get_u8("class pick");
			SeenClass(pickedclass);
			if(careaboutteams)
				SeenTeam(p.getTeamNum());
		}
	}

	//analytics

	//total games played
	u32 gamesTotal()
	{
		return _games_cache + gamesToday;
	}

	//all the players today
	u32 playersToday()
	{
		return _players_cache.length;
	}

	//players in the last 5 minutes
	u32 playersNow()
	{
		u32 count = 0;
		int i = _players_times_cache.length;
		while(i-- > 0)
		{
			if (_players_times_cache[i] < Time() - 5 * 60)
			{
				break;
			}
			count++;
		}
		return count;
	}

	u32 secondsBetweenGames()
	{
		if (_gametimes_cache.length < 1)
			return 0;

		u32 running_total = 0;
		//previous games
		for (uint i = 1; i < _gametimes_cache.length; i++)
		{
			u32 dif = _gametimes_cache[i] - _gametimes_cache[i - 1];
			running_total += dif;
		}
		//current wait
		running_total += (Time() - _gametimes_cache[_gametimes_cache.length - 1]);
		//average
		u32 mean = running_total / _gametimes_cache.length;

		return mean;
	}

	u32 classCount(u8 classnum)
	{
		if(classnum < _classes_cache.length)
			return _classes_cache[classnum];
		return 0;
	}

	u32 teamCount(u8 teamnum)
	{
		if(teamnum < _teams_cache.length)
			return _teams_cache[teamnum];
		return 0;
	}

	LobbyStats()
	{
		gamesToday = 0;
		_games_cache = 0;

		for(u32 i = 0; i < 5; i++)
			_classes_cache.push_back(0);
		for(u32 i = 0; i < 2; i++)
			_teams_cache.push_back(0);
	}
};

LobbyStats@ getStats()
{
	CRules@ rules = getRules();
	LobbyStats@ s = null;
	rules.get("lobbystats", @s);
	if (s is null)
	{
		LobbyStats newstats;
		rules.set("lobbystats", newstats);
		return getStats();
	}
	return s;
}
