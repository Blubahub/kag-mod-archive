#include "ClassesCommon.as"

bool isScoreReached(const int cap)
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.getKills() >= cap)
		{
			return true;
		}
	}
	return false;
}

void KillPlayers()
{
	CBlob@[] players;
	if (getBlobsByTag("player", @players))
	{
		for (uint i = 0; i < players.length; i++)
		{
			CBlob@ p = players[i];
			p.server_Die();
		}
	}
}

void ResetScores(const bool score = true , const bool kills = true , const bool deaths = true)
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (score) player.setScore(0);
		if (kills) player.setKills(0);
		if (deaths) player.setDeaths(0);
	}
}

CBlob@ SpawnPlayer(CRules@ this, CPlayer@ player, Vec2f position)
{
	if (player !is null)
	{
		// remove previous players blob
		CBlob @blob = player.getBlob();
		if (blob !is null)
		{
			CBlob @blob = player.getBlob();
			blob.server_SetPlayer(null);
			blob.server_Die();
		}

		const u8 team = player.getTeamNum();
		const u8 classIndex = player.getClassNum();

		CBlob @newBlob = server_CreateBlobNoInit("soldier");
		if (newBlob !is null)
		{
			newBlob.server_setTeamNum(team);
			newBlob.setPosition(position);
			newBlob.server_SetPlayer(player);
			newBlob.set_u8("class", classIndex);
			if(getRules().exists("spawn_skin"))
				newBlob.set_u8("skin", getRules().get_u8("spawn_skin"));
			newBlob.Init();
			if (newBlob.isBot())
			{
				newBlob.getBrain().server_SetActive(true);
			}
		}

		return newBlob;
	}

	return null;
}

string getTeamMarkerString(const u8 team)
{
	switch (team)
	{
		case 0: return "blue spawn";
		case 1: return "red spawn";
		case 2: return "green spawn";
		case 3: return "pink spawn";
		default: return "neutral spawn";
	}
	return "unknown";
}

funcdef Vec2f SPAWNPOSITION_CALLBACK(const u8);

Vec2f getSpawnPosition(const u8 team)
{
	SPAWNPOSITION_CALLBACK@ func;
	getRules().get("spawn position", @func);
	if (func !is null)
	{
		return func(team);
	}
	else
	{
		warn("spawn position function not set");
		return getMapCenter();
	}
}

Vec2f getMapCenter()
{
	CMap@ map = getMap();
	return Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f);
}

void CalcPlayerCounts(int &out count, int &out deadcount)
{
	count = 0;
	deadcount = 0;
	CBlob@[] players;
	if (getBlobsByTag("player", @players))
	{
		for (uint step = 0; step < players.length; ++step)
		{
			CBlob@ playerBlob = players[step];
			const bool dead = playerBlob.hasTag("dead");
			// count dead
			count++;
			if (dead)
			{
				deadcount++;
			}
		}
	}
}

funcdef void TEAM_FUNCTION(int index, int &out team, int &out classnum);

void FillBots(TEAM_FUNCTION@ team_function, const int count)
{
	// fill server with bots

	const int botsCount = Maths::Max(0, Maths::Min(count, sv_maxplayers) - sv_max_localplayers);
	printf("Adding " + botsCount + " bots " + sv_maxplayers);
	for (uint i = 0; i < botsCount; i++)
	{
		CBlob @newBlob = server_CreateBlobNoInit("soldier");
		if (newBlob !is null)
		{
			newBlob.Tag("mook");
			int team, classnum;
			team_function(i, team, classnum);
			newBlob.server_setTeamNum(team);
			newBlob.setPosition(getSpawnPosition(newBlob.getTeamNum()));
			newBlob.set_u8("class", classnum);
			newBlob.Init();
			newBlob.getBrain().server_SetActive(true);
		}

	}
}

Random _clrandom(Time());
int getRandomBotClass()
{
	int r = _clrandom.NextRanged(4);

	if (r == 0)
	{
		r = getClassIndexByName("Commando");
	}
	else if (r == 1)
	{
		r = getClassIndexByName("Sniper");
	}
	else if (r == 2)
	{
		r = getClassIndexByName("Medic");
	}
	else if (r == 3)
	{
		r = getClassIndexByName("Demolitions");
	}	
	else
	{
		r = getClassIndexByName("Assault");
	}
	return r;
}

int getRandomSkirmishClass()
{
	int r = _clrandom.NextRanged(4);

	if (r == 0)
	{
		r = getClassIndexByName("Commando");
	}
	else if (r == 1)
	{
		r = getClassIndexByName("Sniper");
	}
	else if (r == 2)
	{
		r = getClassIndexByName("Demolitions");
	}
	else
	{
		r = getClassIndexByName("Assault");
	}
	return r;
}

int getRandomSkirmishUniqueBotClass()
{
	bool gotit = false;
	int failsafe = 0;
	int r;
	while (!gotit && failsafe < 9)
	{
		r = getRandomSkirmishClass();
		gotit = true;
		failsafe++;
		//printf("r " + r + " " + failsafe);
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (r == player.getClassNum()){
				gotit = false;
				break;
			}
		}
	}
	return r;
}

bool isMusicOn()
{
	return s_gamemusic && s_musicvolume > 0.0f;
}

int getSmallerTeam()
{
	int[] team_count = {0, 0};
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		u32 team = getPlayer(i).getTeamNum();
		if (team < 2)
			team_count[team]++;
	}
	return team_count[0] < team_count[1] ? 0 : 1;
}

int getFreeClass(int team)
{
	bool[] class_taken;
	for (u32 i = 0; i <= Soldier::COMMANDO; i++)
	{
		class_taken.push_back(false);
	}

	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.getTeamNum() != team) continue;

		u32 c = p.getClassNum();
		if (c <= Soldier::COMMANDO)
			class_taken[c] = true;
	}

	for (u32 i = 0; i <= Soldier::COMMANDO; i++)
	{
		if (!class_taken[i]){
			printf("free class " + i + " for team " + team);
			return i;
		}
	}
	return 0;
}

int getFreeSkirmishTeam()
{
	int[] team_count = {0, 0, 0, 0};
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		u32 team = getPlayer(i).getTeamNum();
		if (team < 4)
			team_count[team]++;
	}
	for (u32 i = 0; i < 4; i++)
	{
		if (team_count[i] == 0)
			return i;
	}
	return 255;
}