#define SERVER_ONLY

#include "BiomeCommon.as"
#include "GamemodeCommon.as"
#include "States.as"
#include "Menus.as"
#include "ClassesCommon.as"
#include "Timers.as"
#include "ConfigUtils.as"
#include "CampaignCommon.as"
#include "ParachuteCommon.as"

#include "BackendCommon.as"
#include "BackendHelper.as"
#include "LobbyCommon.as"
#include "InterServerPlayerSync.as"
#include "BackendGamemode.as"

#include "TRChatCommon.as"
#include "RadioCharacters.as"

#include "PlayerStatsCommon.as"

const bool _backendTest = false;

int _biomeIndex = 0;

void Config(CRules@ this, const string &in configstr)
{
	ConfigFile cfg = ConfigFile(configstr);

	SetConfig_tag(this, @cfg, "use_backend", false);
	SetConfig_u32(this, @cfg, "timeout_secs", 60);
	SetConfig_u32(this, @cfg, "classpick_timeout_secs", 60);
	SetConfig_u32(this, @cfg, "classpick_ready_secs", 2);
	SetConfig_u32(this, @cfg, "minimum_players", 2);
	SetConfig_u32(this, @cfg, "briefing_secs", 2);
	SetConfig_u32(this, @cfg, "teams_secs", 2);
	SetConfig_u32(this, @cfg, "gameover_secs", 2);
	SetConfig_u32(this, @cfg, "win_points", 10);
	SetConfig_u32(this, @cfg, "run_points", 20);
	SetConfig_u32(this, @cfg, "deadbuffer_secs", 0);
	SetConfig_string(this, @cfg, "tips_files", "");

	Campaign::Data@ data = Campaign::getCampaign(this);
	cfg.readIntoArray_string(data.battles, "battles");
	data.allBattles = data.battles;
	data.battlesCount = cfg.read_s32("battles_count", 5);
	Campaign::Reset(data);
}

void onInit(CRules@ this)
{
	ConfigFile cfg = ConfigFile("Rules/Campaign/override.cfg");
	string config = cfg.read_string("override", "Rules/Campaign/campaign_vars.cfg");

	Config(this, config);

	sv_max_localplayers = 1;
	sv_maxplayers = 10;

	Reset(this);
	NextMap(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	printf("reset rules");
	this.SetGlobalMessage("");

	SPAWNPOSITION_CALLBACK@ spawnFunc = defaultSpawnPosition;
	this.set("spawn position", @spawnFunc);

	if (!this.hasTag("use_backend"))
	{
		this.SetCurrentState(GAME_OVER);
		StartTeamsPresentation(this);
		Game::CreateTimer("teams", this.get_u32("teams_secs"), @Dummy, false);
	}

	this.Untag("got over edge");

	// biome sync fix?
	SyncBiome(this);
}

void onTick(CRules@ this)
{
	const bool usesBackend = this.hasTag("use_backend");
	Campaign::Data@ data = Campaign::getCampaign(this);

	// load classes from backend
	if (usesBackend)
	{
		BackendGame::update();

		if (BackendGame::state == BackendGame::state_prematch) //waiting for players
		{
			ResetScores();
			Campaign::Reset(data);
			if (!this.isIntermission())
			{
				print("RESETTING");
				Game::ClearAllTimers();
				Reset(this);
			}
		}
		else if (BackendGame::matchRunning())
		{
			if (this.isIntermission())
			{
				//start the game?
				if (Game::getTimer("intermission") is null)
				{
					printf("backend: start");
					KillPlayers();

					//early-out if we find any players
					//(they seem to be sticking around for a frame or so sometimes)
					CBlob@[] players;
					if (getBlobsByTag("player", @players))
						return;

					NextGame(this);
				}
			}

		}
	}
	else // non-backend
	{
		if (getPlayersCount() > 0)
		{
			HandleBots_NonBackend();
		}
	}

	// start games if all players selected class

	if (this.isMatchRunning())
	{
		if (this.hasTag("got over edge") || CheckWinCondition(this))
		{
			// start dead buffer for a couple secs to allow picking medkit

			Game::Timer@ timer = Game::getTimer("dead buffer");
			if (timer is null)
			{
				printf("deaf bugger");
				Game::CreateTimer("dead buffer", this.get_u32("deadbuffer_secs"), @DeadBufferEnd, false);
			}
		}
		else
		{
			// remove dead buffer if somebody took medkit
			Game::ClearTimer("dead buffer");
		}
	}
	else if (this.isGameOver())
	{
		Game::Timer@ timer = Game::getTimer("new round");
		if (timer is null)
		{
			Game::ClearTimer("timeout");
			Game::CreateTimer("new round", this.get_u32("gameover_secs"), @NewRound, false);
			// set scores
			for (uint i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				if (player.getTeamNum() == this.getTeamWon())
				{
					player.setScore(player.getScore() + this.get_u32("win_points"));
				}
			}
			// next battle
			const int teamWon = this.getTeamWon();
			data.team[data.battleIndex] = teamWon;
		}
	}

	SyncBiome(this);
}

void SpawnPlayers(CRules@ this)
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.getTeamNum() < 2)
		{
			//print("spSPAWN class " + player.getTeamNum() + " " + player.getClassNum());
			CBlob@ blob = SpawnPlayer(this, player, getSpawnPosition(player.getTeamNum()));
		}
	}
	AddParachuteToBlobs("soldier");
}

string[] getWinners()
{
	Campaign::Data@ data = Campaign::getCampaign(getRules());

	int beerscore = Campaign::getTeamScore(data, 0);
	int winescore = Campaign::getTeamScore(data, 1);

	bool paid_tie = beerscore > 0 && winescore > 0 && beerscore == winescore;

	int winnerteam = Campaign::getWinningTeam(data);

	print("getting winners:");
	string[] winners;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (!p.isBot() && (p.getTeamNum() == winnerteam || paid_tie))
		{
			print(" winner! " + p.getUsername());
			winners.push_back(p.getUsername());
		}
		else
		{
			print(" not winner :( " + p.getUsername());
		}
	}
	return winners;
}

bool allPlayersPickedClass(CRules@ this)
{
	int readycount = 0;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.getClassNum() != 255 && player.getTeamNum() != 255)
		{
			readycount++;
		}
	}
	//printf("readycount " + readycount);
	return readycount >= this.get_u32("minimum_players");
}

bool CheckWinCondition(CRules@ this)
{
	CMap@ map = getMap();
	CBlob@[] players;
	int team0count = 0, team0dead = 0;
	int team1count = 0, team1dead = 0;
	if (getBlobsByName("soldier", @players))
	{
		for (uint step = 0; step < players.length; ++step)
		{
			CBlob@ blob = players[step];
			const u8 team = blob.getTeamNum();
			const bool dead = blob.hasTag("dead");

			// over the edge

			if (!dead &&
			        ((team == 0 && blob.getPosition().x > map.tilemapwidth * map.tilesize - map.tilesize)
			         || (team == 1 && blob.getPosition().x < 0 + map.tilesize))
			   )
			{
				OverEdgeWin(this, blob);
				return true;
			}

			// count

			if (team == 0)
			{
				team0count++;
				if (dead)
				{
					team0dead++;
				}
			}
			else
			{
				team1count++;
				if (dead)
				{
					team1dead++;
				}
			}
		}
	}

	// dead conditions

	if (team0count == team0dead && team1count == team1dead ||
	        (sv_test && getControls().isKeyJustPressed(KEY_KEY_3)))  // tie
	{
		this.SetTeamWon((team1count == 0 || team0count == 0) ? -10 : -1);   // -10 if all players from team left
		Campaign::SetWinMsg(this, "EVERYBODY DIED!");
		return true;
	}
	else if (team0count == team0dead ||
	         (sv_test && getControls().isKeyJustPressed(KEY_KEY_1)))    // team 1 win
	{
		this.SetTeamWon(1);
		Campaign::SetWinMsg(this, "WINE TEAM CLEARS THE STAGE");
		return true;
	}
	else if (team1count == team1dead ||
	         (sv_test && getControls().isKeyJustPressed(KEY_KEY_2)))    // team 0 win
	{
		this.SetTeamWon(0);
		Campaign::SetWinMsg(this, "BEER TEAM CLEARS THE STAGE");
		return true;
	}

	return false;
}


void Dummy(Game::Timer@ this)
{
}

void DeadBufferEnd(Game::Timer@ this)
{
	printf("GAME OVER");
	this.rules.SetCurrentState(GAME_OVER);
}

void OverEdgeWin(CRules@ this, CBlob@ blob)
{
	CPlayer@ player = blob.getPlayer();
	if (player !is null)
	{
		player.setScore(player.getScore() + this.get_u32("run_points"));
	}
	this.SetTeamWon(blob.getTeamNum());
	printf("TEAM " + blob.getTeamNum() + " SCORES A RUN!");
	//blob.server_Die();
	this.Tag("got over edge");
	this.Sync("got over edge", true);
	Campaign::SetWinMsg(this, (blob.getTeamNum() == 0 ? "BEER" : "WINE") + " TEAM SCORES A RUN!");
}

void NextMap(CRules@ this)
{
	printf("NEXT MAP");
	this.RestartRules();
	LoadBiomeMap(Campaign::getCurrentBattle(this), "campaign");
	KillPlayers();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// #fix bots arent called here?
	if (player.isBot() || !this.hasTag("use_backend") || _backendTest)
	{
		int team = getSmallerTeam();
		player.server_setTeamNum(team);

		if (player.isMyPlayer())
		{
			Random _r(Time());
			player.server_setClassNum(_r.NextRanged(5)); // HACK: change to pick class singleplayer
			//player.server_setClassNum(2);
		}
		else
		{
			player.server_setClassNum(getFreeClass(team));

		}

		if (player.isBot())
		{
			player.server_setCharacterName(getCharacterFor(player.getTeamNum(), player.getClassNum()).name);
			//printf(player.getTeamNum() + " XXXXX player.getClassNum() " + player.getClassNum() + " " + getCharacterFor(player.getTeamNum(),player.getClassNum()).name );
		}
	}
	else
	{
		player.server_setTeamNum(255);
		player.server_setClassNum(255);
	}
}

// TIMER CALLBACKS

void Ready(Game::Timer@ this)
{
	if (allPlayersPickedClass(this.rules))
	{
		NextGame(this.rules);
	}
	else
	{
		printf("not ready");
	}
}

void NextGame(CRules@ this)
{
	StartTeamsPresentation(this);
}

void StartTeamsPresentation(CRules@ this)
{
	this.SetCurrentState(INTERMISSION);
	printf("intermission");

	if (this.hasTag("use_backend"))
	{
		if (BackendGame::can_start_game())
		{
			ApplyPlayersSyncString(this.get_string("class_picks"));
		}
	}

	Game::CreateTimer("intermission", this.get_u32("teams_secs"), @EndTeamsPresentation, false);
}

void EndTeamsPresentation(Game::Timer@ this)
{
	Campaign::Data@ data = Campaign::getCampaign(this.rules);

	if (this.rules.hasTag("use_backend"))
	{
		if (Campaign::isSeriesEnded(data)) // end campaign
		{
			BackendGame::sendPlayersHome();
			BackendGame::end();
			Campaign::Reset(data);
		}
		else
		{
			if (BackendGame::can_start_game())
			{
				ApplyPlayersSyncString(this.rules.get_string("class_picks"));
				StartBriefing(this.rules);
			}
		}
	}
	else
	{
		if (Campaign::isSeriesEnded(data))
		{
			printf("SeriesEnded Campaign::Reset");
			Campaign::Reset(data);
			NextMap(this.rules);
			Game::CreateTimer("intermission end series", this.rules.get_u32("teams_secs") / 2, @EndTeamsPresentation, false);
		}
		else
		{
			printf("StartBriefing");
			StartBriefing(this.rules);
		}
	}
}

void StartBriefing(CRules@ this)
{
	this.SetCurrentState(WARMUP);
	printf("briefing");

	Campaign::Data@ data = Campaign::getCampaign(this);
	data.team[data.battleIndex] = -1;

	Game::CreateTimer("briefing", this.get_u32("briefing_secs"), @EndBriefing, false);
}

void EndBriefing(Game::Timer@ this)
{
	printf("end briefing -> game");
	this.rules.SetCurrentState(GAME);
	SpawnPlayers(this.rules);
}

void NewRound(Game::Timer@ this)
{
	if (getNet().isServer())
	{
		printf("NEXT ROUND");
		Campaign::Data@ data = Campaign::getCampaign(this.rules);

		// next battle

		const int teamWon = this.rules.getTeamWon();

		data.team[data.battleIndex] = teamWon;
		data.battleIndex++;

		// end campaign

		if (Campaign::isSeriesEnded(data))
		{
			KillPlayers();
			NextGame(this.rules);
			return;
		}
		else
		{
			NextMap(this.rules);
			NextGame(this.rules);
		}
	}
}

// RESPAWN CALLBACK

int _spawnCounter = 0;

Random _teamrandom(0x7ea17 + Time_Local());

Vec2f defaultSpawnPosition(const u8 team)
{
	_teamrandom.Reset(0x7ea177 + Time_Local());
	Vec2f[] spawns;
	CMap@ map = getMap();

	if (map.getMarkers(getTeamMarkerString(team), spawns))
	{
		_spawnCounter++;
		f32 var = -60.0f + (_spawnCounter % 5) * 30.0f;
		return Vec2f(spawns[ _teamrandom.NextRanged(spawns.length) ].x + var, 15);
	}

	warn("Spawn markers not found for team " + team);
	return getMapCenter();
}

//

void onStateChange(CRules@ this, const u8 oldState)
{
	UpdatePlayerRadios();

	const u8 state = this.getCurrentState();

	if (state == GAME_OVER)
	{
		//BuildAwards( this );
		//PlayerStatsFullReset();
	}
}

void UpdatePlayerRadios()
{
	string[] old_names_and_icons = getTRChatNameIconLookup();
	string[] new_names_and_icons;

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);

		int icon = getCharacterFor(p.getTeamNum(), p.getClassNum()).frame;

		new_names_and_icons.push_back(p.getUsername());
		new_names_and_icons.push_back("" + icon);
	}

	setTRChatNameIconLookup(new_names_and_icons);
}


void HandleBots_NonBackend()
{
	//handle bot numbers

	//add bots up to player count
	for (u32 i = getPlayersCount(); i < sv_maxplayers; i++)
	{
		//printf("getPlayersCount()   "  + getPlayersCount() );
		AddBot("CPU", 255, 255);
	}
}
