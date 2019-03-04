
// Simple rules logic script

#define SERVER_ONLY

void onInit(CRules@ this)
{
	if (!this.exists("default class"))
	{
		this.set_string("default class", "builder");
	}
	
	this.addCommandID("GameplayEvent");
}

void onRestart( CRules@ this ){
	ResetPlayers();
}

void onReload( CRules@ this ){
	ResetPlayers();
	server_CreateBlob("music",0,Vec2f(0,0));
}

void ResetPlayers(){
	for(int i = 0; i < getPlayerCount(); i += 1){
		CPlayer @player = getPlayer(i);
		if(player !is null){
			player.Untag("joined");
			player.Untag("dead");
		}
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	if(player.hasTag("joined")){
		player.Tag("dead");
	} else {
		player.Tag("joined");
		Respawn(this, player);
	}
}

void onTick(CRules @this){

	for(int i = 0; i < getPlayerCount(); i += 1){
		CPlayer @player = getPlayer(i);
		if(player !is null)
		if(player.getBlob() is null){
			if(!player.hasTag("joined")){
				player.Tag("joined");
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

		CBlob @newBlob = server_CreateBlob(this.get_string("default class"), 0, getSpawnLocation(player));
		newBlob.server_SetPlayer(player);
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
