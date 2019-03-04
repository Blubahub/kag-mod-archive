
//StoryMode gamemode logic script

#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

//simple config function - edit the variables below to change the basics

void Config(StoryModeCore@ this)
{
	string configstr = "Rules/StoryMode/StoryMode_vars.cfg";
	if (getRules().exists("StoryModeconfig"))
	{
		configstr = getRules().get_string("StoryModeconfig");
	}
	ConfigFile cfg = ConfigFile(configstr);

	//how long for the game to play out?
	s32 gameDurationMinutes = cfg.read_s32("game_time", -1);
	if (gameDurationMinutes <= 0)
	{
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
	else
	{
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));

}

//StoryMode spawn system

const s32 spawnspam_limit_time = 10;

shared class StoryModeSpawns : RespawnSystem
{
	StoryModeCore@ StoryMode_core;

	bool force;
	s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@StoryMode_core = cast < StoryModeCore@ > (core);

		limit = spawnspam_limit_time;
	}

	void Update()
	{
		for (uint team_num = 0; team_num < StoryMode_core.teams.length; ++team_num)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (StoryMode_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}

			string propname = "StoryMode spawn time " + info.username;

			StoryMode_core.rules.set_u8(propname, spawn_property);
			StoryMode_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

	bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if (inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlob(name);
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition(blob.getPosition());
			}
		}

		return true;
	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		if (canSpawnPlayer(p_info))
		{
			//limit how many spawn per second
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();
			}
			CBlob@ playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);

			if (playerBlob !is null)
			{
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);
				player.set_u8("used_spawned",player.get_u8("used_spawned")+1);
				
				//We've spawned player!
				//Has kev been spawned in?
				if(getRules().hasTag("killedkevin")){
					CBlob@[] players;
					getBlobsByName("kevinghost", @players);
					if(players.length <= 0){
						//Spawn in da main man
						server_CreateBlob("kevinghost", 0, getSpawnLocation(p_info));
					}
				}
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("StoryMode LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }
		
		CPlayer@ player = getPlayerByUsername(p_info.username);
		if (player !is null){
			if(player.get_u8("used_spawned") > 0 && getRules().hasTag("can_lose"))return false;
		}
		
		return true;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ c_info = cast < CTFPlayerInfo@ > (p_info);
		if (c_info !is null)
		{
			
			CBlob@[] tents;
			getBlobsByName("tent", @tents);
			
			if(tents.length > 0)return tents[XORRandom(tents.length)].getPosition();
			
			
			
			CMap@ map = getMap();
			if (map !is null)
			{
				f32 x = 32.0f;
				return Vec2f(x, map.getLandYAtX(s32(x / map.tilesize)) * map.tilesize - 16.0f);
			}
		}

		return Vec2f(0, 0);
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("StoryMode LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "StoryMode spawn time " + info.username;

		for (uint i = 0; i < StoryMode_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (StoryMode_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		StoryMode_core.rules.set_u8(propname, 255);   //not respawning
		StoryMode_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(StoryMode_core.spawnTime);

		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("StoryMode LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

//		print("ADD SPAWN FOR " + player.getUsername());

		if (info.team < StoryMode_core.teams.length)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (StoryMode_core.teams[info.team]);

			info.can_spawn_time = tickspawndelay;

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < StoryMode_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (StoryMode_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};

shared class StoryModeCore : RulesCore
{
	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;

	StoryModeSpawns@ StoryMode_spawns;

	StoryModeCore() {}

	StoryModeCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}

	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		@StoryMode_spawns = cast < StoryModeSpawns@ > (_respawns);
		server_CreateBlob("Entities/Meta/WARMusic.cfg");
	}

	void Update()
	{

		if (rules.isGameOver()) { return; }

		RulesCore::Update(); //update respawns
		CheckTeamWon();

	}

	//team stuff

	void AddTeam(CTeam@ team)
	{
		CTFTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		CTFPlayerInfo p(player.getUsername(), 0, "builder");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null)
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}

	//checks
	void CheckTeamWon()
	{
		if (!rules.isMatchRunning()) { return; }
		
		bool lost = true;
		
		CBlob@[] players;
		getBlobsByTag("player", @players);
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ player = players[i].getPlayer();
			if (player !is null && player.getTeamNum() == 0)
			{
				lost = false;
				rules.Tag("can_lose");
			}
		}
		
		if(lost)rules.set_u8("loss ticks",rules.get_u8("loss ticks")+1);
		else rules.set_u8("loss ticks",0);
		
		if(rules.hasTag("can_lose"))
		if(rules.get_u8("loss ticks") > 150){
			rules.set_u8("loss ticks",0);
			rules.Untag("can_lose");
			print("We lost :(");
			clearAdventure();
			LoadMap(FirstMap());
		}
		
		if(rules.hasTag("completed_level") || rules.hasTag("completed_level_alternate")){
			
			rules.Untag("can_lose");
			print("We won :)");
			NextMap();
			rules.Untag("completed_level");
			rules.Untag("completed_level_alternate");
		}
	}

	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			CTFTeamInfo@ team_info = cast < CTFTeamInfo@ > (teams[team]);
		}
	}

	void NextMap()
	{
		
		if(getMap().getMapName() == "CrossRoads.png"){
			if(rules.hasTag("completed_level"))LoadMap("FirstVoyage.png");
			if(rules.hasTag("completed_level_alternate"))LoadMap("IslandCrossing.png");
			return;
		}
		
		if(getMap().getMapName() == "IslandCrossing.png"){
			LoadMap("KevinsPass.png");
			return;
		}
		
		if(getMap().getMapName() == "KevinsPass.png"){
			LoadMap("BorderGuard.png");
			return;
		}
		
		if(getMap().getMapName() == "FirstVoyage.png"){
			if(rules.hasTag("completed_level"))LoadMap("BorderGuard.png");
			if(rules.hasTag("completed_level_alternate"))LoadMap("SkyLands.png");
			return;
		}
		
		if(getMap().getMapName() == "BorderGuard.png"){
			LoadMap(FirstMap());
			return;
		}
	}
	
	string FirstMap(){
		return "CrossRoads.png";
	}
};

//pass stuff to the core from each of the hooks

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());
	StoryModeSpawns spawns();
	StoryModeCore core(this, spawns);
	Config(core);

	this.SetCurrentState(GAME);
	this.SetGlobalMessage("");
	
	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	
	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u8("used_spawned",0);
		}
	}
}

shared void clearAdventure(){

	CRules@ rules = getRules();

	rules.Untag("killedkevin");
	
}
