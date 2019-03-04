
//CTF gamemode logic script

#define SERVER_ONLY

#include "NECRO_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

#include "CTF_PopulateSpawnList.as";

#include "Tickets.as";

void Config(NecroCore@ this)
{
    ConfigFile cfg;
    if (!cfg.loadFile("../Mods/Necromancer/Rules/NECRO/custom_necro_vars.cfg")){
        cfg.loadFile("../Mods/Necromancer/Rules/NECRO/necro_vars.cfg");
    }
    
    s32 warmUpTimeSeconds = cfg.read_s32("warmup_time",0);
    this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);

    s32 gameDurationMinutes = cfg.read_s32("game_time",-1);
    if (gameDurationMinutes <= 0) {
        this.gameDuration = 0;
        getRules().set_bool("no timer", true);
    } else {
        this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
    }
    this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team",1);
    this.scramble_teams = cfg.read_bool("scramble_teams",false);
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 10));
    s32 max_necros = cfg.read_s32("max_necromancers", 1);
    getRules().set_s32("max_necros", max_necros);
}

shared string base_name() { return "tent"; }
shared string flag_name() { return "ctf_flag"; }
shared string flag_spawn_name() { return "flag_base"; }

//NECRO spawn system

const s32 spawnspam_limit_time = 10;

shared class NecroSpawns : RespawnSystem
{
    NecroCore@ Necro_Core;

    bool force;
    s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Necro_Core = cast<NecroCore@>(core);
		
		limit = spawnspam_limit_time;
	}

    void Update()
    {
        for (uint team_num = 0; team_num < Necro_Core.teams.length; ++team_num )
        {
            NecroTeamInfo@ team = cast<NecroTeamInfo@>( Necro_Core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
                
                DoSpawnPlayer( info );
            }
        }
    }
    
    void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
    {
		if ( info !is null)
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "ctf spawn time "+info.username;
			
			Necro_Core.rules.set_u8( propname, spawn_property );
			Necro_Core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
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

			//-----@TICKETS
			
            if(getRules().isMatchRunning() && decrementTickets(getRules(), p_info.team)==1){
                    p_info.spawnsCount++;
                    RemovePlayerFromSpawn(player);
            }else{
                if (p_info.team == 1)
                    p_info.blob_name = "necromancer"; //hard-set the respawn blob
                else if (p_info.blob_name == "necromancer" || p_info.blob_name == "kagician")
                    p_info.blob_name = "builder";

                CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);
                if (playerBlob !is null)
                {
                    p_info.spawnsCount++;
                    RemovePlayerFromSpawn(player);
                }
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);

        if (info is null) { warn("NECRO LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

        if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ c_info = cast<CTFPlayerInfo@>(p_info);
		if(c_info !is null)
        {
			CBlob@ pickSpawn = getBlobByNetworkID( c_info.spawn_point );
			if (pickSpawn !is null &&
				pickSpawn.hasTag("respawn") &&
				pickSpawn.getTeamNum() == p_info.team)
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
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);
        
        if (info is null) { warn("NECRO LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "ctf spawn time "+info.username;
        
        for (uint i = 0; i < Necro_Core.teams.length; i++)
        {
			NecroTeamInfo@ team = cast<NecroTeamInfo@>(Necro_Core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Necro_Core.rules.set_u8( propname, 255 ); //not respawning
		Necro_Core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		//DONT set this zero - we can re-use it if we didn't actually spawn
		//info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {// @TICKETS
    	CRules@ rules = getRules();
        int teamNum=player.getTeamNum();

        if(!isSpawning(player)){              //if they are already spawning, continue with readding to spawn
            if(rules.isMatchRunning()){                      //check if build time
                if(ticketsRemaining(rules, teamNum)<=0/*-spawns.length<=0*/){          //this allows them to be on spawn list even if there will be no tickets left when they get to spawn
                    checkGameOver(rules, teamNum);
                    return;
                }
            }
        }

        
		s32 tickspawndelay = s32(Necro_Core.spawnTime);
        
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("NECRO LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

        //clamp it so old bad values don't get propagated
        s32 old_spawn_time = Maths::Max(0, Maths::Min(info.can_spawn_time, tickspawndelay));

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		if (info.team < Necro_Core.teams.length)
		{
			NecroTeamInfo@ team = cast<NecroTeamInfo@>(Necro_Core.teams[info.team]);

			info.can_spawn_time = ((old_spawn_time > 30) ? old_spawn_time : tickspawndelay);
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY! " + info.team + " / " + Necro_Core.teams.length);
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < Necro_Core.teams.length; i++)
        {
			NecroTeamInfo@ team = cast<NecroTeamInfo@>(Necro_Core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}

};

shared class NecroCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

	s32 minimum_players_in_team;

    s32 players_in_small_team;
    bool scramble_teams;

    NecroSpawns@ necro_spawns;

    NecroCore() {}

    NecroCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }

	
    int gamestart;
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        gamestart = getGameTime();
        @necro_spawns = cast<NecroSpawns@>(_respawns);
        _rules.set_string("music - base name", base_name());
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
        players_in_small_team = -1;
    }

    void Update()
    {			
        //HUD
        // lets save the CPU and do this only once in a while
        if (getGameTime() % 16 == 0)
        {
            updateHUD();
        }

        if (rules.isGameOver()) { return; }

        s32 ticksToStart = gamestart + warmUpTime - getGameTime();
        necro_spawns.force = false;

        if (ticksToStart <= 0 && (rules.isWarmup()))
        {
            rules.SetCurrentState(GAME);
        }
        else if (ticksToStart > 0 && rules.isWarmup()) //is the start of the game, spawn everyone + give mats
        {
            rules.SetGlobalMessage( "Match starts in "+((ticksToStart/30)+1) );
            necro_spawns.force = true;
        }

        if ((rules.isIntermission() || rules.isWarmup()) && (!allTeamsHavePlayers()) ) //CHECK IF TEAMS HAVE ENOUGH PLAYERS
        {
            gamestart = getGameTime();
            rules.set_u32("game_end_time", gamestart + gameDuration);
            rules.SetGlobalMessage( "Not enough players in each team for the game to start.\nPlease wait for someone to join..." );
            necro_spawns.force = true;
        }
        else if (rules.isMatchRunning())
        {
            rules.SetGlobalMessage( "" );
        }

		/*
		 * If you want to do something tricky with respawning flags and stuff here, go for it
		 */

        RulesCore::Update(); //update respawns
        CheckTeamWon();

    }

	void updateHUD()
	{
		
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
        NecroTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
    	if (getRules().exists("singleplayer") ){
    		team = 0;
    	}
    	else{
    		team = player.getTeamNum();
    	}
        CTFPlayerInfo p(player.getUsername(), 0, team == 1 ? "necromancer" : "builder" );
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

    //setup the CTF bases

    void SetupBase( CBlob@ base )
    {
        if (base is null) {
            return;
        }

        //nothing to do
    }

    void SetupBases()
    {
        // destroy all previous spawns if present
        CBlob@[] oldBases;
        getBlobsByName( base_name(), @oldBases );

        for (uint i=0; i < oldBases.length; i++) {
            oldBases[i].server_Die();
        }
        
        CMap@ map = getMap();

        if (map !is null)
        {
			//spawn the spawns :D
            Vec2f respawnPos;

            if (!getMap().getMarker("blue main spawn", respawnPos ))
            {
				warn("CTF: Blue spawn added");
                respawnPos = Vec2f(100.0f, map.getLandYAtX(100.0f/map.tilesize)*map.tilesize - 16.0f);
            }

			respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 0, respawnPos ) );

            if (!getMap().getMarker("red main spawn", respawnPos ))
            {
				warn("CTF: Red spawn added");
                respawnPos = Vec2f(map.tilemapwidth*map.tilesize - 100.0f, map.getLandYAtX(map.tilemapwidth - (100.0f/map.tilesize))*map.tilesize- 16.0f);
            }

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 1, respawnPos ) );
        }

        rules.SetCurrentState(WARMUP);
    }

    //checks
    void CheckTeamWon( )
    {
        if (!rules.isMatchRunning()) { return; }
    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            NecroTeamInfo@ team_info = cast<NecroTeamInfo@>( teams[team] );
        }
    }

};

//pass stuff to the core from each of the hooks

void Reset( CRules@ this )
{
    printf("Restarting rules script: " + getCurrentScriptName() );
    NecroSpawns spawns();
    NecroCore core(this, spawns);
    Config(core);
    core.SetupBases();
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}

void onRestart( CRules@ this )
{
	Reset( this );
}

void onInit( CRules@ this )
{
	Reset( this );
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