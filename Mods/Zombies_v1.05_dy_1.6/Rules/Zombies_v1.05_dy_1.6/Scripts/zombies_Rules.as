
//Zombies gamemode logic script
//Modded by Eanmig
#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "zombies_Technology.as";  

#include "CTF_PopulateSpawnList.as"

//simple config function - edit the variables below to change the basics

void Config(ZombiesCore@ this)
{
	//Map Record System Init - Start
	string configZ = "../Cache/serverSpecific_vars.cfg";
	ConfigFile zCfg = ConfigFile( configZ );
	s32 zGameT = zCfg.read_s32("game_mode",0);
	string currentMap = getRules().get_string("current_map");
	string tRecordMap = currentMap + "_record";				//add _record to map name					//add map to config
	s32 mapRecord = zCfg.read_s32(tRecordMap, 0);
	
	//Map Record System Init - End
    string configstr = "../Mods/" + sv_gamemode + "/Rules/" + sv_gamemode + "/zombies_vars.cfg";
	if (getRules().exists("Zombiesconfig")) {
	   configstr = getRules().get_string("Zombiesconfig");
	}
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long for the game to play out?
	
    s32 gameDurationMinutes = cfg.read_s32("game_time",-1);
    if (gameDurationMinutes <= 0)
    {
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
    else
    {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	
	//Map Record specifics
	if (mapRecord == 0)
	{
		zCfg.add_s32(tRecordMap, 1);
		zCfg.saveFile("serverSpecific_vars.cfg");
		printf("recordMap "+tRecordMap);
		mapRecord = 1;
	}

//Rabid Dog Boss	
	f32 rabid_dog_player_dmg = cfg.read_f32("rabid_dog_player_dmg", 1.0f);
	f32 rabid_dog_aggro_range = cfg.read_f32("rabid_dog_aggro_range", 300.0f);
	
	s32 rabid_dog_reward_coins = cfg.read_s32("rabid_dog_reward_coins", 500);
	s32 rabid_dog_tile_dmg = cfg.read_s32("rabid_dog_tile_dmg", 100);
	s32 rabid_dog_tile_dmg_range = cfg.read_s32("rabid_dog_tile_dmg_range", 20);

	getRules().set_f32("rabid_dog_aggro_range", rabid_dog_aggro_range);
	getRules().set_f32("rabid_dog_player_dmg", rabid_dog_player_dmg);
	getRules().set_s32("rabid_dog_reward_coins", rabid_dog_reward_coins);
	getRules().set_s32("rabid_dog_tile_dmg", rabid_dog_tile_dmg);
	getRules().set_s32("rabid_dog_tile_dmg_range", rabid_dog_tile_dmg_range);
	
//Green Troll Boss
	f32 green_troll_player_dmg = cfg.read_f32("green_troll_player_dmg", 2.5f);
	f32 green_troll_aggro_range = cfg.read_f32("green_troll_aggro_range", 150.0f);
	s32 green_troll_knockback_power = cfg.read_s32("green_troll_knockback_power", 5);
	s32 green_troll_tile_dmg = cfg.read_s32("green_troll_tile_dmg", 100);
	s32 green_troll_tile_dmg_range = cfg.read_s32("green_troll_tile_dmg_range", 20);
	s32 green_troll_reward_coins = cfg.read_s32("green_troll_reward_coins", 500);
	

	getRules().set_f32("green_troll_player_dmg", green_troll_player_dmg);
	getRules().set_f32("green_troll_aggro_range", green_troll_aggro_range);
	getRules().set_s32("green_troll_knockback_power", green_troll_knockback_power);
	getRules().set_s32("green_troll_reward_coins", green_troll_reward_coins);
	getRules().set_s32("green_troll_tile_dmg", green_troll_tile_dmg);
	getRules().set_s32("green_troll_tile_dmg_range", green_troll_tile_dmg_range);

//Minotaur King Boss
	f32 boss_minotaur_aggro_range = cfg.read_f32("boss_minotaur_aggro_range", 150.0f);
	f32 boss_minotaur_player_dmg = cfg.read_f32("boss_minotaur_player_dmg", 2.5f);
	s32 boss_minotaur_knockback_power = cfg.read_s32("boss_minotaur_knockback_power", 5);
	s32 boss_minotaur_tile_dmg = cfg.read_s32("boss_minotaur_tile_dmg", 100);
	s32 boss_minotaur_tile_dmg_range = cfg.read_s32("boss_minotaur_tile_dmg_range", 20);
	s32 boss_minotaur_reward_coins = cfg.read_s32("boss_minotaur_reward_coins", 500);
	
	getRules().set_f32("boss_minotaur_player_dmg", boss_minotaur_player_dmg);
	getRules().set_f32("boss_minotaur_aggro_range", boss_minotaur_aggro_range);
	getRules().set_s32("boss_minotaur_knockback_power", boss_minotaur_knockback_power);
	getRules().set_s32("boss_minotaur_reward_coins", boss_minotaur_reward_coins);
	getRules().set_s32("boss_minotaur_tile_dmg", boss_minotaur_tile_dmg);
	getRules().set_s32("boss_minotaur_tile_dmg_range", boss_minotaur_tile_dmg_range);

//Red Dragon Boss
	f32 red_dragon_player_dmg = cfg.read_f32("red_dragon_player_dmg", 5.0f);
	f32 red_dragon_aggro_range = cfg.read_f32("red_dragon_aggro_range", 300.0f);

	s32 red_dragon_reward_coins = cfg.read_s32("red_dragon_reward_coins", 1000);
	s32 red_dragon_tile_dmg = cfg.read_s32("red_dragon_tile_dmg", 100);
	s32 red_dragon_tile_dmg_range = cfg.read_s32("red_dragon_tile_dmg_range", 20);

	getRules().set_f32("red_dragon_aggro_range", red_dragon_aggro_range);
	getRules().set_f32("red_dragon_player_dmg", red_dragon_player_dmg);
	getRules().set_s32("red_dragon_reward_coins", red_dragon_reward_coins);
	
	getRules().set_s32("red_dragon_tile_dmg", red_dragon_tile_dmg);
	getRules().set_s32("red_dragon_tile_dmg_range", red_dragon_tile_dmg_range);
//Normal Mobs Parameters
	f32 skeleton_player_dmg = cfg.read_f32("skeleton_player_dmg", 0.3f);
	f32 zombie_player_dmg = cfg.read_f32("zombie_player_dmg", 0.5f);
	f32 zombie_knight_player_dmg = cfg.read_f32("zombie_knight_player_dmg", 0.8f);
	f32 greg_player_dmg = cfg.read_f32("greg_player_dmg", 0.1f);

	getRules().set_f32("zombie_player_dmg", zombie_player_dmg);
	getRules().set_f32("skeleton_player_dmg", skeleton_player_dmg);
	getRules().set_f32("zombie_knight_player_dmg", zombie_knight_player_dmg);
//All other parameters

	s32 tempDay = cfg.read_s32("tempDay",0);
	s32 bossRound = cfg.read_s32("bossRound",0);
	s32 boss_round_counter = cfg.read_s32("boss_round_counter",-1);
	s32 boss_round_end = cfg.read_s32("boss_round_end",0);
	s32 respawn_grace_period = cfg.read_s32("respawn_grace_period",1);

	getRules().set_s32("respawn_grace_period", respawn_grace_period);
	getRules().set_s32("tempDay", tempDay);
	getRules().set_s32("bossRound", bossRound);
	getRules().set_s32("boss_round_counter", boss_round_counter);
	getRules().set_s32("boss_round_end", boss_round_end);
	bool npc_guards_enabled = cfg.read_bool("npc_guards_enabled",true);
	s32 max_npc_guards = cfg.read_s32("max_npc_guards", 20);
	s32 max_migrants = cfg.read_s32("max_migrants", 5);
	getRules().set_s32("max_npc_guards", max_npc_guards);
	getRules().set_s32("max_migrants", max_migrants);
	getRules().set_string("tRecordMap", tRecordMap);
	getRules().set_s32("mapRecord", mapRecord);
	getRules().set_s32("zGameT", zGameT);

	bool cook_food_only = cfg.read_bool("cook_food_only",true);
	bool extra_siege_vehicles = cfg.read_bool("extra_siege_vehicles",true);
    bool destroy_dirt = cfg.read_bool("destroy_dirt",true);
	getRules().set_bool("destroy_dirt", destroy_dirt);
	bool gold_structures = cfg.read_bool("gold_structures",false);
	bool scrolls_spawn = cfg.read_bool("scrolls_spawn",false);
	bool techstuff_spawn = cfg.read_bool("techstuff_spawn",false);
	warn("GS SERVER: "+ gold_structures);
	getRules().set_bool("gold_structures", gold_structures);
	//Zombies Vars Config
	string server_title = cfg.read_string("server_title","Sernix Survival Server");
	string server_rules = cfg.read_string("server_rules","");

	s32 lastBossType = cfg.read_s32("lastBossType",-1); 
	s32 max_wraiths = cfg.read_s32("max_wraiths",5); 
	s32 max_gregs = cfg.read_s32("max_gregs",5); 
	s32 max_zombieknights = cfg.read_s32("max_zombieknights",10); 

	s32 red_dragon_throwing_power = cfg.read_s32("red_dragon_throwing_power",10); 
	s32 boss_variants = cfg.read_s32("boss_variants",4); 
	s32 boss_round_length = cfg.read_s32("boss_round_length",5);
	s32 boss_spawn_with_zeds = cfg.read_s32("boss_spawn_with_zeds",0);
	s32 boss_spawn_anytime = cfg.read_s32("boss_spawn_anytime",75);
	s32 max_bosses = cfg.read_s32("max_bosses",5);
	s32 boss_enabled_day = cfg.read_s32("boss_enabled_day",15);
	s32 land_mobs_increase_jump_day = cfg.read_s32("land_mobs_increase_jump_day",30);
	s32 extra_wraiths_day = cfg.read_s32("extra_wraiths_day",40);
	s32 boss_round_interval = cfg.read_s32("boss_round_interval",10);
	s32 max_zombies = cfg.read_s32("max_zombies",30);
	s32 max_normal_zombies = cfg.read_s32("max_normal_zombies",10);
	s32 max_skeletons = cfg.read_s32("max_skeletons",10);
	f32 dorm_heal_amount = cfg.read_f32("dorm_heal_amount",0.1f);
	s32 break_chance_modifier = cfg.read_s32("break_chance_modifier",10); 
	s32 max_dragons = cfg.read_s32("max_dragons", 1);

	f32 red_dragon_health = cfg.read_f32("red_dragon_health",300.0f); 
	f32 green_troll_health = cfg.read_f32("green_troll_health",100.0f); 
	f32 rabid_dog_health = cfg.read_f32("rabid_dog_health",80.0f); 
	f32 boss_minotaur_health = cfg.read_f32("boss_minotaur_health",90.0f); 

		
	getRules().set_f32("red_dragon_health", red_dragon_health);
	getRules().set_f32("green_troll_health", green_troll_health);
	getRules().set_f32("rabid_dog_health", rabid_dog_health);
	getRules().set_f32("boss_minotaur_health", boss_minotaur_health);

	getRules().set_s32("max_dragons", max_dragons);
	getRules().set_s32("break_chance_modifier", break_chance_modifier);
	getRules().set_s32("red_dragon_throwing_power", red_dragon_throwing_power);
	getRules().set_s32("lastBossType", lastBossType);
	getRules().set_s32("max_normal_zombies", max_normal_zombies);
	getRules().set_s32("max_skeletons", max_skeletons);
	getRules().set_s32("boss_round_interval", boss_round_interval);
	getRules().set_f32("dorm_heal_amount", dorm_heal_amount);
	getRules().set_s32("boss_round_length", boss_round_length);
	getRules().set_s32("boss_variants", boss_variants);
	getRules().set_s32("max_zombieknights", max_zombieknights);
	getRules().set_s32("max_gregs", max_gregs);
	getRules().set_s32("max_wraiths", max_wraiths);
	getRules().set_s32("boss_spawn_anytime", boss_spawn_anytime);
	getRules().set_s32("boss_spawn_with_zeds", boss_spawn_with_zeds);
	getRules().set_s32("max_zombies", max_zombies);
	getRules().set_s32("max_bosses", max_bosses);
	getRules().set_s32("boss_enabled_day", boss_enabled_day);
	getRules().set_s32("boss_round_interval", boss_round_interval);
	getRules().set_s32("land_mobs_increase_jump_day", land_mobs_increase_jump_day);
	getRules().set_s32("extra_wraiths_day", extra_wraiths_day);
	getRules().set_bool("scrolls_spawn", scrolls_spawn);
	getRules().set_bool("techstuff_spawn", techstuff_spawn);
	getRules().set_bool("npc_guards_enabled", npc_guards_enabled);
	getRules().set_bool("extra_siege_vehicles", extra_siege_vehicles);
	getRules().set_bool("cook_food_only", cook_food_only);
	getRules().set_string("server_title", server_title);
	getRules().set_string("server_rules", server_rules);
    //spawn after death time 
    //this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 10));
	
}

//Zombies spawn system

const s32 spawnspam_limit_time = 10;

shared class ZombiesSpawns : RespawnSystem
{

    ZombiesCore@ Zombies_core;

    bool force;
    s32 limit;
	
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Zombies_core = cast<ZombiesCore@>(core);
		if (getRules().isWarmup())
        limit = 10;
        else
		limit = spawnspam_limit_time;

		getRules().set_bool("everyones_dead",false);
	}

    void Update()
    {
		int everyone_dead=0;
		int total_count=Zombies_core.players.length;
        for (uint team_num = 0; team_num < Zombies_core.teams.length; ++team_num )
        {
            CTFTeamInfo@ team = cast<CTFTeamInfo@>( Zombies_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
				if ( info !is null )
				{
					if (info.can_spawn_time>0) everyone_dead++;
					//total_count++;
				}
                DoSpawnPlayer( info );
            }
        }
		if (getRules().isMatchRunning())
		{
			if (everyone_dead == total_count && total_count!=0) getRules().set_bool("everyones_dead",true); 
			if (getGameTime() % (10*getTicksASecond()) == 0) warn("ED:"+everyone_dead+" TC:"+total_count);
		}
    }
    
    void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
    {
		if ( info !is null )
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "Zombies spawn time "+info.username;
			
			Zombies_core.rules.set_u8( propname, spawn_property );
			Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}

	bool SetMaterials( CBlob@ blob,  const string &in name, const int quantity )
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if(inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlob( name );
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition( blob.getPosition() );
			}
		}

		return true;
	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {

        	//printf("limit = "+limit);
        	//25 is a second
			//limit how many spawn per second
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				if (getRules().isWarmup())
        		limit = 10;
        		else
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
				warn("team"+p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}

			p_info.blob_name = "builder"; //hard-set the respawn blob
            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);

                
				// spawn resources
					SetMaterials( playerBlob, "mat_wood", 200 );
					SetMaterials( playerBlob, "mat_stone", 100 );
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		//return true;
        //if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ c_info = cast<CTFPlayerInfo@>(p_info);
		if(c_info !is null)
        {
        	CBlob@ pickSpawn = getBlobByNetworkID( c_info.spawn_point );
			
			if (pickSpawn !is null && pickSpawn.hasTag("respawn") && pickSpawn.getName() != "dorm" && pickSpawn.getTeamNum() == p_info.team)
			{
				CBitStream params;
				params.write_netid(pickSpawn.getNetworkID() );
				//params.write_string( pickSpawn );
				pickSpawn.SendCommand( pickSpawn.getCommandID("out migrant"), params );
				return pickSpawn.getPosition();
			}
			else if (pickSpawn !is null && pickSpawn.hasTag("respawn") && pickSpawn.getName() == "dorm" && isRoomFullOfMigrants(pickSpawn) && pickSpawn.getTeamNum() == p_info.team)
			{
				CBitStream params;
				params.write_netid(pickSpawn.getNetworkID() );
				//params.write_string( pickSpawn );
				pickSpawn.SendCommand( pickSpawn.getCommandID("out migrant"), params );
				return pickSpawn.getPosition();
			}
			else
			{
				CMap@ map = getMap();
				if(map !is null)
				{
					f32 x = XORRandom(2) == 0 ? 32.0f : map.tilemapwidth * map.tilesize - 32.0f;
					return Vec2f(x, map.getLandYAtX(s32(x/map.tilesize))*map.tilesize - 16.0f);
				}
			}
        }
        return Vec2f(0,0);
    }

    void RemovePlayerFromSpawn(CPlayer@ player)
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);
        
        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "Zombies spawn time "+info.username;
        
        for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Zombies_core.rules.set_u8( propname, 255 ); //not respawning
		Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		s32 tickspawndelay = 0;
		if (player.getDeaths() != 0)
		{
			int respawn_grace_period = getRules().get_s32("respawn_grace_period");
			int gamestart = getRules().get_s32("gamestart");
			int day_cycle = getRules().daycycle_speed*60;
			int timeElapsed = ((getGameTime()-gamestart)/getTicksASecond()) % day_cycle;
			tickspawndelay = (day_cycle - timeElapsed)*getTicksASecond();
			//printf("timeElapsed = "+timeElapsed);
			warn("DC: "+day_cycle+" TE:"+timeElapsed);
			if (timeElapsed<respawn_grace_period) tickspawndelay=0;
		}
		
		
		//; //
        
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		print("ADD SPAWN FOR " + player.getUsername()+ "Spawn Delay: " +tickspawndelay);

		if (info.team < Zombies_core.teams.length)
		{
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}

};


shared class ZombiesCore : RulesCore
{

	
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

    ZombiesSpawns@ Zombies_spawns;

    ZombiesCore() {}

    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }
    
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {

        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
		int gamestart = getGameTime();
		rules.set_s32("gamestart",gamestart);
		rules.SetCurrentState(WARMUP);
    }


    void Update()
    {

		//printf("zGameT = "+zGameT);
		/*
		//Map Record System Init - Start
		string configZ = "../Cache/serverSpecific_vars.cfg";
		ConfigFile zCfg = ConfigFile( configZ );
		s32 zGameT = zCfg.read_s32("game_mode",0);
		string currentMap = getRules().get_string("current_map");
		string tRecordMap = currentMap + "_record";				//add _record to map name					//add map to config
		s32 mapRecord = zCfg.read_s32(tRecordMap, 0);
		if (mapRecord == 0)
		{
			zCfg.add_s32(tRecordMap, 1);
			zCfg.saveFile("serverSpecific_vars.cfg");
			printf("recordMap "+tRecordMap);
			mapRecord = 1;
		}
		*/
		//Map Record System Init - End
		string configZ = "../Cache/serverSpecific_vars.cfg";
		ConfigFile zCfg = ConfigFile( configZ );
		s32 zGameT = rules.get_s32("zGameT");
		s32 mapRecord = rules.get_s32("mapRecord");
		string tRecordMap = rules.get_string("tRecordMap");

        if (rules.isGameOver()) { return; }
        if (zGameT == 0)
		rules.SetCurrentState(GAME_OVER);
		int day_cycle = getRules().daycycle_speed * 60;
		int max_zombies = rules.get_s32("max_zombies");
		int boss_enabled_day = rules.get_s32("boss_enabled_day");
		int land_mobs_increase_jump_day = rules.get_s32("land_mobs_increase_jump_day");
		int extra_wraiths_day = rules.get_s32("extra_wraiths_day");
		int boss_round_interval = rules.get_s32("boss_round_interval");
		int max_migrants = rules.get_s32("max_migrants");
		int num_zombies = rules.get_s32("num_zombies");
		int num_dragons = rules.get_s32("num_dragons");
		int num_bosses = rules.get_s32("num_bosses");
		int num_wraiths = rules.get_s32("num_wraiths");
		int num_gregs = rules.get_s32("num_gregs");
		int num_migrants = rules.get_s32("num_migrants");
		int num_zombieknights = rules.get_s32("num_zombieknights");
		int max_bosses = rules.get_s32("max_bosses");
		int boss_variants = rules.get_s32("boss_variants");
		int boss_type = rules.get_s32("boss_type");
		int gamestart = rules.get_s32("gamestart");
		int timeElapsed = getGameTime()-gamestart;
		int bossRound = rules.get_s32("bossRound");
		int boss_spawn_with_zeds = rules.get_s32("boss_spawn_with_zeds");
		int boss_round_length = rules.get_s32("boss_round_length");
		int boss_round_end = rules.get_s32("boss_round_end");
		int boss_spawn_anytime = rules.get_s32("boss_spawn_anytime");
		int max_zombieknights = rules.get_s32("max_zombieknights");
		int max_gregs = rules.get_s32("max_gregs");
		int max_wraiths = rules.get_s32("max_wraiths");
		int max_normal_zombies = rules.get_s32("max_normal_zombies");
		int max_skeletons = rules.get_s32("max_skeletons");
		int boss_round_counter = rules.get_s32("boss_round_counter");
		int boss_round_init_day = rules.get_s32("boss_round_init_day");
		int num_guards = rules.get_s32("num_guards");
		int num_normal_skeletons = rules.get_s32("num_normal_skeletons");
		int num_normal_zombies = rules.get_s32("num_normal_zombies");
		int tempDay = rules.get_s32("tempDay");
		int lastBossType = rules.get_s32("lastBossType");
		int max_dragons = rules.get_s32("max_dragons");
		string server_title = rules.get_string("server_title");
		string server_rules = rules.get_string("server_rules");
		float difficulty = 2.0*(getGameTime()-gamestart)/getTicksASecond()/day_cycle;
		
		float actdiff = 4.0*((getGameTime()-gamestart)/getTicksASecond()/day_cycle);
		//printf("difficulty = "+difficulty+" actdiff = "+actdiff);
		int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
		if (actdiff>9) { actdiff=9; difficulty=difficulty-1.0; } else { difficulty=1.0; }
		if (rules.isWarmup() && timeElapsed>getTicksASecond()*30) { rules.SetCurrentState(GAME); warn("TE:"+timeElapsed); }
		rules.set_f32("difficulty",difficulty/3.0);

		int spawnRate = getTicksASecond() * (6-(difficulty/2.0));
	
		if (dayNumber > mapRecord)
		{
			mapRecord = dayNumber;
			getRules().set_s32("mapRecord", mapRecord);
			//printf("Map : "+tRecordMap+" recorded. mapRecord : "+mapRecord);
		}
		if (spawnRate<8) spawnRate=8;

		if (getGameTime() % (spawnRate) == 0)
		{
			//Get Zombies / Bosses Count	
			CBlob@[] boss_blobs;
			getBlobsByTag("boss", @boss_blobs );
			num_bosses = boss_blobs.length;
			rules.set_s32("num_bosses",num_bosses);

			CBlob@[] wraith_blobs;
			getBlobsByTag("Wraith", @wraith_blobs );
			num_wraiths = wraith_blobs.length;
			rules.set_s32("num_wraiths",num_wraiths);

			CBlob@[] greg_blobs;
			getBlobsByTag("GregSpawn", @greg_blobs );
			num_gregs = greg_blobs.length;
			rules.set_s32("num_gregs",num_gregs);

			CBlob@[] zombieknight_blobs;
			getBlobsByTag("ZombieKnight", @zombieknight_blobs );
			num_zombieknights = zombieknight_blobs.length;
			rules.set_s32("num_zombieknights",num_zombieknights);

			CBlob@[] migrant_blobs;
			getBlobsByTag("migrant", @migrant_blobs );
			num_migrants = migrant_blobs.length;
			rules.set_s32("num_migrants", num_migrants);
			
			CBlob@[] npc_bots;
			getBlobsByTag("npc_bot", @npc_bots );
			num_guards = npc_bots.length;
			rules.set_s32("num_guards", num_guards);

			CBlob@[] normal_skeleton_bots;
			getBlobsByTag("normal_skeleton", @normal_skeleton_bots );
			num_normal_skeletons = normal_skeleton_bots.length;
			rules.set_s32("num_normal_skeletons", num_normal_skeletons);

			CBlob@[] normal_zombie_bots;
			getBlobsByTag("normal_zombie", @normal_zombie_bots );
			num_normal_zombies = normal_zombie_bots.length;
			rules.set_s32("num_normal_zombies", num_normal_zombies);

			CBlob@[] zombie_blobs;
			getBlobsByTag("zombie", @zombie_blobs );
			num_zombies = zombie_blobs.length - num_bosses;  // normal zeds dont count bosses
			rules.set_s32("num_zombies",num_zombies);

			CBlob@[] dragon_blobs;
			getBlobsByTag("BossRedDragon", @dragon_blobs );
			num_dragons = dragon_blobs.length;  // normal zeds dont count bosses
			rules.set_s32("num_dragons",num_dragons);
			

		}

		//printf("Zombies: "+num_zombies+" spawnRate: "+spawnRate+"getGameTime() % (spawnRate) == 0 is "+(getGameTime() % (spawnRate) == 0)+"getGameTime() = "+getGameTime());	
		if (getGameTime() % 300 == 0 && dayNumber >= mapRecord) { getRules().set_s32("mapRecord", mapRecord); zCfg.add_s32(tRecordMap, mapRecord); zCfg.saveFile("serverSpecific_vars.cfg"); }
		if (getGameTime() % 300 == 0)
			printf("Total non-boss mobs: "+num_zombies+" Bosses = "+num_bosses+" Guards = "+(num_guards-num_migrants)+" Migrants: "+num_migrants+" Dragons = "+num_dragons+" Normal Zeds = "+num_normal_zombies+" Z_knights = "+num_zombieknights+" Skeletons = "+num_normal_skeletons+" Wraiths = "+num_wraiths+" Gregs = "+num_gregs);
			//printf("num_normal_skeletons = "+num_normal_skeletons+" num_normal_zombies = "+num_normal_zombies+" num_wraiths = "+num_wraiths+" num_zombieknights = "+num_zombieknights+" num_gregs = "+num_gregs);
						
		if (dayNumber > boss_spawn_anytime)
		{
			boss_spawn_with_zeds = 1;
			rules.set_s32("boss_spawn_with_zeds", boss_spawn_with_zeds);
			bossRound = 2;
			rules.set_s32("bossRound", bossRound);
			boss_type = (XORRandom(boss_variants));
			if (boss_type == lastBossType) //lazy formula to insure boss_type differs from last boss round
			{
				if (XORRandom(2)==0)
				boss_type = boss_type + XORRandom(3);
				else
				boss_type = boss_type - XORRandom(3);

				if (boss_type < 0)
				{
					boss_type = 0;
					if (boss_type == lastBossType)
						boss_type++;
				}
				if (boss_type > boss_variants-1) 
				{
					boss_type = boss_variants-1;
					if (boss_type == lastBossType)
						boss_type--;
				}
			}
			rules.set_s32("boss_type", boss_type);
		}
			tempDay = rules.get_s32("tempDay");

			//printf("bossRound = "+bossRound+" dayNumber = "+dayNumber+" boss_round_interval = "+boss_round_interval+" boss_round_counter = "+boss_round_counter+" boss_round_end = "+boss_round_end);
			//printf("dayNumber = "+dayNumber+" boss_round_counter = "+boss_round_counter+" tempDay = "+tempDay+" boss_spawn_with_zeds = "+boss_spawn_with_zeds+" bossRound ="+bossRound);
		if (dayNumber >= boss_enabled_day && tempDay < dayNumber && bossRound == 0 && boss_spawn_with_zeds == 0)
		{
			boss_round_counter++;
			//if (boss_round_counter >= boss_round_interval)
			
			tempDay = dayNumber;
			rules.set_s32("tempDay", tempDay);
			rules.set_s32("boss_round_counter", boss_round_counter);

		}

		if (dayNumber > boss_round_end && bossRound == 1 && boss_spawn_with_zeds == 0)
		{
			bossRound = 0;
			rules.set_s32("bossRound", bossRound);
		}
		//Is it boss round, are the enabled, are they spawning with zeds already?, are we not already on bossround?
		if ((boss_round_counter == boss_round_interval) && dayNumber >= boss_enabled_day && boss_spawn_with_zeds == 0 && bossRound == 0 && bossRound != 1)
		{
			bossRound = 1; //0 means no bosses, 1 is only bosses, 2 is both
			boss_round_counter = boss_round_length;
			rules.set_s32("bossRound", bossRound);
			boss_type = (XORRandom(boss_variants));
			rules.set_s32("boss_type", boss_type);
			boss_round_end = (dayNumber + boss_round_length);
			rules.set_s32("boss_round_end", boss_round_end);
			rules.set_s32("boss_round_counter", boss_round_counter);

		}

				string newRecord = "";
				if (dayNumber>=mapRecord) 
					newRecord = " - New Record!";
		//printf("Day : "+dayNumber+" BossRound: : "+bossRound+" nZeds: "+num_zombies+" bossType: "+boss_type+" num_Boss: "+num_bosses+" max_bosses: "+max_bosses+" boss_variants: "+boss_variants);
	   			if (dayNumber < boss_enabled_day)
				rules.SetGlobalMessage( "                                                                                                                                                                                                                                                                                                                                      \n\n"+
					"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nDay "+ dayNumber +"  |  This Maps Survival Record: Day "+mapRecord+newRecord+
					"             \n\n\n            "+server_title+":"+
					"\n\nBosses enabled on day "+boss_enabled_day+
					"\n\nBoss round every "+ boss_round_interval +" days after enabled"+
					"\n\nBosses spawn with zombies after day "+boss_spawn_anytime+
					"\n\nLand mobs get increased jump after day "+ land_mobs_increase_jump_day +
					"\n\nIncreased bomber mobs(wraiths) after day "+ extra_wraiths_day+
					"\n\n\n"+server_rules+
					"\n\n\nLose Condition: All players dead!"+
					"\n\nWin Condition: Beat/extend map survival record!" );
				if (dayNumber >= boss_enabled_day)
				rules.SetGlobalMessage( "                                                                                                                                                                                                                                                                                                                                      \n\n"+
					"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nDay "+ dayNumber +"  |  This Maps Survival Record: Day "+mapRecord+newRecord+
					"             \n\n\n            "+server_title+":"+
					"\n\nBosses enabled!"+
					"\n\nBoss round in "+ (boss_round_interval-boss_round_counter) +" day(s) which started on day "+boss_enabled_day+
					"\n\nBosses spawn with zombies after day "+boss_spawn_anytime+
					"\n\nLand mobs get increased jump after day "+ land_mobs_increase_jump_day +
					"\n\nIncreased bomber mobs(wraiths) after day "+ extra_wraiths_day+
					"\n\n\n"+server_rules+
					"\n\n\nLose Condition: All players dead!"+
					"\n\nWin Condition: Beat/extend map survival record!" );
				if (dayNumber >= boss_enabled_day && bossRound == 1)
				rules.SetGlobalMessage( "                                                                                                                                                                                                                                                                                                                                      \n\n"+
					"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nDay "+ dayNumber +"  |  This Maps Survival Record: Day "+mapRecord+newRecord+
					"             \n\n\n            "+server_title+":"+
					"\n\nBosses enabled!"+
					"\n\nBoss Round Currently Active!  Zombies coming back in "+ (boss_round_end - dayNumber) +" days."+
					"\n\nLand mobs get increased jump after day "+ land_mobs_increase_jump_day +
					"\n\nIncreased bomber mobs(wraiths) after day "+ extra_wraiths_day+
					"\n\n\n"+server_rules+
					"\n\n\nLose Condition: All players dead!"+
					"\n\nWin Condition: Beat/extend map survival record!" );
				if (dayNumber > boss_enabled_day && bossRound == 2)
				rules.SetGlobalMessage( "                                                                                                                                                                                                                                                                                                                                      \n\n"+
					"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nDay "+ dayNumber +"  |  This Maps Survival Record: Day "+mapRecord+newRecord+
					"             \n\n\n            "+server_title+":"+
					"\n\nBosses enabled!"+
					"\n\nNo more Boss rounds, bosses now spawn with zombies"+
					"\n\nLand mobs get increased jump after day "+ land_mobs_increase_jump_day +
					"\n\nIncreased bomber mobs(wraiths) after day "+ extra_wraiths_day+
					"\n\n\n"+server_rules+
					"\n\n\nLose Condition: All players dead!"+
					"\n\nWin Condition: Beat/extend map survival record!" );
				
		if (getGameTime() % (spawnRate) == 0 && num_zombies<max_zombies || (getGameTime() % (spawnRate) == 0 && bossRound == 1 && num_bosses < max_bosses) || (getGameTime() % (spawnRate) == 0 && bossRound == 2 && num_bosses < max_bosses))
        {
		
			CMap@ map = getMap();
			if (map !is null)
			{	

				Vec2f[] zombiePlaces;
				getMap().getMarkers("zombie spawn", zombiePlaces );
				
				if (zombiePlaces.length<=0)
				{
					for (int zp=8; zp<16; zp++)
					{
						Vec2f col;
						getMap().rayCastSolid( Vec2f(zp*8, 0.0f), Vec2f(zp*8, map.tilemapheight*8), col );
						col.y-=16.0;
						zombiePlaces.push_back(col);
						
						getMap().rayCastSolid( Vec2f((map.tilemapwidth-zp)*8, 0.0f), Vec2f((map.tilemapwidth-zp)*8, map.tilemapheight*8), col );
						col.y-=16.0;
						zombiePlaces.push_back(col);
					}
					//zombiePlaces.push_back(Vec2f((map.tilemapwidth-8)*4,(map.tilemapheight/2)*8));
				}
				//if (map.getDayTime()>0.1 && map.getDayTime()<0.2)
				//Test AI
				//int max_spawn = 0;
				//max_spawn = rules.get_s32("max_spawn");  && max_spawn < 1 
				//rules.set_s32("max_spawn", max_spawn); max_spawn++; 
				//if (getGameTime() % 30 == 0)
				//printf("Day : "+dayNumber+" BossRound: : "+bossRound+" nZeds: "+num_zombies+" bossType: "+boss_type+" num_Boss: "+num_bosses+" max_bosses: "+max_bosses);
				if (XORRandom(200)==0 && num_migrants < max_migrants)
				{
					//printf("migrantSpawned");
					Vec2f spM = zombiePlaces[XORRandom(zombiePlaces.length)];
					server_CreateBlob("migrant_bot", 0, spM);
				}
				if ((map.getDayTime()>0.1 || map.getDayTime()<0.4) && dayNumber != 1)
				{
					//Vec2f sp(XORRandom(4)*(map.tilemapwidth/4)*8+(90*8),(map.tilemapheight/2)*8);
					Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];

					if ((bossRound == 1 && tempDay == dayNumber) || bossRound == 2)
					{
						if (num_bosses < max_bosses) //num_zombies < max_zombies && 
						{
							printf("Boss Spawn! : "+boss_type+" BR: : "+bossRound+" bossT: "+boss_type+" nBoss: "+num_bosses);
	   						lastBossType = boss_type;
	   						rules.set_s32("lastBossType", lastBossType);
							switch(boss_type)
							{
								case 0: {
											if (num_dragons < max_dragons)
												server_CreateBlob( "BossRedDragon", -1, sp);
											break;
										}
								case 1: {server_CreateBlob( "BossRabidDog", -1, sp); break;}
								case 2: {server_CreateBlob( "BossGreenTroll", -1, sp); break;}
								case 3: {server_CreateBlob( "BossMinotaurKing", -1, sp); break;}
							}
							if (boss_type == 0)
							{
								boss_type = (XORRandom(boss_variants)+1);
								if (boss_type >= boss_variants)
									boss_type--;
								rules.set_s32("boss_type", boss_type);
							}
								
						}
					}

					if ((bossRound != 1 || bossRound == 2) && num_zombies<max_zombies)
					{
						
						if (dayNumber > extra_wraiths_day)
						{
							max_wraiths = max_wraiths * 2;
						}
						//max_zombieknights
						//max_gregs
						//max_wraiths
						//printf("Normal Zed Spawn");
						//printf("num_normal_skeletons = "+num_normal_skeletons+" num_normal_zombies = "+num_normal_zombies+" num_wraiths = "+num_wraiths+" num_zombieknights = "+num_zombieknights+" num_gregs = "+num_gregs);
						int r;
						//if (actdiff>9) r = XORRandom(9); else r = XORRandom(actdiff);
						r = XORRandom(9);
						int rr = XORRandom(9);
						if (r==8 && rr==8 && num_wraiths < max_wraiths || ((dayNumber > extra_wraiths_day) && r==8 && (num_wraiths < max_wraiths)))
							server_CreateBlob( "Wraith", -1, sp);
						else
						if (r==7 && num_gregs < max_gregs)
							server_CreateBlob( "Greg", -1, sp);
						else
						if (r>=5 && r<=6 && rr<=5 && num_zombieknights < max_zombieknights)
						{
							//if(XORRandom(2) == 0)
							server_CreateBlob( "ZombieKnight", -1, sp);
							//else
							//server_CreateBlob( "BossEmo", -1, sp);
						}
						else
						if (r>=3 && num_normal_zombies < max_normal_zombies)
						{
							server_CreateBlob( "Zombie", -1, sp);
						}
						else
						{
							if (num_normal_skeletons < max_skeletons)
								server_CreateBlob( "Skeleton", -1, sp);
						}
							
					}

					
					
					//server_CreateBlob( "Greg", -1, sp);
				}
			}
		}


        RulesCore::Update(); //update respawns
        if (getRules().get_bool("everyones_dead")) 
		{
			s32 mapRecord = getRules().get_s32("mapRecord");
			zCfg.add_s32(tRecordMap, mapRecord);
			zCfg.saveFile("serverSpecific_vars.cfg");
			printf("tRecordMap "+tRecordMap);
		}
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
        CTFPlayerInfo p(player.getUsername(), 0, "builder" );
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
		warn("sync");
		getRules().Sync("gold_structures",true);
    }

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{

		if (!rules.isMatchRunning()) { return; }

		if (victim !is null )
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}

    //checks
    void CheckTeamWon( )
    {
        if (!rules.isMatchRunning()) { return; }
		if (getRules().get_bool("everyones_dead")) 
		{
            rules.SetCurrentState(GAME_OVER);
			int gamestart = rules.get_s32("gamestart");			
			int day_cycle = getRules().daycycle_speed*60;			
			int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
			s32 mapRecord = rules.get_s32("mapRecord");
			if (dayNumber >= mapRecord)
            rules.SetGlobalMessage( "\n\n\n\n\n\n\n\nYou survived for "+ dayNumber+" days! \n\n\n\n Congrats! New Map Record!" );		
            else if (dayNumber < mapRecord)
            rules.SetGlobalMessage( "\n\n\n\n\n\n\n\nYou survived for "+ dayNumber+" days... \n\n\n\n You did not set a new map record!" );	
			getRules().set_bool("everyones_dead",false); 
		}
    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            CTFTeamInfo@ team_info = cast<CTFTeamInfo@>( teams[team] );
        }
    }

};

//pass stuff to the core from each of the hooks

void spawnPortal(Vec2f pos)
{
	server_CreateBlob("ZombiePortal",-1,pos+Vec2f(0,-24.0));
}


void spawnRandomTech(Vec2f pos)
{
	bool techstuff_spawn = getRules().get_bool("techstuff_spawn");
	if (techstuff_spawn)
	{
		int r = XORRandom(2);
		if (r == 0)
			server_CreateBlob("RocketLauncher",-1,pos+Vec2f(0,-16.0));
		else
		if (r == 1)
			server_CreateBlob("megasaw",-1,pos+Vec2f(0,-16.0));
	}
}

void spawnRandomScroll(Vec2f pos)
{
	bool scrolls_spawn = getRules().get_bool("scrolls_spawn");
	if (scrolls_spawn)
	{
		int r = XORRandom(3);
		if (r == 0)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "carnage" );				
	}
}
void onRestart( CRules@ this )
{

    ZombiesSpawns spawns();
    ZombiesCore core(this, spawns);
    Config(core);
    SetupScrolls(getRules());
	Vec2f[] zombiePlaces;
	getMap().getMarkers("zombie portal", zombiePlaces );
	if (zombiePlaces.length>0)
	{
		for (int i=0; i<zombiePlaces.length; i++)
		{
			spawnPortal(zombiePlaces[i]);
		}
	}
	Vec2f[] techPlaces;
	getMap().getMarkers("random tech", techPlaces );
	if (techPlaces.length>0)
	{
		for (int i=0; i<techPlaces.length; i++)
		{
			spawnRandomTech(techPlaces[i]);
		}
	}

	Vec2f[] scrollPlaces;
	getMap().getMarkers("random scroll", scrollPlaces );
	if (scrollPlaces.length>0)
	{
		for (int i=0; i<scrollPlaces.length; i++)
		{
			spawnRandomScroll(scrollPlaces[i]);
		}
	}

    //this.SetCurrentState(GAME);
    
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}

//modifications by Daimyo