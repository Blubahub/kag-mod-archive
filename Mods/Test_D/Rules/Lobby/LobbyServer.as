#define SERVER_ONLY

#include "BiomeCommon.as"
#include "GamemodeCommon.as"
#include "States.as"
#include "Menus.as"
#include "Timers.as"
#include "Mooks.as"
#include "ConfigUtils.as"
#include "ParachuteCommon.as"
#include "ClassesCommon.as"
#include "MapCommon.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "LobbyStatsCommon.as"
#include "Pets.as"
#include "ShopCommon.as"
#include "Leaderboard.as"

void Config(CRules@ this, const string &in configstr)
{
	ConfigFile cfg = ConfigFile(configstr);

	SetConfig_string(this, @cfg, "gamemode", "Skirmish");
	SetConfig_u32(this, @cfg, "max_players", 10);
	SetConfig_u32(this, @cfg, "players_required_skirmish", 2);
	SetConfig_u32(this, @cfg, "players_required_perteam_campaign", 2);
	SetConfig_u32(this, @cfg, "launch_secs", 10);
	SetConfig_string(this, @cfg, "lobby_map", "Maps/Lobby/generallobby.png");
	SetConfig_string(this, @cfg, "biome", "trenches");
	SetConfig_u32(this, @cfg, "vip_entry_cost", 0);
	SetConfig_u32(this, @cfg, "game_entry_cost", 0);
	SetConfig_u32(this, @cfg, "winner_reward", 1);
	SetConfig_u32(this, @cfg, "max_coins", 100000);
	SetConfig_string(this, @cfg, "lobby_music", "Sounds/Music/Lobby_Music.ogg");
	SetConfig_string(this, @cfg, "tips_files", "");
	SetConfig_string(this, @cfg, "scrolling_text", "Jump in a truck to start the game         Refreshments can be purchased at the bar          Management takes no responsibility for any illness encountered");
}

void onInit(CRules@ this)
{
	ConfigFile cfg = ConfigFile("Rules/Lobby/override.cfg");
	string config = cfg.read_string("override", "Rules/Lobby/lobby_vars.cfg");
	if (isFreeBuild())
	{
		config = cfg.read_string("override", "Rules/Lobby/lobby_vars.cfg");
	}

	Config(this, config);

	if (v_driver == 0)  // dedi-server
	{
		sv_max_localplayers = 1;
		sv_maxplayers = this.get_u32("max_players");
	}

	Reset(this);
	NextMap(this);
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
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	ResetPlayerSpawnTimer(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	RemovePlayerSpawnTimer(player);

	// remove players pets
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		CBlob@[] blobs;
		getBlobsByTag("pet", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if (b.get_netid("owner") == blob.getNetworkID())
			{
				b.server_Die();
			}
		}
	}
}

void RespawnPlayer(CRules@ this, CPlayer@ player)
{
	if (player.getBlob() !is null)
		return;

	u8 skin = 0;
	s32 pet = -1;
	if (Lobby::hasPlayerRecord(player.getUsername()))
	{
		Lobby::PlayerRecord@ record = Lobby::getPlayerRecordFromCPlayer(player);
		player.server_setCoins(record.coins);
		skin = record.skin;
		pet = record.pet;

		// update leaderboard
		int stat = record.getStat("win_game");
		if (stat > 0){
			Leaderboard::SetScore("wins leaderboard", player.getCharacterName(), stat);
		}
		stat = record.getStat("lose_game");
		if (stat > 0){
			Leaderboard::SetScore("losses leaderboard", player.getCharacterName(), stat);
		}
	}
	else
	{
		if (sv_test)
		{
			player.server_setCoins(15);
			//skin = 0;
		}
	}
	this.set_u8("spawn_skin", skin); //for spawn player

	player.server_setTeamNum(255);
	player.server_setClassNum(Soldier::CIVILIAN);
	CBlob@ blob = SpawnPlayer(this, player, getSpawnPosition(255));

	if (!sv_test)
	{
		AddParachute(blob);
	}
	else
	{
		pet = CAT;
	}

	//spawn pet if applicable
	if (pet >= 0 && !hasPet(blob))
	{
		SpawnPet(blob, pet, blob.getPosition(), true);
	}

	ResetPlayerSpawnTimer(player);
}

void onTick(CRules@ this)
{
	const u8 state = getRules().getCurrentState();

	if (getGameTime() % (30 * 5) == 0)
	{
		UpdateAPIInfo(this);
	}

	//check any players that haven't spawned or died somehow
	u32 current_time = Time();
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.getBlob() is null)
		{
			if (PlayerSpawnTimerPassed(p) || Lobby::hasPlayerRecord(p.getUsername()))
			{
				RespawnPlayer(this, p);
			}
		}
	}

	this.set_string("scrolling text", this.get_string("scrolling_text"));

	SyncBiome(this);
}

//for updating the status for the API and browser

u32 GetTotalPlayers()
{
	LobbyStats@ stats = getStats();
	if (stats is null) return 0;

	{
		string s = "";
		int i = stats._players_cache.length;
		while (i-- > 0)
		{
			s += stats._players_cache[i] + ",";
		}
		getRules().set_string("__debug_playernames", s);
	}

	return stats.playersNow();
}

void UpdateAPIInfo(CRules@ this)
{
	//anything else we need from this?

	u32 total_players = GetTotalPlayers();
	this.set_u32("total_players", total_players);

	u32 wait_seconds = getStats().secondsBetweenGames();

	sv_info = "RANKED PLAYERS: " + total_players + " WAIT: " + wait_seconds;
}



//warmup checks

void NextMap(CRules@ this)
{
	printf("NEXT MAP");
	this.RestartRules();

	LoadMap(this.get_string("lobby_map"));
	CRules@ rules = getRules();
	rules.set_bool("force biome", true);

	SpawnStuff(this);
	SpawnClassBoxes(this);
	SpawnStatusMonitors(this);
}

void SpawnStuff(CRules@ this)
{
	CMap@ map = getMap();
	Vec2f[] spawns;

	// bouncer

	if (map.getMarkers("neutral spawn", spawns))
	{
		for (int i = 0; i < spawns.length; i++)
		{
			if (!sv_test)
			{
				CBlob@ bouncer = SpawnMook(spawns[i], 255, Soldier::ASSAULT);
				bouncer.Tag("bouncer");
				if (i == 0)
				{
					bouncer.Tag("face left");
				}
				bouncer.getSprite().RemoveScript("SoldierFootsteps.as");
			}
		}
	}
	else
	{
		warn("missing spawns for bouncers");
	}

	//spawn band + bar items; todo: move to its own function if you care

	spawns.clear();
	if (map.getMarkers("band", spawns) && spawns.length > 0)
	{
		for (int i = 0; i < 3; i++)
		{
			CBlob @newBlob = server_CreateBlobNoInit("band_member");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(i * 16, 0));
				newBlob.set_u8("class", 1 + i);
				newBlob.Init();
			}
		}

		//normal bar
		{
			CBlob @newBlob = server_CreateBlobNoInit("shop");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(-48, 16));
				newBlob.set_u8("shop type", BAR);
				newBlob.Init();
			}
		}
		//vip bar
		{
			CBlob @newBlob = server_CreateBlobNoInit("shop");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(8, -32));
				newBlob.set_u8("shop type", BAR_VIP);
				newBlob.Init();
			}
		}
	}
	else
	{
		warn("missing spawns for band and bar");
	}

	spawns.clear();
	if (map.getMarkers("shop", spawns) && spawns.length > 0)
	{
		//pet shop
		{
			CBlob @newBlob = server_CreateBlobNoInit("shop");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(8, 8));
				newBlob.set_u8("shop type", PET_SHOP);
				newBlob.Init();
			}
		}
		//costume shop
		{
			CBlob @newBlob = server_CreateBlobNoInit("shop");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(8, -40));
				newBlob.set_u8("shop type", SKIN_SHOP);
				newBlob.Init();
			}
		}
		//coffee shop
		{
			CBlob @newBlob = server_CreateBlobNoInit("shop");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(96, 8));
				newBlob.set_u8("shop type", COFFEE_SHOP);
				newBlob.Init();
			}
		}

	}
	else
	{
		warn("missing spawns for shop");
	}

	spawns.clear();
	if (map.getMarkers("billboard", spawns) && spawns.length > 0)
	{
		//news and help billboard
		{
			CBlob @newBlob = server_CreateBlobNoInit("billboard");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[0] + Vec2f(0, -116));
				newBlob.Init();
			}
		}

	}
	else
	{
		warn("missing spawns for billboard");
	}

	// spawn basketball stuff

	spawns.clear();
	if (map.getMarkers("hoop", spawns) && spawns.length > 0)
	{
		for (int i = 0; i < spawns.length; i++)
		{
			CBlob @newBlob = server_CreateBlobNoInit("hoop");
			if (newBlob !is null)
			{
				bool left = (i % 2) == 1;
				newBlob.server_setTeamNum(i);
				newBlob.setPosition(spawns[i] + Vec2f(left ? -10 : 10, 0));
				newBlob.Init();
				newBlob.SetFacingLeft(left);
			}
		}
	}
	else
	{
		warn("missing spawns for hoops");
	}

	spawns.clear();
	if (map.getMarkers("dispenser", spawns) && spawns.length > 0)
	{
		for (int i = 0; i < spawns.length; i++)
		{
			CBlob @newBlob = server_CreateBlobNoInit("dispenser");
			if (newBlob !is null)
			{
				newBlob.server_setTeamNum(-1);
				newBlob.setPosition(spawns[i] + Vec2f(-4, -10));
				newBlob.Init();
			}
		}
	}
	else
	{
		warn("missing spawns for dispenser");
	}
}

void SpawnClassBoxes(CRules@ this)
{
	CMap@ map = getMap();
	Vec2f[] positions;
	if (map.getMarkers("class change", positions))
	{
		u8 classindex = 255;
		//so we can do gamemode-specific stuff
		string gamemode = this.get_string("gamemode");

		for (uint i = 0; i < positions.length; i++)
		{
			//no random class in campaign
			if (gamemode == "Campaign" && classindex >= Soldier::CIVILIAN)
			{
				classindex = 0;
			}

			Vec2f pos = positions[i];
			CBlob @newBlob = server_CreateBlobNoInit("class_selector");
			if (newBlob !is null)
			{
				newBlob.setPosition(pos + Vec2f(map.tilesize, map.tilesize) * 0.5f);
				newBlob.set_u8("class", classindex);
				newBlob.Init();
			}

			map.server_SetTile(pos, TWMap::tile_bunker);

			classindex++;
			if (classindex >= Soldier::CIVILIAN)
			{
				classindex = 255;
			}

			//no medic in skirmish
			if (gamemode == "Skirmish" && classindex == Soldier::MEDIC)
			{
				classindex++;
			}
		}
	}
}

void SpawnStatusMonitors(CRules@ this)
{
	CMap@ map = getMap();
	Vec2f[] positions;
	if (map.getMarkers("campaign view", positions))
	{
		for (uint i = 0; i < positions.length; i++)
		{
			Vec2f pos = positions[i];
			CBlob @newBlob = server_CreateBlobNoInit("status_monitor");
			if (newBlob !is null)
			{
				newBlob.setPosition(pos + Vec2f(map.tilesize, map.tilesize) * 0.5f);
				newBlob.Init();
			}

			map.server_SetTile(pos, TWMap::tile_bunker);
		}
	}
}

// RESPAWN CALLBACK

Vec2f defaultSpawnPosition(const u8 team)
{
	CMap@ map = getMap();
	Random _r(Time());
	u32 border = map.tilemapwidth * 0.4f;
	f32 x = (_r.NextRanged(map.tilemapwidth - border * 2) + border + 0.5f) * map.tilesize;
	return Vec2f(x, 0);
}

void RemovePlayerSpawnTimer(CPlayer@ player)
{
	getRules().set_u32(player.getUsername() + "_canspawn", 0);
}

void ResetPlayerSpawnTimer(CPlayer@ player)
{
	u32 spawntime = 10;
	if (getNet().isServer() && getNet().isClient()) //local cheats
		spawntime = 1;
	getRules().set_u32(player.getUsername() + "_canspawn", Time() + spawntime);
}

bool PlayerSpawnTimerPassed(CPlayer@ player)
{
	CRules@ this = getRules();
	string prop = player.getUsername() + "_canspawn";
	if (!this.exists(prop))
		return false;

	u32 spawn_time = this.get_u32(prop);
	return spawn_time <= Time() && spawn_time != 0;
}

