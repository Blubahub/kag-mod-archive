//BunnyFection Abominable Rules

#define SERVER_ONLY
#include "PlayerInfo.as";
#include "MakeMat.as";
#include "BF_VectorWorks.as"

BPlayerInfo@[] players;
const f32 CORRUPTION_RADIUS = 50.0f;
const u16 OUTBREAK_TIME = 50 * 30;
const u16 ENDMATCH_TIME = 9 * 60 * 30;

void onInit( CRules@ this )
{
	this.set_bool( "no timer", true );
	this.set_u32( "game_end_time", 0 );
	this.set_u32( "extraTime", 0 );
	this.set_string( "lastOBPlayer", "" );

	this.set_bool( "outbreak", false );
	this.set_s16( "hatcheryID", -1 );
}

void onRestart( CRules@ this )
{
	print( "restarting Match" );
	this.SetCurrentState(GAME);
	this.set_bool( "outbreak", false );
	this.set_s16( "hatcheryID", -1 );
	this.set_u32( "game_end_time", 0 );
	this.Sync( "game_end_time", true );
	this.set_u32( "extraTime", 0 );

	SetupPlayers();

	this.SetGlobalMessage( "" );
		
	respawnEveryone();
}

void onTick( CRules@ this )
{
	f32 gameTime = getGameTime();
	if ( gameTime % 300 == 0 || ( this.get_bool( "outbreak" ) && gameTime > this.get_u32( "game_end_time" ) ) )
		MatchDirector( this );
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData )
{
    if ( victim !is null )
    {
		BPlayerInfo@ pInfo = getInfoFromName( victim.getUsername() );
		CBlob@ blob = victim.getBlob();
		pInfo.deathSpot = blob.getPosition();
		//print( "teamNum: " + pInfo.team + ", cDAta: " + customData );
		//Mutant kills Bunny
		if ( pInfo.team == 0  && customData == 40 )//40 is the mutant hittertype
			Mutate( victim );
		else	if ( killer !is null && pInfo.team == 0 && killer.getTeamNum() == 1  )//just in case
			Mutate( victim );
    }
}

CBlob@ Respawn( CPlayer@ player )
{
    if ( player !is null )
    {
		BPlayerInfo@ pInfo = getInfoFromName( player.getUsername() );
		pInfo.spawnsCount = pInfo.spawnsCount + 1;

		CBlob @blob = player.getBlob();
		if (blob !is null)
			RemovePlayerBlob( player );
		
		CBlob @newBlob = server_CreateBlob( pInfo.blob_name, pInfo.team, getSpawnLocation( player ) );
			       
		newBlob.server_SetPlayer( player );
		
		if ( pInfo.team == 1 )
			newBlob.Tag( "mutant" );
		else if ( pInfo.spawnsCount == 1 )
			giveResources( player );

		return newBlob;
    }
    return null;
}

Vec2f getSpawnLocation( CPlayer@ player )
{
	BPlayerInfo@ pInfo = getInfoFromName( player.getUsername() );

	if ( pInfo.justMutated )
	{
		pInfo.justMutated = false;
		return pInfo.deathSpot;
	}

	CMap@ map = getMap();
	u8 team = pInfo.team;
	Vec2f mSpawn;
	if ( team == 1 && map.getMarker( "red spawn", mSpawn ) )
	{
		return mSpawn;
	}
	else
	{
		Vec2f[] spawns;

		if (map.getMarkers("blue spawn", spawns )) {
			return spawns[ XORRandom( spawns.length ) ];
		}
		else if (map.getMarkers("blue main spawn", spawns )) {
			return spawns[ XORRandom( spawns.length ) ];
		}			
	}
	return Vec2f(0,0);
}

void onPlayerRequestSpawn( CRules@ this, CPlayer@ player )
{
	BPlayerInfo@ p = getInfoFromName( player.getUsername() );  
	if ( p is null )
	{
		if ( this.get_bool( "outbreak" ) && getGameTime() > this.get_u32( "game_end_time" )/2 )
			AddPlayer(player, 1, "bf_mutant1");
		else
			AddPlayer(player, 0, "bf_bunny");
	}
	else if ( this.get_bool( "outbreak" ) && p.team == 0 )//no mercy for rejoiners!
		Mutate( player, false );
		
    Respawn( player );
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )//avoiding respawn issues
{
	u8 prevTeam = player.getTeamNum();
	
	BPlayerInfo@ pInfo = getInfoFromName( player.getUsername() );  
	if ( pInfo !is null )
		player.server_setTeamNum( pInfo.team );
	else
		player.server_setTeamNum(0);
		
	if ( prevTeam == this.getSpectatorTeamNum() )
		player.client_RequestSpawn();
		
	this.SyncToPlayer( "game_end_time", player );//just in case
}

void respawnEveryone()
{
	u8 playerCount = getPlayersCount();
	for( u8 pNum = 0; pNum < playerCount; pNum++ )
	{
		CPlayer@ player = getPlayer( pNum );
		if ( player is null )
			continue;
		Respawn( player );
	}
}

void giveResources( CPlayer@ this )
{
	CBlob@ blob = this.getBlob();
	MakeMat( blob, blob.getPosition(), "mat_wood", 150 );
	MakeMat( blob, blob.getPosition(), "mat_stone", 100 );
}

void MatchDirector( CRules@ this )
{
	u32 gameTime = getGameTime();
	
	if ( this.isGameOver() )
	{
		LoadNextMap();
		return;
	}

	u8 pCount = getPlayersCount();
	if ( pCount < 2 )
	{
		this.set_u32( "extraTime", gameTime );
		return;
	}
	
	bool OUTBREAK = this.get_bool( "outbreak" );
	u8 bunnyCount = 0;
	u8 mutantCount = 0;
	for( u8 pNum = 0; pNum < pCount; pNum++ )
	{
		CPlayer@ player = getPlayer( pNum );
		if ( player is null )
			continue;
		BPlayerInfo@ pInfo = getInfoFromPlayer( player );
		if ( pInfo is null )
			continue;
		if ( pInfo.team == 0 )
			bunnyCount++;
		else
			mutantCount++;
	}
	
	if ( bunnyCount == 0 )
	{
		print( "Mutants WIN!" );
		this.SetGlobalMessage( "The Corrupted win the game!" );
		this.SetCurrentState(GAME_OVER);
	}
	else if ( OUTBREAK && ( this.get_s16( "hatcheryID" ) == -1 || gameTime > this.get_u32( "game_end_time" ) ) )
	{
		print( "Bunnies WIN!" );
		this.SetGlobalMessage( "Bunnies win the game!" );
		this.SetCurrentState(GAME_OVER);
	}
	else if ( OUTBREAK && mutantCount == 0 )// && some time passed )//<- Todo
	{
		CPlayer@ player = getPlayer( XORRandom( pCount ) );
		Mutate( player, false );
		Respawn( player );
	}
	
	if ( !OUTBREAK && gameTime > OUTBREAK_TIME + this.get_u32( "extraTime" ) )
	{
		Outbreak( this );
		this.set_u32( "game_end_time", ENDMATCH_TIME + gameTime );
		this.Sync( "game_end_time", true );
	}
}

void onBlobDie( CRules@ this, CBlob@ blob )
{
	if ( blob.getName() == "bf_hatchery" )
	{
		this.set_s16( "hatcheryID", -1 );
		this.Sync( "hatcheryID", true );
	}
}
///// Mutate functions

void Mutate( CPlayer@ this, bool onSpot = true )
{
	BPlayerInfo@ pInfo = getInfoFromName( this.getUsername() );
	print( ":::MUTATING: " + pInfo.username );
	//empty the inv. if any
	CBlob@ blob = this.getBlob();
	if ( blob !is null )
	{
		CInventory@ inv = blob.getInventory();
		if (inv !is null)
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob @item = inv.getItem(i);	
				item.server_Die();
			}
	}
	ChangePlayerTeam( this, 1 );
	pInfo.blob_name = "bf_mutant1";
	pInfo.justMutated = onSpot;
}

bool Outbreak( CRules@ this, f32 radius = CORRUPTION_RADIUS )
{
	u8 pCount = getPlayersCount();
	if ( pCount > 0 )//otherwise getPlayer() crashes server
		for ( u8 try = 0; try < 5; try++ )
		{
			u8 randomPlayer = XORRandom( pCount );
			CPlayer@ player = getPlayer( randomPlayer );
			if ( player is null )
				continue;
			if ( player.getUsername() == this.get_string( "lastOBPlayer" ) && pCount > 1 )
				continue;
			CBlob@ blob = player.getBlob();
			if ( blob is null )
				continue;
			if ( SpawnCorruption( this, blob.getPosition(), radius ) )
			{
				this.set_bool( "outbreak", true );
				this.set_string( "lastOBPlayer", player.getUsername() );
				return true;
			}
		}
	return false;
}

bool SpawnCorruption( CRules@ this, Vec2f spot, f32 radius )
{
	CMap@ map = getMap();
	CBlob@[] corrupted;
	map.getBlobsInRadius( spot, radius, @corrupted );

	CBlob@ hatchery = server_CreateBlobNoInit( "bf_hatchery" );
	this.set_s16( "hatcheryID", hatchery.getNetworkID() );
	this.Sync( "hatcheryID", true );
	hatchery.server_setTeamNum(1);
	hatchery.Tag( "mutant" );

	//find the ground
	Vec2f hSpot = map.getTileWorldPosition( spot/8 );
	do
	{
		if ( !map.isTileSolid( hSpot + Vec2f( 0, 8 ) ) )
			hSpot.y += 8.0f;
		else
			break;
	} while ( hSpot.y - spot.y < 65 );
	
	map.AddMarker( hSpot + Vec2f( 0, -6 ), "red spawn" );

						//Clear Area
	//kill flora spawn Points
	removeMarkersInRadius( "bf_spawncarrot", hSpot, 64.0f );
	removeMarkersInRadius( "bf_spawnshrub", hSpot, 64.0f );

	//kill blobs
	for ( int c = 0; c < corrupted.length; c++ )
		if ( corrupted[c].getName() != "tree_pine" && corrupted[c].getName() != "tree_bushy" )
		{
			MakeMat( corrupted[c], corrupted[c].getPosition(), "bf_materialbiomass", 7 );
			hatchery.server_Hit( corrupted[c], corrupted[c].getPosition(), Vec2f_zero, 30.0f, 40 );
		}

	//remove dirt
	for ( f32 y = hSpot.y; y >= hSpot.y - 16; y -= 8 )
		for ( f32 x = hSpot.x - 16; x <= hSpot.x + 16; x += 8 )
			map.server_DestroyTile( Vec2f( x, y ), 100.0f, hatchery );
	
	//add dirt base
	for ( f32 x = hSpot.x - 16; x <= hSpot.x + 16; x += 8 )
		if ( !map.isTileBackground( map.getTile( Vec2f( x, hSpot.y + 16 ) ) ) )
			map.server_SetTile( Vec2f( x, hSpot.y + 8 ), CMap::tile_ground  );

	hatchery.setPosition( hSpot + Vec2f( 0, -6 ) );
	hatchery.Init();

	//no build zone
	map.server_AddSector( Vec2f( hSpot.x - 16, hSpot.y - 16 ), Vec2f( hSpot.x + 16, hSpot.y ), "no build" );

	return true;
}


/////////BPlayerInfo
shared class BPlayerInfo : PlayerInfo
{
	Vec2f deathSpot;
	bool justMutated;
	u8 mutLVL;
	
    BPlayerInfo() { Setup( "", 0, "" ); }
    BPlayerInfo(string _name, u8 _team, string _default_config ) { Setup( _name, _team, _default_config ); }

    void Setup( string _name, u8 _team, string _default_config )
    {
        PlayerInfo::Setup(_name,_team,_default_config);
		deathSpot = Vec2f_zero;
		justMutated = false;
		mutLVL = 0;
    }
};
/////////Crippled RulesCore below
void SetupPlayers()
{
	players.clear();

	for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
	{
		AddPlayer(getPlayer(player_step), 0, "bf_bunny");
	}
}

BPlayerInfo@ getInfoFromName( string username )
{
	for (uint k = 0; k < players.length; k++)
	{
		if (players[k].username == username) {
			return players[k];
		}
	}
	return null;
}

BPlayerInfo@ getInfoFromPlayer( CPlayer@ player )
{
	if (player !is null) {
		return getInfoFromName( player.getUsername() );
	}
	else {
		return null;
	}
}

void AddPlayer( CPlayer@ player, u8 team = 0, string default_config = "bf_bunny" )
{
	BPlayerInfo@ check = getInfoFromName( player.getUsername() );

	if (check is null)
	{
		BPlayerInfo p(player.getUsername(), team, default_config);
		players.push_back(@p);
		player.server_setTeamNum(team);
	}
}

void ChangePlayerTeam(CPlayer@ player, int newTeamNum)
{
	BPlayerInfo@ p = getInfoFromName( player.getUsername() );
	
	if (p.team == newTeamNum)
		return;
	
	RemovePlayerBlob( player );

	u8 oldteam = player.getTeamNum();
	p.setTeam(newTeamNum);	  
	player.server_setTeamNum(newTeamNum);	
}	

void RemovePlayerBlob( CPlayer@ player )
{
	if (player is null)
		return;

	// remove previous players blob	  			
	CBlob @blob = player.getBlob();
	if (blob !is null )
	{							   
		blob.server_SetPlayer( null );
		
		//if (blob.getHealth() > 0.0f)
			blob.server_Die();
	}	 
}

void KillPlayerBlob( CPlayer@ player )
{
	if (player is null)
		return;

	CBlob@ blob = player.getBlob();
	if (blob !is null )
	{
		getRules().server_PlayerDie( player );
		blob.server_SetPlayer( null );
	}	 
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null || !player.isMod())
		return true;

    if (text_in == "!b")
    {
		PosInfo[] testList = getTilePosInRadius( player.getBlob().getPosition(), 40 );
		for ( int i = 0; i < testList.length(); i++ )
			getMap().server_DestroyTile( testList[i].pos, 10.5f );
    }
    else if (text_in == "!ob")
    {
        Outbreak( this );
		this.set_u32( "game_end_time", ENDMATCH_TIME + getGameTime() );
		this.Sync( "game_end_time", true );
    }
	 else if (text_in == "!goo")
    {
		print("gooing");
		if ( player.getBlob().hasTag( "gooable" ) )
			player.getBlob().set_u8( "stickiedTime", this.get_u8( "stickiedTime" ) + 50 );
    }

	return true;
}
