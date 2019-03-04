
// Simple rules logic script

#define SERVER_ONLY

#include "RosterCommon.as";

void onInit(CRules@ this)
{
	if (!this.exists("default class"))
	{
		this.set_string("default class", "builder");
	}
	
	this.addCommandID("GameplayEvent");
	Reset();
}

void onRestart( CRules@ this ){
	
	Reset();
}

void onReload( CRules@ this ){
	Reset();
}

void Reset()
{
	server_CreateBlob("ftl_music", 0, Vec2f(0, 0));
	
	server_CreateBlob("roster", 0, Vec2f(0, 0));
	
	server_CreateBlob("pick_race", 0, Vec2f(0, 0));
	
	ResetPlayers();
}

void ResetPlayers(){
	for(int i = 0; i < getPlayerCount(); i += 1){
		CPlayer @player = getPlayer(i);
		if(player !is null){
			player.Untag("dead");
		}
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	CBlob @roster = getRoster();
	
	if(roster is null)return;
	
	if(roster.hasTag(player.getUsername()+"_canspawn")){
		player.Untag(player.getUsername()+"_canspawn");
		Respawn(this, player);
	} else {
		player.Tag("dead");
	}
}

void onTick(CRules @this){

	CBlob @roster = getRoster();
	
	if(roster is null)return;

	for(int i = 0; i < getPlayerCount(); i += 1){
		CPlayer @player = getPlayer(i);
		if(player !is null)
		if(player.getBlob() is null){
			if(roster.hasTag(player.getUsername()+"_canspawn")){
				roster.Untag(player.getUsername()+"_canspawn");
				Respawn(this, player);
			}
		}
	}

}

CBlob@ Respawn(CRules@ this, CPlayer@ player)
{
	if (player !is null)
	{
		// remove previous players blob
		CBlob @blob = player.getBlob();

		if (blob !is null)
		{
			CBlob @blob = player.getBlob();
			blob.server_SetPlayer(null);
			blob.server_Die();
		}

		string race = "human";
		
		CBlob @roster = getRoster();
	
		if(roster !is null){
			race = getPlayerRace(roster, player);
		}
		
		print("Spawning "+player.getUsername()+" as a "+race+".");
		
		CBlob @newBlob = server_CreateBlob(race, 0, getSpawnLocation(player));
		if(newBlob !is null)newBlob.server_SetPlayer(player);
		return newBlob;
	}

	return null;
}

Vec2f getSpawnLocation(CPlayer@ player)
{
	Vec2f[] spawns;

	if (getMap().getMarkers("blue spawn", spawns))
	{
		return spawns[ XORRandom(spawns.length) ];
	}
	else if (getMap().getMarkers("blue main spawn", spawns))
	{
		return spawns[ XORRandom(spawns.length) ];
	}

	return Vec2f(0, 0);
}

