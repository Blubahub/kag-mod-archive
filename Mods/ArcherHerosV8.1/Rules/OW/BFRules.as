//BunnyFection Abominable Rules

#define SERVER_ONLY
#include "PlayerInfo.as";
#include "MakeMat.as";



const f32 CORRUPTION_RADIUS = 50.0f;
const u16 OUTBREAK_TIME = 50 * 60;
const u16 ENDMATCH_TIME = 5 * 60 * 30;

void onInit( CRules@ this )
{
	this.set_bool( "no timer", false );
	this.set_u32( "game_end_time", 0 );
	this.set_u32( "extraTime", 0 );
	this.set_string( "lastOBPlayer", "" );

	this.set_bool( "outbreak", false );
	this.set_s16( "hatcheryID", -1 );
	onRestart(this);
}

void onRestart( CRules@ this )
{
	print( "restarting Match" );
	this.SetCurrentState(GAME);
	u32 gameTime = getGameTime();
	this.set_bool( "outbreak", false );
	this.set_s16( "hatcheryID", -1 );
	this.set_u8("dead",0);
  this.set_u32( "game_end_time", ENDMATCH_TIME );
	this.Sync( "game_end_time", true );
	this.set_u32( "extraTime", 0 );

	this.SetGlobalMessage( "" );
		
	respawnEveryone();
}

void onTick( CRules@ this )
{
	f32 gameTime = getGameTime();
	//if ( gameTime % 300 == 0 && gameTime > this.get_u32( "game_end_time" ) )
		MatchDirector( this );
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData )
{
	print( "Someone Died" );
  
  Respawn( victim );
}

CBlob@ Respawn( CPlayer@ player )
{
    if ( player !is null )
    {
		CBlob @blob = player.getBlob();
		if (blob !is null)
			RemovePlayerBlob( player );
		
		CBlob @newBlob = server_CreateBlob( "builder", 0, getSpawnLocation( player ) );
			       
		newBlob.server_SetPlayer( player );
		
		
			//giveResources( player );

		return newBlob;
    }
    return null;
}

Vec2f getSpawnLocation( CPlayer@ player )
{
  string typespawn = player.getTeamNum() == 0 ? "blue spawn" : "red spawn";
	CMap@ map = getMap();
	Vec2f[]  mSpawn;
	if (map.getMarkers( typespawn, mSpawn ) )
	{
		return mSpawn[XORRandom(mSpawn.Length)];
	}
	return Vec2f(0,0);
}

void onPlayerRequestSpawn( CRules@ this, CPlayer@ player )
{
   Respawn( player );
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )//avoiding respawn issues
{
	u8 prevTeam = player.getTeamNum();
	player.set_u8("lvl", 0);
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



