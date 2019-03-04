namespace Campaign
{
	const string SYNC_CMD = "campaign data";
	const string sync_ids_name = SYNC_CMD + "_bs";
	CBitStream _syncBs;

	shared class Data
	{
		string[] battles;
		string[] allBattles;
		int[] team;
		int battleIndex;
		int battlesCount;

		Data()
		{
			battleIndex = 0;
		}
	};

	Data@ InitCampaign(CRules@ this)
	{
		Data data;
		this.set("campaign", @data);
		this.addCommandID(SYNC_CMD);
		_syncBs.Clear();
		return getCampaign(this);
	}

	Data@ getCampaign(CRules@ this)
	{
		Data@ data;
		this.get("campaign", @data);
		return data;
	}

	string getCurrentBattle(CRules@ this)
	{
		Data@ data = getCampaign(this);
		return data.battles[data.battleIndex];
	}

	void Reset(Data@ data)
	{
		// randomize battles

		Random _r(Time());
		string[] temp = data.allBattles;
		data.battles.clear();
		int index;
		while (data.battles.length < data.battlesCount)
		{
			index = _r.NextRanged(temp.length);
			data.battles.push_back(temp[index]);
			temp.removeAt(index);
		}

		// center battle
		data.battleIndex = 0;
		data.team.clear();
		for (uint i = 0; i < data.battles.length; i++)
		{
			data.team.push_back(-1);
		}
		_syncBs.Clear();
	}

	void Sync(CRules@ this, Data@ data)
	{
		if (getNet().isServer())
		{
			_syncBs.Clear();

			_syncBs.write_u16(data.battles.length);
			for (uint i = 0; i < data.battles.length; i++)
			{
				_syncBs.write_string(data.battles[i]);
			}

			_syncBs.write_u16(data.team.length);
			for (uint i = 0; i < data.team.length; i++)
			{
				_syncBs.write_s16(data.team[i]);
			}

			_syncBs.write_u16(data.battleIndex);

			this.set_CBitStream(sync_ids_name, _syncBs);
			this.Sync(sync_ids_name, true);
		}
		else
		{
			this.get_CBitStream(sync_ids_name, _syncBs);
			if (_syncBs.getBytesUsed() > 0)
			{
				_syncBs.ResetBitIndex();

				data.battles.clear();
				const u16 battles = _syncBs.read_u16();
				for (uint i = 0; i < battles; i++)
				{
					data.battles.push_back(_syncBs.read_string());
				}

				data.team.clear();
				const u16 teams = _syncBs.read_u16();
				for (uint i = 0; i < teams; i++)
				{
					data.team.push_back(_syncBs.read_s16());
				}

				data.battleIndex = _syncBs.read_u16();
			}
			else
			{
				data.battles.clear();
				data.team.clear();
				data.battleIndex = 0;
			}
		}
	}

	void SetWinMsg(CRules@ this, const string &in msg)
	{
		this.set_string("win msg", msg);
		this.Sync("win msg", true);
	}

	int getTeamScore(Data@ data, const int team)
	{
		int score = 0;
		for (uint i = 0; i < data.battles.length; i++)
		{
			if (data.team[i] == team)
			{
				score++;
			}
		}
		return score;
	}

	int getWinningTeam(Data@ data)
	{
		int team = -1;

		int beerscore = getTeamScore(data, 0);
		int winescore = getTeamScore(data, 1);
		if(beerscore > winescore)
			team = 0;
		if(winescore > beerscore)
			team = 1;

		return team;
	}

	bool isSeriesEnded(Data@ data)
	{
		const int team1score = getTeamScore(data, 0);
		const int team2score = getTeamScore(data, 1);
		const int scoreThreshold = Maths::Floor(data.battles.length / 2) + 1;
		const int gamesRemaining = data.battles.length - data.battleIndex;

		// not initialized?
		if (getPlayersCount() == 0 || data.battles.length == 0)
		{
			return false;
		}

		//one team won too much
		if(team1score > team2score + gamesRemaining || team2score > team1score + gamesRemaining)
		{
			return true;
		}

		//fallback cases
		return getRules().getTeamWon() == -10 || data.battleIndex > data.battles.length - 1;
	}
}
