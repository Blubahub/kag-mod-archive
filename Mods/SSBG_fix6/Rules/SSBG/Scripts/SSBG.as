
//SSBG gamemode logic script

#define SERVER_ONLY

#include "SSBG_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

//simple config function - edit the variables below to change the basics

void Config(SSBGCore@ this)
{
	CRules@ rules = getRules();
    //how long to wait for everyone to spawn in?
    s32 warmUpTimeSeconds = 5;
    this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);
    this.gametime = getGameTime() + this.warmUpTime;
    //how many deaths needed to lose the match, per player on the smallest team
    this.deaths_to_lose_per_player = 4;
    //how long for the game to play out?
    s32 gameDurationMinutes = 10;
    this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes) + this.warmUpTime;
    //spawn after death time - set in gamemode.cfg, or override here
    f32 spawnTimeSeconds = rules.playerrespawn_seconds;
    this.spawnTime = (getTicksASecond() * spawnTimeSeconds);
    //how many players have to be in for the game to start
    this.minimum_players_in_team = 1;
    //whether to scramble each game or not
    this.scramble_teams = true;
    // modifies if the fall damage velocity is higher or lower - SSBG has lower velocity
    rules.set_f32("fall vel modifier", 1.3f);
	
	sv_gravity = 9;
}

//SSBG spawn system

shared class SSBGSpawns : RespawnSystem
{
    SSBGCore@ SSBG_core;

    bool force;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@SSBG_core = cast<SSBGCore@>(core);
	}

    void Update()
    {
        for (uint team_num = 0; team_num < SSBG_core.teams.length; ++team_num )
        {
            SSBGTeamInfo@ team = cast<SSBGTeamInfo@>( SSBG_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                SSBGPlayerInfo@ info = cast<SSBGPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
                
                info.thrownBomb = false;
                DoSpawnPlayer( info );
            }
        }
    }
    
    void UpdateSpawnTime(SSBGPlayerInfo@ info, int i)
    {
		//default
		u8 spawn_property = 254;
		
		if ( i == 0 && info !is null && info.can_spawn_time > 0) {
			info.can_spawn_time--;
			spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
		}

		string propname = "SSBG spawn time "+info.username;
		SSBG_core.rules.set_u8( propname, spawn_property );
		if (info !is null && info.can_spawn_time >= 0)
		{
			SSBG_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (force || canSpawnPlayer(p_info))
        {
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null) {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
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
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        SSBGPlayerInfo@ info = cast<SSBGPlayerInfo@>(p_info);

        if (info is null) { warn("SSBG LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

        if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        CBlob@[] spawns;

        if (getBlobsByName( "tdm_spawn", @spawns ))
        {
            for (uint step = 0; step < spawns.length; ++step)
            {
                if (spawns[step].getTeamNum() == s32(p_info.team) ) {
                    return spawns[step].getPosition();
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
        SSBGPlayerInfo@ info = cast<SSBGPlayerInfo@>(p_info);
        
        if (info is null) { warn("SSBG LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "SSBG spawn time "+info.username;
        
        for (uint i = 0; i < SSBG_core.teams.length; i++)
        {
			SSBGTeamInfo@ team = cast<SSBGTeamInfo@>(SSBG_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		SSBG_core.rules.set_u8( propname, 255 ); //not respawning
		SSBG_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
        info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
        s32 tickspawndelay = s32(SSBG_core.spawnTime);
        print("ADD SPAWN FOR " + player.getUsername());
        SSBGPlayerInfo@ info = cast<SSBGPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("SSBG LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		if (info.team < SSBG_core.teams.length)
		{
			SSBGTeamInfo@ team = cast<SSBGTeamInfo@>(SSBG_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		SSBGPlayerInfo@ info = cast<SSBGPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < SSBG_core.teams.length; i++)
        {
			SSBGTeamInfo@ team = cast<SSBGTeamInfo@>(SSBG_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}

};

shared class SSBGCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;
    s32 minimum_players_in_team;
    s32 deaths_to_lose;
    s32 deaths_to_lose_per_player;

    s32 players_in_small_team;
    bool scramble_teams;

    SSBGSpawns@ SSBG_spawns;

    SSBGCore() {}

    SSBGCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }

    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        gametime = getGameTime();
        @SSBG_spawns = cast<SSBGSpawns@>(_respawns);
     //   server_CreateBlob( "Entities/Meta/SSBGMusic.cfg" );
        players_in_small_team = -1;
    }

    int gametime;
    void Update()
    {			
        //HUD
        //dirty hack time...
        // lets save the CPU and do this only once in a while
        if (getGameTime() % 16 == 0)
        {
            updateHUD();
        }

        if (rules.isGameOver()) { return; }

        s32 ticksToStart = gametime - getGameTime();
        SSBG_spawns.force = false;

        if (ticksToStart <= 0 && (rules.isWarmup()))
        {
            rules.SetCurrentState(GAME);
        }
        else if (ticksToStart > 0 && rules.isWarmup()) //is the start of the game, spawn everyone + give mats
        {
            rules.SetGlobalMessage( "Match starts in "+((ticksToStart/30)+1) );
            SSBG_spawns.force = true;

            //set deaths and cache #players in smaller team

            if (players_in_small_team == -1 || (getGameTime() % 30) == 4)
            {
                players_in_small_team = 100;

                for (uint team_num = 0; team_num < teams.length; ++team_num )
                {
                    SSBGTeamInfo@ team = cast<SSBGTeamInfo@>( teams[team_num] );

                    if (team.players_count < players_in_small_team)
                    {
                        players_in_small_team = team.players_count;
                    }
                }

                deaths_to_lose = Maths::Max(players_in_small_team,1) * deaths_to_lose_per_player;
            }
        }

        if ((rules.isIntermission() || rules.isWarmup()) && (!allTeamsHavePlayers()) ) //CHECK IF TEAMS HAVE ENOUGH PLAYERS
        {
            gametime = getGameTime();
            rules.set_u32("game_end_time", gametime + gameDuration);
            rules.SetGlobalMessage( "Not enough players in each team for the game to start.\nPlease wait for someone to join..." );
            SSBG_spawns.force = true;
        }
        else if (rules.isMatchRunning())
        {
            rules.SetGlobalMessage( "" );

            //if (getGameTime() % 11 == 0) {
            //    CheckKnightThrownBomb();
            //}
        }

      //  SpawnPowerups();
        RulesCore::Update(); //update respawns
        CheckTeamWon();

		if (getGameTime() % 2000 == 0)
			SpawnBombs();
    }

	void updateHUD()
	{
		bool hidedeaths = (rules.isIntermission() || rules.isWarmup());
		CBitStream serialised_team_hud;
		serialised_team_hud.write_u16(0x5afe); //check bits

		for (uint team_num = 0; team_num < teams.length; ++team_num )
		{
			SSBG_HUD hud;
			SSBGTeamInfo@ team = cast<SSBGTeamInfo@>( teams[team_num] );
			hud.team_num = team_num;
			hud.deaths = team.deaths;
			hud.deaths_limit = (hidedeaths ? -1 : deaths_to_lose);
			string temp = "";

			for ( uint player_num = 0; player_num < players.length; ++player_num )
			{
				SSBGPlayerInfo@ player = cast<SSBGPlayerInfo@>( players[player_num] );

				if (player.team == team_num)
				{
					CPlayer@ e_player = getPlayerByUsername(player.username);

					if (e_player !is null)
					{
						CBlob@ player_blob = e_player.getBlob();
						bool blob_alive = player_blob !is null && player_blob.getHealth() > 0.0f;

						if (blob_alive)
						{
							string player_char = "k"; //default to sword

							if (player_blob.getName() == "archer") {
								player_char = "a";
							}

							temp += player_char;
						}
						else
						{
							temp += "s";
						}
					}
				}
			}

			hud.unit_pattern = temp;

			if (team.spawns.length > 0 && !rules.isIntermission()) {
				hud.spawn_time = (cast<SSBGPlayerInfo@>(team.spawns[0]).can_spawn_time / 30);
			}
			else {
				hud.spawn_time = 255;
			}

			hud.Serialise(serialised_team_hud);
		}

		rules.set_CBitStream("SSBG_serialised_team_hud",serialised_team_hud);
		rules.Sync("SSBG_serialised_team_hud",true);
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
        SSBGTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        SSBGPlayerInfo p(player.getUsername(), player.getTeamNum(), player.isBot() ? "knight" : (XORRandom(512) >= 256 ? "knight" : "archer") );
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
    }

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null )
		{		
			addDeath(victim.getTeamNum());	
		}
	}
	
	void onSetPlayer( CBlob@ blob, CPlayer@ player )
	{
		if (blob !is null && player !is null) {
			GiveSpawnResources( blob, player );
		}
	}

    //setup the SSBG bases

    void SetupBase( CBlob@ base )
    {
        if (base is null) {
            return;
        }

        //nothing to do
    }


    void SetupBases()
    {
        const string base_name = "tdm_spawn";
        // destroy all previous spawns if present
        CBlob@[] oldBases;
        getBlobsByName( base_name, @oldBases );

        for (uint i=0; i < oldBases.length; i++) {
            oldBases[i].server_Die();
        }

        //spawn the spawns :D
        CMap@ map = getMap();

        if (map !is null)
        {
            // team 0 ruins
            Vec2f respawnPos;

            if (!getMap().getMarker("blue main spawn", respawnPos ))
            {
				warn("SSBG: Blue spawn marker not found on map");
				if ( map.tilesize > 0 )
					respawnPos = Vec2f(150.0f, map.getLandYAtX(150.0f/map.tilesize)*map.tilesize - 32.0f);
				else
					respawnPos = Vec2f(0.0f, 0.0f);
            }

            respawnPos.y -= 16.0f;
            SetupBase( server_CreateBlob( base_name, 0, respawnPos ) );

            // team 1 ruins
            if (!getMap().getMarker("red main spawn", respawnPos ))
            {
				warn("SSBG: Red spawn marker not found on map");
                respawnPos = Vec2f(map.tilemapwidth*map.tilesize - 150.0f, map.getLandYAtX(map.tilemapwidth - (150.0f/map.tilesize))*map.tilesize- 32.0f);
            }

            respawnPos.y -= 16.0f;
            SetupBase( server_CreateBlob( base_name, 1, respawnPos ) );
        }

        rules.SetCurrentState(WARMUP);
    }

    //checks
    void CheckTeamWon( )
    {
        if (!rules.isMatchRunning()) { return; }

        int loseteamIndex = -1;
        SSBGTeamInfo@ loseteam = null;
        s8 team_loses_on_end = -1;
        int highdeaths = 0;

        for (uint team_num = 0; team_num < teams.length; ++team_num )
        {
            SSBGTeamInfo@ team = cast<SSBGTeamInfo@>( teams[team_num] );

            if (team.deaths >= deaths_to_lose)
            {
                @loseteam = team;
                loseteamIndex = team_num;
                break;
            }

            if (team.deaths > highdeaths)
            {
                highdeaths = team.deaths;
                team_loses_on_end = team_num;
            }
            else if (team.deaths > 0 && team.deaths == highdeaths)
            {
                team_loses_on_end = -1;
            }
        }

        rules.set_s8("team_loses_on_end", team_loses_on_end);

        if (loseteamIndex >= 0)
        {
			// add winning team coins
			if (rules.isMatchRunning())
			{					
				CBlob@[] players;
				getBlobsByTag( "player", @players ); 
				for (uint i=0; i < players.length; i++) 
				{
					CPlayer@ player = players[i].getPlayer();										
					if (player !is null && player.getTeamNum() != loseteamIndex) 	{
						player.server_setCoins( player.getCoins() + 10 );
					}
				}
			}
			
			rules.SetTeamWon( loseteamIndex ); //game over!
            rules.SetCurrentState(GAME_OVER);
            rules.SetGlobalMessage( loseteam.name + " has been defeated!" );
			if (loseteamIndex == 1)
			{
			Sound::Play( "/RedTeamWins.ogg" );
			}
			else
			{
			Sound::Play( "/BlueTeamWins.ogg" );
			}
        }
    }

    void addDeath(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            SSBGTeamInfo@ team_info = cast<SSBGTeamInfo@>( teams[team] );
            team_info.deaths++;
        }
    }

    void CheckKnightThrownBomb()
    {
        CBlob@[] knights;
        getBlobsByName( "knight", @knights );

        for (uint i=0; i < knights.length; i++) {
            CBlob@ knight = knights[i];

            if (knight.getPlayer() !is null)
            {
                CBlob@ carried = knight.getCarriedBlob();

                if (carried !is null && carried.getName() == "bomb")
                {
                    PlayerInfo@ p_info = getInfoFromName( knight.getPlayer().getUsername() );

                    if (p_info !is null)
                    {
                        SSBGPlayerInfo@ SSBG_info = cast<SSBGPlayerInfo@>(p_info);

                        if (SSBG_info !is null) {
                            SSBG_info.thrownBomb = true;
                        }
                    }
                }
            }
        }
    }

    void SpawnPowerups()
    {
        if (getGameTime() % 200 == 0 && XORRandom(12) == 0) {
            SpawnPowerup();
        }
    }

    void SpawnPowerup()
    {
        CBlob@ powerup = server_CreateBlob( "powerup", -1, Vec2f( getMap().tilesize * 0.5f * getMap().tilemapwidth, 50.0f ) );
    }

	void SpawnBombs()
	{
		Vec2f[] bombPlaces;
		if (getMap().getMarkers("bombs", bombPlaces )) 
		{
			for (uint i = 0; i < bombPlaces.length; i++)
			{
				server_CreateBlob( "mat_bombs", -1, bombPlaces[i] );
			}
		}
	}


	void GiveSpawnResources( CBlob@ blob, CPlayer@ player )
	{
		int multiplier = 1;

		// give

	   /* if (blob.getName() == "knight") // only give bombs on warmup
		{
			// check if knight has thrown bomb
			//SSBGPlayerInfo@ SSBG_info = getSSBGPlayerInfoFromName( this, player.getUsername() );
			//if (SSBG_info !is null && SSBG_info.thrownBomb) {
				//return;               // thrown - exit
			//}

			CBlob@ mat = server_CreateBlob( "mat_bombs" );

			if (mat !is null)
			{
				if (!blob.server_PutInInventory(mat)) {
					mat.setPosition( blob.getPosition() );
				}

				mat.server_SetQuantity(1*multiplier);
			}
		} */

		if (blob.getName() == "archer")
		{
			// first check if its in surroundings
			CBlob@[] blobsInRadius;	   
			CMap@ map = getMap();
			bool found = false;
			if (map.getBlobsInRadius( blob.getPosition(), 60.0f, @blobsInRadius )) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if (b.getName() == "mat_arrows")
					{
						if (!found)	{
							blob.server_PutInInventory(b);
						}
						else
							b.server_Die();
						found = true;
					}
				}															 			
			}

			if (!found)
			{
				CBlob@ mat = server_CreateBlob( "mat_arrows" );
				if (mat !is null)
				{
					if (!blob.server_PutInInventory(mat)) {
						mat.setPosition( blob.getPosition() );
					}									   
				}
			}
		}

		if (sv_test)
		{
			player.server_setCoins(100);
		}
	}

};

//pass stuff to the core from each of the hooks

void Reset(CRules@ this)
{
    printf("Restarting rules script: " + getCurrentScriptName() );
    SSBGSpawns spawns();
    SSBGCore core(this, spawns);
    Config(core);
    core.SetupBases();
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	Sound::Play( "/ReadyGo.ogg" );
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

