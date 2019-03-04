#define SERVER_ONLY

#include "BiomeCommon.as"
#include "GamemodeCommon.as"
#include "States.as"
#include "Menus.as"
#include "Timers.as"
#include "BackendCommon.as"
#include "BackendHelper.as"
#include "LobbyCommon.as"
#include "InterServerPlayerSync.as"
#include "BackendGamemode.as"
#include "ConfigUtils.as"
#include "TRChatCommon.as"
#include "RadioCharacters.as"
#include "PlayerStatsCommon.as"

bool _DEBUG = false;

int _biomeIndex = Time();

bool _resetOnNextTick = false;

void Config(CRules@ this, const string &in configstr)
{
	ConfigFile cfg = ConfigFile(configstr);

	SetConfig_tag(this, @cfg, "use_backend", false);
	SetConfig_u32(this, @cfg, "score_cap", 15);
	SetConfig_u32(this, @cfg, "classpick_secs", 9);
	SetConfig_u32(this, @cfg, "timeout_secs", 60);
	SetConfig_u32(this, @cfg, "scores_secs", 7);
	SetConfig_u32(this, @cfg, "endseries_secs", 9);
	SetConfig_u32(this, @cfg, "deadbuffer_secs", 3);
	SetConfig_u32(this, @cfg, "warmup_secs", 2);
	SetConfig_u32(this, @cfg, "cancel_secs", 10);
	SetConfig_tag(this, @cfg, "expo_mode", false);
	SetConfig_string(this, @cfg, "tips_files", "" );
}

void onInit(CRules@ this)
{
	ConfigFile cfg = ConfigFile("Rules/Skirmish/override.cfg");
	string config = cfg.read_string("override", "Rules/Skirmish/skirmish_vars.cfg");

	Config(this, config);

	if (v_driver == 0)   // dedi-server
	{
		sv_max_localplayers = 1;
	}
	sv_maxplayers = 4;

	Reset(this);
	NextMap(this);

	if (this.hasTag("expo_mode")){
		this.AddScript("skirmishexpo");
	}

	if (_DEBUG)
	{
		print("SKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUG");
		print("SKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUG");
		print("SKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUGSKIRMISHDEBUG");
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	this.SetGlobalMessage("");

	SPAWNPOSITION_CALLBACK@ spawnFunc = defaultSpawnPosition;
	this.set("spawn position", @spawnFunc);

	// biome sync fix?
	SyncBiome( this );
}

void onTick(CRules@ this)
{
	const bool usesBackend = this.hasTag("use_backend");

	// reset if all players left
	// or match over
	if (_resetOnNextTick)
	{
		_resetOnNextTick = false;

		print("Reset game");

		ResetScores();

		if(usesBackend)
		{
			BackendGame::sendPlayersHome();
		}
		else
		{
			NextMap(this);
		}

		this.SetCurrentState(INTERMISSION);
		return;
	}

	// load classes from backend
	if (usesBackend)
	{
		BackendGame::update();
		if (BackendGame::state == BackendGame::state_prematch) //waiting for players
		{
			ResetScores();
		}
		else if (BackendGame::matchRunning())
		{
			if (this.isIntermission())
			{
				KillPlayers();

				//early-out if we find any players
				//(they seem to be sticking around for a frame or so sometimes)
				CBlob@[] players;
				if (getBlobsByTag("player", @players))
					return;

				this.SetCurrentState(WARMUP);
				SpawnPlayers(this);

			}
			//end the backend game at game-over time
			if (this.isGameOver() && isScoreReached(this.get_u32("score_cap")))
			{
				BackendGame::end();
			}
		}
	}
	else
	{
		// pick classes in intermission
		if (this.isIntermission())
		{
			PickClasses(this);
			return;
		}

		if (!this.hasTag("expo_mode") && getPlayersCount() > 0)
		{
		//	HandleBots_NonBackend();
		}
	}

	// check wins during the game
	if (this.isMatchRunning())
	{
		int count, deadcount;
		CalcPlayerCounts(count, deadcount);

		// all dead or one survivor

		// start dead buffer for a couple secs to allow picking medkit
		if (count >= 1 && deadcount >= count - 1 && !_DEBUG)
		{
			Game::Timer@ timer = Game::getTimer("dead buffer");
			if (timer is null)
			{
				Game::CreateTimer("dead buffer", this.get_u32("deadbuffer_secs"), @DeadBufferEnd, false);
			}
		}
		else
		{
			// remove dead buffer if somebody took medkit
			Game::ClearTimer("dead buffer");
		}
	}

	SyncBiome( this );
}


void NextMap(CRules@ this)
{
	print("NEXT MAP");

	bool usesBackend = this.hasTag("use_backend");

	if (usesBackend && BackendGame::state == BackendGame::state_postmatch ||
	        !usesBackend && isScoreReached(this.get_u32("score_cap")))
	{
		printf("reset on next tick");
		_resetOnNextTick = true;
		return;
	}

	this.RestartRules();
	KillPlayers();
	
	/*if (sv_test){
		LoadBiomeMap(5, "Campaign");
	}
	else*/ {
		LoadBiomeMap(_biomeIndex++, "Skirmish");
	}
}

void PickClasses(CRules@ this)
{
	// pick class

	int picked_count = 0;
	bool stillWaiting = false;
	const int playersCount = getPlayersCount();

	// count picked
	for (uint i = 0; i < playersCount; i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.hasTag("class picked"))
		{
			picked_count++;
		}
	}

	// timeout if at least one picked
	if (picked_count > 0)
	{
		for (uint i = 0; i < playersCount; i++)
		{
			CPlayer@ player = getPlayer(i);
			const u32 menuTime = player.get_u32("class menu time");

			// start counting timeout time
			if (menuTime == 0)
			{
				player.set_u32("class menu time", getGameTime());
			}

			if (((!player.hasTag("class picked") && menuTime > 0
			        && (getGameTime() - menuTime > this.get_u32("classpick_secs") * getTicksASecond())))
			        || getControls().isKeyJustPressed(KEY_SPACE))       // skip with space
			{
				player.Tag("class picked");
				//print("timeout " + (getGameTime() - menuTime) + " picked_count " + picked_count );
			}
		}
	}

	if (picked_count >= 1 && (playersCount > 1 || sv_bots > 0 || getNet().isClient()))
	{
		for (uint i = 0; i < playersCount; i++)
		{
			CPlayer@ player = getPlayer(i);
			if (!player.hasTag("class picked"))
			{
				stillWaiting = true;
			}
		}
	}
	else
	{
		stillWaiting = true;
	}

	// IF ALL PICKED - WARMUP

	if (!stillWaiting)
	{
		print("WARMUP");
		this.SetCurrentState(WARMUP);
		SpawnPlayers(this);
	}

}

int getFreeTeam(int start)
{
	for (uint i = start; i < sv_maxplayers; i++)
	{
		bool free = true;
		for (uint p = 0; p < getPlayersCount(); p++)
		{
			CPlayer@ player = getPlayer(p);
			if (player.getTeamNum() == i)
			{
				free = false;
				break;
			}
		}

		if (free)
		{
			return i;
		}
	}

	warn("No empty team found for bot");
	return 255;
}

void SpawnPlayers(CRules@ this)
{
	RandomizeSpawns();

	int count = 0;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);

		// cpu players
		const bool joined = player.hasTag("joined");
		if (!joined || player.isBot())
		{
			player.server_setClassNum(getRandomSkirmishUniqueBotClass());
			//player.server_setClassNum(getClassIndexByName("Demolitions"));
		}

		// random class

		if (player.getClassNum() == 255 || player.hasTag("random class"))
		{
			player.Tag("random class");
			player.server_setClassNum(getRandomSkirmishClass());
		}

		u32 snum = _spawnNum;
		Vec2f pos = getSpawnPosition(0);

		CBlob@ blob = SpawnPlayer(this, player, pos);

		if (!joined && blob !is null)
		{
			blob.getBrain().server_SetActive(true);
			CPlayer@ player = blob.getPlayer();
			player.server_setCharacterName(getCharacterFor(player.getTeamNum(),player.getClassNum()).name);
		}

		// disable keys for warmup // SYNC!?
		//blob.DisableKeys( key_action1 | key_action2 );
	}
}

void onStateChange(CRules@ this, const u8 oldState)
{
	const u8 state = this.getCurrentState();

	UpdatePlayerRadios();

	if (state == GAME_OVER)
	{
		//sync the coin amounts
		this.Sync("entry_cost", true);
		this.Sync("winner_reward", true);

		//remove all supply from the game (prevent end-of-game revive "aww why cant i play")
		CBlob@[] supplies;
		getBlobsByName("supply", @supplies);
		for (uint i = 0; i < supplies.length; i++)
		{
			supplies[i].server_Die();
		}

		if(isScoreReached(this.get_u32("score_cap")))
		{
			Game::CreateTimer("scores", this.get_u32("endseries_secs"), @ScoresEnd, false);
			//BuildAwards( this );
			//PlayerStatsFullReset();
		}
		else
		{
			Game::CreateTimer("scores", this.get_u32("scores_secs"), @ScoresEnd, false);
		}
	}
	else if (state == INTERMISSION)
	{
		// set scores to kills
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			player.setScore(player.getKills());
		}
	}
}


void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	// expo mode handling
	if (cmd == this.getCommandID("force start"))
	{
		Game::ClearAllTimers();
		ResetScores();
		NextMap(this);
		this.SetCurrentState(WARMUP);
		SpawnPlayers(this);

	}
	else if (cmd == this.getCommandID("force end"))
	{
		Game::ClearAllTimers();
		_biomeIndex++;
		ResetScores();
		NextMap(this);
	}
}

void UpdatePlayerRadios()
{
	string[] old_names_and_icons = getTRChatNameIconLookup();
	string[] new_names_and_icons;

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);

		int icon = getCharacterFor(0, p.getClassNum()).frame;

		new_names_and_icons.push_back(p.getUsername());
		new_names_and_icons.push_back("" + icon);
	}

	setTRChatNameIconLookup(new_names_and_icons);
}

void ScoresEnd(Game::Timer@ this)
{
	NextMap(this.rules);
}

void MatchEnd(Game::Timer@ this)
{
	print("match end");
	_resetOnNextTick = true;
}

string[] getWinners()
{
	print("getting winners:");
	string[] winners;
	u32 scorecap = getRules().get_u32("score_cap");
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (!p.isBot() && p.getKills() >= scorecap) //uses kills for isScoreReached -> need to use it here...
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

//other callbacks

void DeadBufferEnd(Game::Timer@ this)
{
	this.rules.SetCurrentState(GAME_OVER);
}

// RESPAWN CALLBACK

Random _teamrandom(0x7ea17 + Time_Local());
int _spawnNum = _teamrandom.NextRanged(4);

void RandomizeSpawns()
{
	_teamrandom.Reset(0x7ea177 + Time_Local());
	_spawnNum = _teamrandom.NextRanged(4);
}

Vec2f defaultSpawnPosition(const u8 team)
{
	Vec2f[] spawns;
	CMap@ map = getMap();

	//just use blue team spawns
	if (map.getMarkers(getTeamMarkerString(0), spawns))
	{
		_spawnNum = (_spawnNum + 1) % spawns.length;

		return spawns[ _spawnNum ];
	}

	warn("Spawns markers not found for team " + 0);
	return getMapCenter();
}

void HandleBots_NonBackend()
{
	//handle bot numbers

	//add bots up to player count
	for (u32 i = getPlayersCount(); i < sv_maxplayers; i++)
	{
		int c = getRandomSkirmishUniqueBotClass();
		AddBot("CPU", 255, 255); // team doesnt get set?
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// #fix bots arent called here?
	if (player.isBot())
	{
		if (!this.hasTag("use_backend"))
		{
			player.server_setTeamNum(getFreeSkirmishTeam());
			player.server_setClassNum(getRandomSkirmishUniqueBotClass());
		}
		player.server_setCharacterName(getCharacterFor(player.getTeamNum(),player.getClassNum()).name);
	}
}
