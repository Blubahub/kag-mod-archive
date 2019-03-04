
//TDM gamemode logic script

#define SERVER_ONLY

#include "CP_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

//simple config function - edit the variables below to change the basics TDMTeamInfo

void Config(CPCore@ this)
{
    //whether to scramble each game or not
    this.scramble_teams = true;
    // modifies if the fall damage velocity is higher or lower - TDM has lower velocity
    this.rules.set_f32("fall vel modifier", 1.3f);
}

//TDM spawn system

shared class CPSpawns : RespawnSystem
{
    CPCore@ CP_core;

    bool force;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@CP_core = cast<CPCore@>(core);
	}

    void Update()
    {
        for (uint team_num = 0; team_num < CP_core.teams.length; ++team_num )
        {
            CPTeamInfo@ team = cast<CPTeamInfo@>( CP_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CPPlayerInfo@ info = cast<CPPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info);
                
                DoSpawnPlayer( info );
            }
        }
    }
    
    void UpdateSpawnTime(CPPlayerInfo@ info)
    {
		string propname = "cp spawn time "+info.username;
		
		CP_core.rules.set_u8( propname, info.can_spawn_time-- / 30 );
		if (info !is null && info.can_spawn_time >= 0)
		{
			CP_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null) {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != p_info.team)
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
			
			if(getRules().exists("ClassPlayer"+player.getNetworkID())){
				p_info.blob_name = getRules().get_string("ClassPlayer"+player.getNetworkID());
			}

            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(player), p_info);

            if (playerBlob !is null)
            {
                // spawn resources
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);
            }
			CGridMenu@ menu = getGridMenuByName("Pick spawn point");
			if (menu !is null) {
				menu.kill = true;
			}
			@menu = getGridMenuByName("Pick Class");
			if (menu !is null) {
				menu.kill = true;
			}
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CPPlayerInfo@ info = cast<CPPlayerInfo@>(p_info);

        if (info is null) { warn("TDM LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }
		
        if (getRules().get_u8("Team_Points"+p_info.team) <= 0) { return false; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(CPlayer@ player)
    {
		CRules@ Rule = getRules();
		CBlob@[] blob;
		
		s8 spawnPoint = Rule.get_s8("SpawnPoint_Player"+player.getNetworkID());
		
		getBlobsByTag("Point" + spawnPoint, @blob);
			
		return CheckSpawnPoint( blob[0], player.getTeamNum(), spawnPoint );
    }
	
	Vec2f CheckSpawnPoint(CBlob@ CP_point, u8 TeamNum, s8 index)
	{
		if(CP_point.getTeamNum() == TeamNum)
		{
			return CP_point.getPosition();
		}
		else
		{
			
			s8 swap = 1;
			//if(TeamNum != 0){
			//	swap = -1;
			//}
			u8 howMuch_Points = getRules().get_u8("Points_Count");
			for(s8 i=1; index-i >= 0 || index+i < howMuch_Points; i++)
			{				
				if(index - i*swap >= 0){
					CBlob@[] blob1;
					getBlobsByTag("Point" + (index - i*swap), @blob1);
					if(blob1[0].getTeamNum() == TeamNum){
						return blob1[0].getPosition();
					}
				}
				
				if(index + i*swap < howMuch_Points){
					CBlob@[] blob2;
					getBlobsByTag("Point" + (index + i*swap), @blob2);
					if(blob2[0].getTeamNum() == TeamNum){
						return blob2[0].getPosition();
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
        CPPlayerInfo@ info = cast<CPPlayerInfo@>(p_info);
        
        if (info is null) { warn("CP LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "cp spawn time "+info.username;
        
        for (uint i = 0; i < CP_core.teams.length; i++)
        {
			CPTeamInfo@ team = cast<CPTeamInfo@>(CP_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		CP_core.rules.set_u8( propname, 255 ); //not respawning
		CP_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
        info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
		
        print("ADD SPAWN FOR " + player.getUsername());
        CPPlayerInfo@ info = cast<CPPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("CP LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		if (info.team < CP_core.teams.length)
		{
			CPTeamInfo@ team = cast<CPTeamInfo@>(CP_core.teams[info.team]);
			
			s32 time = getGameTime();
			s32 lastSpawnTime = time - team.LastSpawnTime;
			s32 coreSpawn =  s32(CP_core.rules.playerrespawn_seconds * getTicksASecond());
			
			if( lastSpawnTime <= coreSpawn/2){
				info.can_spawn_time = coreSpawn - lastSpawnTime;
			}
			else{
				info.can_spawn_time = coreSpawn; 
				team.LastSpawnTime = time;
			}
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }
};

//===========================================================================================//

shared class CPCore : RulesCore
{	
    s32 warmUpTime;
	s32 startScore;

    s32 players_in_small_team;
    bool scramble_teams;
	
	u8 DayCycleTime = 0;
	u8 NightCycleTime = 0;
	float IndexCycleTime = 0.1;
	
	CRules@ Rule = getRules();

    CPSpawns@ tdm_spawns;

    CPCore() {}

    CPCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }

    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @tdm_spawns = cast<CPSpawns@>(_respawns);
     //   server_CreateBlob( "Entities/Meta/TDMMusic.cfg" );
        players_in_small_team = -1;
    }

    void Update()
    {			
        //HUD
        //dirty hack time...
        // lets save the CPU and do this only once in a while

        if (rules.isGameOver()) { return; }
		
        rules.SetCurrentState(GAME);

		if (rules.isMatchRunning())
        {
            rules.SetGlobalMessage( "" );

			if( getGameTime() % getTicksASecond() == 0)
			{				
				s16 difference = Rule.get_u8("Team_Points"+0) - Rule.get_u8("Team_Points"+1);
				
				if( difference > 0 )
				{
					Rule.set_s32("Team_Score"+1, Rule.get_s32("Team_Score"+1) - difference);
					Rule.Sync("Team_Score"+1,true);
					CheckTeamWon(Rule);
				}
				else if( difference < 0 )
				{
					Rule.set_s32("Team_Score"+0, Rule.get_s32("Team_Score"+0) + difference);
					Rule.Sync("Team_Score"+0,true);
					CheckTeamWon(Rule);
				}				
			}
        }

        RulesCore::Update(); //update respawns

		if( getGameTime() % 1000 == 0)
			SpawnBox();
		if( getGameTime() % 29 == 0)
			updatePointsInfo();
		//if( getGameTime() % 30 == 0)
		//	DayCycle();
    }
	
	void updatePointsInfo ()
	{
		u8 Points_Count = Rule.get_u8("Points_Count");
		
		u8 redPoints = 0, bluePoints = 0;
		
		for(u8 i=0; i<Points_Count; i++)
		{
			CBlob@[] point;
			getBlobsByTag("Point" + i, @point);
			
			if(point[0].getTeamNum() == 0){
				bluePoints++;
			}
			else if(point[0].getTeamNum() == 1){
				redPoints++;
			}
			
			Rule.set_u8("Team_Point"+i, point[0].getTeamNum()); Rule.Sync("Team_Point"+i,true);
		}
		Rule.set_u8("Team_Points"+0, bluePoints);
		Rule.set_u8("Team_Points"+1, redPoints);
	}
	
	void DayCycle()
	{
		CMap@ map = getMap();
		
		float dayTime = map.getDayTime();print("=======/dayTime/========" + dayTime);
		if(dayTime > 0.0)
		{
			if(DayCycleTime++ == 4)
			{
				map.SetDayTime (dayTime + IndexCycleTime);
				DayCycleTime = 0;
				
				if(dayTime + IndexCycleTime > 1){
					IndexCycleTime *= (-1);
				}
					
				return;
			}
		}
		else
		{
			if(NightCycleTime++ == 10)
			{
				map.SetDayTime (dayTime + IndexCycleTime);
				DayCycleTime = 0;

				if(dayTime + IndexCycleTime < 0){
					IndexCycleTime *= (-1);
				}
					
				return;
			}
		}
	}
	
    //team stuff

    void AddTeam(CTeam@ team)
    {
        CPTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
		
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
		CRules@ Rule = getRules();
		if(player.getTeamNum() == 0){		
			Rule.set_s8("SpawnPoint_Player" + player.getNetworkID(), 0);
			//Rule.Sync("SpawnPoint_Player" + player.getNetworkID(),true);
		}
		else{
			Rule.set_s8("SpawnPoint_Player" + player.getNetworkID(), 0);
			//Rule.Sync("SpawnPoint_Player" + player.getNetworkID(),true);
		}
		Rule.set_string("ClassPlayer"+player.getNetworkID(), "knight");
        CPPlayerInfo p(player.getUsername(), player.getTeamNum(), "knight");
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
    }
	
	void onSetPlayer( CBlob@ blob, CPlayer@ player )
	{
		if (blob !is null && player !is null) {
			GiveSpawnResources( blob, player );
		}
	}

    void CreatePoints()
    {
        // destroy all previous points if present
        CBlob@[] oldPoints;
        getBlobsByName( "cp_spawn", @oldPoints );

        for (uint i=0; i < oldPoints.length; i++) {
            oldPoints[i].server_Die();
        }
		
        CMap@ map = getMap();

        if (map !is null)
        {
			CRules@ Rule = getRules();
            Vec2f Blue_pos;
			Vec2f Red_pos;			
			Vec2f[] common_points_position;
			Vec2f[] blue_spawn_positions;
			Vec2f[] red_spawn_positions;
			
			u8 Blue_Points = 0;
			u8 Red_Points = 0;

            // Blue CP points
			map.getMarkers("blue spawn", blue_spawn_positions);

			for(u8 i=0; i<blue_spawn_positions.length; i++)
			{
				blue_spawn_positions[i].y -= 16.0f; blue_spawn_positions[i].x+=4.0f;				
				server_CreateBlob("cp_spawn", 0, blue_spawn_positions[i]);
				Blue_Points++;
			}
			
			// Red CP points
			map.getMarkers("red spawn", red_spawn_positions);

			for(u8 i=0; i<red_spawn_positions.length; i++)
			{
				red_spawn_positions[i].y -= 16.0f; red_spawn_positions[i].x+=4.0f;				
				server_CreateBlob("cp_spawn", 1, red_spawn_positions[i]);
				Red_Points++;
			}
			
			// Common CP points
			map.getMarkers("red main spawn", common_points_position);

			for(u8 i=0; i<common_points_position.length; i++)
			{
				common_points_position[i].y -= 16.0f; common_points_position[i].x+=4.0f;				
				server_CreateBlob("cp_spawn", 7, common_points_position[i]);
			}
			
			CBlob@[] CP_points;
			getBlobsByName("cp_spawn", @CP_points);
			int index = 0;
			
			for(u8 j=0; j<CP_points.length; j++)
			{
				Vec2f min = Vec2f (map.tilemapwidth*100,0);
				for(u8 i=0; i<CP_points.length; i++)
				{
					if((CP_points[i] !is null) && (CP_points[i].getPosition().x < min.x))
					{
						min = CP_points[i].getPosition();
						index = i;
					}
				}
				
				CP_points[index].Tag("Point" + j);
				
				Rule.set_u8("Team_Point"+j, CP_points[index].getTeamNum()); Rule.Sync("Team_Point"+j,true);
				
				@CP_points[index] = null;
			}
			
			Rule.set_u8("Points_Count", CP_points.length); Rule.Sync("Points_Count",true);
			Rule.set_u8("Team_Points"+0, Blue_Points);
			Rule.set_u8("Team_Points"+1, Red_Points);
			startScore = CP_points.length * 25;
			Rule.set_s32("Team_Score"+0, startScore); Rule.Sync("Team_Score"+0,true);
			Rule.set_s32("Team_Score"+1, startScore); Rule.Sync("Team_Score"+1,true);
        }

        rules.SetCurrentState(WARMUP);
    }

    //checks
    void CheckTeamWon( CRules@ Rule )
    {
        if (!rules.isMatchRunning()) { return; }

        s32 BlueTeam_Score = Rule.get_s32("Team_Score"+0);
		s32 RedTeam_Score = Rule.get_s32("Team_Score"+1);
		
		if (RedTeam_Score <= 0)
		{
			Rule.set_s32("Team_Score"+1, 0);
			rules.SetTeamWon( 0 ); //game over!
            rules.SetCurrentState(GAME_OVER);
            rules.SetGlobalMessage( "Blue Team" + " wins the game!" );
		}
		else if (BlueTeam_Score <= 0)
		{
			Rule.set_s32("Team_Score"+0, 0);
			rules.SetTeamWon( 1 ); //game over!
            rules.SetCurrentState(GAME_OVER);
            rules.SetGlobalMessage( "Red Team" + " wins the game!" );
		}
    }

	void SpawnBox()
	{
		Vec2f[] bombPlaces;
		if (getMap().getMarkers("bombs", bombPlaces )) 
		{
			for (uint i = 0; i < bombPlaces.length; i++)
			{
				server_CreateBlob( "mat_bombs", -1, bombPlaces[i] );
				server_CreateBlob( "mat_arrows", -1, bombPlaces[i] );
			}
		}
		/*CBlob@[] oldBox;
		getBlobsByName("crate", @oldBox);
		
		for (uint i = 0; i < oldBox.length; i++){
			oldBox[i].server_Die();
		}
	
		Vec2f[] boxPlaces;
		CBlob@ box;
		if (getMap().getMarkers("bombs", boxPlaces )) 
		{
			for (uint i = 0; i < boxPlaces.length; i++)
			{
				@box = server_CreateBlob( "crate", -1, boxPlaces[i] );
				CBlob@ arrows = server_CreateBlob( "mat_arrows" );
				CBlob@ bombs = server_CreateBlob( "mat_bombs" );
				CBlob@ heart = server_CreateBlob( "heart" );

				if (arrows !is null)
				{
					if (!box.server_PutInInventory(arrows)) {
						arrows.setPosition( box.getPosition() );
					}
				}
				if (bombs !is null)
				{
					if (!box.server_PutInInventory(bombs)) {
						bombs.setPosition( box.getPosition() );
					}
				}
				if (heart !is null)
				{
					if (!box.server_PutInInventory(heart)) {
						heart.setPosition( box.getPosition() );
					}
				}
			}
		}*/
	}


	void GiveSpawnResources( CBlob@ blob, CPlayer@ player )
	{
		int multiplier = 1;

		// give

	   /* if (blob.getName() == "knight") // only give bombs on warmup
		{
			// check if knight has thrown bomb
			//CPPlayerInfo@ tdm_info = getTDMPlayerInfoFromName( this, player.getUsername() );
			//if (tdm_info !is null && tdm_info.thrownBomb) {
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
			CBlob@ mat = server_CreateBlob( "mat_arrows" );

			if (mat !is null)
			{
				if (!blob.server_PutInInventory(mat)) {
					mat.setPosition( blob.getPosition() );
				}									   
			}
		}
	}
};

//pass stuff to the core from each of the hooks

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart( CRules@ this )
{
    printf("Restarting rules script: " + getCurrentScriptName() );
    CPSpawns spawns();
    CPCore core(this, spawns);
    Config(core);
    core.CreatePoints();
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
}