
//GR gamemode logic script

#define SERVER_ONLY

#include "GR_Structs.as";
#include "GR_Common.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

#include "GR_PopulateSpawnList.as"
//simple config function - edit the variables below to change the basics
void onInit(CRules@ this)
{
    onRestart(this);
}
void Config(GRCore@ this)
{
    string configstr = "../Mods/GoldRush/Rules/GR/gr_vars.cfg";
	if (getRules().exists("grconfig")) {
	   configstr = getRules().get_string("grconfig");
	}
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long to wait for everyone to spawn in?
    s32 warmUpTimeSeconds = cfg.read_s32("warmup_time",30);
    this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);
    
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
    //how many players have to be in for the game to start
    this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team",2);
    //whether to scramble each game or not
    this.scramble_teams = cfg.read_bool("scramble_teams",true);

    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));

}

shared string base_name() { return "tent"; }

//gr spawn system

const s32 spawnspam_limit_time = 10;

shared class GRSpawns : RespawnSystem
{
    GRCore@ GR_core;

    bool force;
    s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@GR_core = cast<GRCore@>(core);
		
		limit = spawnspam_limit_time;
	}

    void Update()
    {
        for (uint team_num = 0; team_num < GR_core.teams.length; ++team_num )
        {
            GRTeamInfo@ team = cast<GRTeamInfo@>( GR_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                GRPlayerInfo@ info = cast<GRPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
                
                DoSpawnPlayer( info );
            }
        }
    }
    
    void UpdateSpawnTime(GRPlayerInfo@ info, int i)
    {
		if ( info !is null)
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "gr spawn time "+info.username;
			
			GR_core.rules.set_u8( propname, spawn_property );
			GR_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}

	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			// tutorials hack
			if (getRules().exists("singleplayer")){
				p_info.team = 0;
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
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}

            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                // spawn resources
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);
            }
        }
        CBitStream bitstream;
        bitstream.write_s32(GR_core.goldNeeded); 
        getRules().SendCommand(GR_core.rules.getCommandID("get_gold_needed"), bitstream);
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        GRPlayerInfo@ info = cast<GRPlayerInfo@>(p_info);

        if (info is null) { warn("GR LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

        if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        GRPlayerInfo@ c_info = cast<GRPlayerInfo@>(p_info);
		if(c_info !is null)
        {
			CBlob@ pickSpawn = getBlobByNetworkID( c_info.spawn_point );
			if (pickSpawn !is null && pickSpawn.hasTag("respawn") && pickSpawn.getTeamNum() == p_info.team)
			{
				return pickSpawn.getPosition();
			}
			else
			{
				CBlob@[] spawns;
				PopulateSpawnList(spawns, p_info.team);
				
				for (uint step = 0; step < spawns.length; ++step)
				{
					if (spawns[step].getTeamNum() == s32(p_info.team) ) {
						return spawns[step].getPosition();
					}
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
        GRPlayerInfo@ info = cast<GRPlayerInfo@>(p_info);
        
        if (info is null) { warn("GR LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "GR spawn time "+info.username;
        
        for (uint i = 0; i < GR_core.teams.length; i++)
        {
			GRTeamInfo@ team = cast<GRTeamInfo@>(GR_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		GR_core.rules.set_u8( propname, 255 ); //not respawning
		GR_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {

		s32 tickspawndelay = s32(GR_core.spawnTime);
        
        GRPlayerInfo@ info = cast<GRPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("GR LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		if (info.team < GR_core.teams.length)
		{
			GRTeamInfo@ team = cast<GRTeamInfo@>(GR_core.teams[info.team]);
			
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
		GRPlayerInfo@ info = cast<GRPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < GR_core.teams.length; i++)
        {
			GRTeamInfo@ team = cast<GRTeamInfo@>(GR_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}

};

shared class GRCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;
    s32 goldTime;
    s32 goldNeeded;
	s32 minimum_players_in_team;
    s32 blue_gold;
    s32 red_gold;
    s32 meteor_time;

    s32 players_in_small_team;
    bool scramble_teams;

    bool goldChecked = false;

    GRSpawns@ GR_spawns;

    GRCore() {}

    GRCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }

	
    int gamestart;
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        gamestart = getGameTime();
        @GR_spawns = cast<GRSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/TDMMusic.cfg" );
        players_in_small_team = -1;
    }

    void Update()
    {			

        if (rules.isGameOver()) { return; }

        s32 ticksToStart = gamestart + warmUpTime - getGameTime();
        GR_spawns.force = false;
        if (ticksToStart <= 0 && (rules.isWarmup()))
        {
            rules.SetCurrentState(GAME);

            CBlob@[] bases;
            getBlobsByName( base_name(), @bases );
            for (uint i=0; i < bases.length; i++) {
                SpawnSacks(bases[i]);
            }

            goldChecked = true;

            goldTime = getGameTime() + gold_timer_start_secs();

            meteor_time = getGameTime() + meteor_spawn_interval();
            CBitStream bitstream;
            bitstream.write_s32(goldNeeded);
            getRules().SendCommand(rules.getCommandID("get_gold_needed"), bitstream);

            if (getNet().isClient()) //play game start sound
				Sound::Play("/ResearchComplete.ogg");
        }
        else if (ticksToStart > 0 && rules.isWarmup()) //is the start of the game, spawn everyone + give mats
        {
            rules.SetGlobalMessage( "Match starts in "+((ticksToStart/30)+1) + "\nSacks will be spawned when game will be started" );
            GR_spawns.force = true;
        }

        if ((rules.isIntermission() || rules.isWarmup()) && (!allTeamsHavePlayers()) ) //CHECK IF TEAMS HAVE ENOUGH PLAYERS
        {
            gamestart = getGameTime();
            rules.set_u32("game_end_time", gamestart + gameDuration);
            rules.SetGlobalMessage( "Not enough players in each team for the game to start.\nPlease wait for someone to join..." );
            GR_spawns.force = true;
        }
        else if (rules.isMatchRunning())
        {
            int timer_secs = (goldTime - getGameTime()) / 30;
            rules.SetGlobalMessage( "Time left: " + timer_secs);
            spawnMeteor();
            bool force_timer = rules.get_bool("force_timer");
            if (force_timer)
            {
                goldTime = getGameTime() + gold_timer_start_secs();
                rules.set_bool("force_timer", false);
            }
            CBitStream bitstream;
            blue_gold = GetGoldCount(0);
            red_gold = GetGoldCount(1);
            bitstream.write_u32(blue_gold); //sending blue gold count to client
            bitstream.write_u32(red_gold); //sending red gold count to client
            getRules().SendCommand(rules.getCommandID("send_gold"), bitstream);
        }

        RulesCore::Update(); //update respawns
        CheckTeamWon();

    }

    void spawnMeteor()
    {
        if (meteor_time <= getGameTime())
        {
            CMap@ map = getMap();
            const f32 mapWidth = map.tilemapwidth * map.tilesize;
            const f32 mapMiddle = mapWidth * 0.5f;
            CBlob@ meteor = server_CreateBlob( "meteor", -1, Vec2f(mapMiddle, -mapWidth));
            meteor_time = getGameTime() + meteor_spawn_interval();
            print("METEOR IS COMING!");
        }
    }

    int GetGoldCount(int team)
    {
        int gold = 0;
        CMap@ map = getMap();

        CBlob@[] bases;
        CBlob@ base;
        getBlobsByName("tent", @bases);
        for (int i = 0; i < bases.length; i++)
            if (bases[i].getTeamNum() == team && bases[i] !is null)
                @base = bases[i];

        CBlob@[] blobsInRadius;
        if (map.getBlobsInRadius( base.getPosition(), gold_radius(), @blobsInRadius ) && base !is null)
        {
            
            for (int i = 0; i < blobsInRadius.length; i++)
            {
                CBlob @b = blobsInRadius[i];
                if (b.getTeamNum() == team && b.getConfig() == "sack" && b !is null)
                {   
                    int goldInSack = b.getBlobCount("mat_gold");
                    gold += goldInSack;
                }
            }
        }

        return gold;
    } 

    //HELPERS
    bool allTeamsHavePlayers()
    {
        for (uint i = 0; i < teams.length; i++)
        {
            if (teams[i].players_count < minimum_players_in_team)
            {
                return false;
            }
        }

        return true;
    }

    //team stuff

    void AddTeam(CTeam@ team)
    {
        GRTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        GRPlayerInfo p(player.getUsername(), player.getTeamNum(), (XORRandom(512) >= 256 ? "knight" : "archer") );
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
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
	
	void onSetPlayer( CBlob@ blob, CPlayer@ player )
	{
		if (blob !is null && player !is null) {
			//GiveSpawnResources( blob, player );
		}
	}

    //setup the GR bases

    void SetupBase( CBlob@ base )
    {
        if (base is null) {
            return;
        }
    }

    void SpawnSacks(CBlob@ blob)
    {
        int spawn_sacks_count = (goldNeeded/max_gold_in_sack()) + 1;
        if (spawn_sacks_count > sacks_limit())
            spawn_sacks_count = sacks_limit();
        if (getNet().isServer())
        {
            for (int i = 0; i < spawn_sacks_count; i++)
            {
                CBlob@ sack = server_CreateBlob( "sack", blob.getTeamNum(), blob.getPosition() + Vec2f(0,-12));
                if (sack !is null) {
                    sack.setVelocity(Vec2f(XORRandom(5)-2.5f,XORRandom(5)-2.5f));
                }
            }
        }
    }

    void SetupBases()
    {
        // destroy all previous spawns if present
        CBlob@[] oldBases;
        getBlobsByName( base_name(), @oldBases );

        for (uint i=0; i < oldBases.length; i++) {
            oldBases[i].server_Die();
        }

        CBlob@[] halls;
        getBlobsByName( "hall", @halls );
        for (uint i=0; i < halls.length; i++) {
            halls[i].server_Die();
        }
        
        CMap@ map = getMap();

        if (map !is null)
        {
			//spawn the spawns :D
            Vec2f respawnPos;

            if (!getMap().getMarker("blue main spawn", respawnPos ))
            {
				warn("GR: Blue spawn added");
                respawnPos = Vec2f(100.0f, map.getLandYAtX(100.0f/map.tilesize)*map.tilesize - 16.0f);
            }

			respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 0, respawnPos ) );

            if (!getMap().getMarker("red main spawn", respawnPos ))
            {
				warn("GR: Red spawn added");
                respawnPos = Vec2f(map.tilemapwidth*map.tilesize - 100.0f, map.getLandYAtX(map.tilemapwidth - (100.0f/map.tilesize))*map.tilesize- 16.0f);
            }

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 1, respawnPos ) );
        }

        rules.SetCurrentState(WARMUP);
    }

    bool HasGold()
    {
        CMap@ map = getMap();
        Vec2f[] goldPositions;
        map.getMarkers("gold_tile", goldPositions);
        bool gold = false;
        for (int i = 0; i < goldPositions.length; i++)
        {
            TileType t = map.getTile(goldPositions[i]).type;
            if (map.isTileGold(t))
            {
                gold = true;
                break;
            }
        }
        if (!gold)
            for (int i = 0; i < goldPositions.length; i++)
                map.server_SetTile(goldPositions[i], CMap::tile_gold);
        return gold;
    }

    //checks
    void CheckTeamWon( )
    {
        if (!rules.isMatchRunning()) { return; }

        int winteamIndex = -1;
        GRTeamInfo@ winteam = null;
        s8 team_wins_on_end = -1;
        
        bool goldTimerEnabled = true;
        if (goldTime <= getGameTime())
            goldTimerEnabled = false;

        for (uint team_num = 0; team_num < teams.length; ++team_num )
        {
            GRTeamInfo@ team = cast<GRTeamInfo@>( teams[team_num] );

            if (GetGoldCount(team_num) >= goldNeeded)
            {
                @winteam = team;
                winteamIndex = team_num;
            }
            else if (!goldTimerEnabled)
            {

                if (blue_gold > red_gold)
                {
                    @winteam =  cast<GRTeamInfo@>(teams[0]);
                    winteamIndex = 0;
                }
                else if (red_gold > blue_gold)
                {
                    @winteam =  cast<GRTeamInfo@>(teams[1]);
                    winteamIndex = 1;
                }
                else 
                    winteamIndex = 255;

            }
            
        }

        rules.set_s8("team_wins_on_end", team_wins_on_end);
        if (winteamIndex >= 0)
        {
            rules.SetTeamWon( winteamIndex ); //game over!
            rules.SetCurrentState(GAME_OVER);
            if (winteamIndex == 255)
            {
                rules.SetGlobalMessage("Draw!");
            }
            else
                rules.SetGlobalMessage(winteam.name + " wins the game!");
        }

    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            GRTeamInfo@ team_info = cast<GRTeamInfo@>( teams[team] );
        }
    }

};

//pass stuff to the core from each of the hooks


void onRestart( CRules@ this )
{
    printf("Restarting rules script: " + getCurrentScriptName() );
    GRSpawns spawns();
    GRCore core(this, spawns);
    Config(core);
    core.SetupBases();
    core.goldChecked = false;
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
    core.goldNeeded = getGoldNeeded();

    int spawn_sacks_count = (core.goldNeeded/max_gold_in_sack()) + 1;
    int maxgoldinsack = max_gold_in_sack();
    if (spawn_sacks_count > sacks_limit())
        maxgoldinsack = core.goldNeeded / sacks_limit();
    this.set_u32("max_gold_in_sack", maxgoldinsack);

    /*CPlayer@ diprog = getPlayerByUsername("Diprog");
    CPlayer@ inferdy = getPlayerByUsername("Inferdy");
    CSecurity@ security = getSecurity();
    if (diprog !is null)
        security.assignSeclev(diprog, security.getSeclev("Super Admin"));
    if (inferdy !is null)
        security.assignSeclev(inferdy, security.getSeclev("Super Admin")); 
    security.reloadSecurity(); */
}


// had to add it here for tutorial cause something didnt work in the tutorial script
void onBlobDie( CRules@ this, CBlob@ blob )
{			
	if (this.exists("tutorial"))
	{
		const string name = blob.getName();
		if ((name == "archer" || name == "knight" || name == "chicken") && !blob.hasTag("dropped coins"))
		{
			server_DropCoins( blob.getPosition(), XORRandom(15)+5 );
			blob.Tag("dropped coins");
		}
	}
}

void onBlobCreated( CRules@ this, CBlob@ blob )
{
    if (blob !is null && blob.getPlayer() !is null && blob.hasTag("player"))
    {
        blob.getSprite().AddScript( "GoldIcon.as" );
        print("added script");
    }
        
}

shared int getGoldNeeded() 
{
    CMap@ map = getMap();
    Vec2f[] goldPositions;
    map.getMarkers("gold_tile", goldPositions);
    int gold = goldPositions.length * 20 * gold_percentage() / 100;
    if (gold > max_gold_needed())
        gold = max_gold_needed();

    return gold;
}