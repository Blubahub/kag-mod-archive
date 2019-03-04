
// Simple rules logic script

#define SERVER_ONLY

#include "RulesCore.as";
#include "RespawnSystem.as";

void onInit(CRules@ this)
{
	if (!this.exists("default class"))
	{
		this.set_string("default class", "archer");
	}
	
	
	
	Reset(this);
}

void onTick(CRules@ this){
	for(uint i = 0; i < getPlayerCount(); i += 1){
		CPlayer@ p = getPlayer(i);
		if(p !is null){
			if(p.getBlob() !is null){
				if(p.getBlob().hasTag("dead") || p.getBlob().getHealth() <= 0){
					DoSpawnPlayer(p);
				}
			} else {
				DoSpawnPlayer(p);
			}
		}
	}
	
	
	int archers = 0;
	string name = "";
	CBlob@[] archer;
	getBlobsByName("archer", @archer);
	for(uint i = 0; i < archer.length(); i += 1){
		if(!archer[i].hasTag("dead")){
			archers += 1;
			if(archer[i].getPlayer() !is null){
				name = archer[i].getPlayer().getUsername();
			}
		}
	}

	if(archers > 2)this.Tag("GameStarted");
	if(this.hasTag("GameStarted")){
		if(archers == 1){
			this.set_s16("postgametimer",this.get_s16("postgametimer")+1);
			this.SetGlobalMessage(name + " wins the game!");
		}
		
		if(this.get_s16("postgametimer") > 0){
			this.set_s16("postgametimer",this.get_s16("postgametimer")+1);
		}
		
		if(this.get_s16("postgametimer") > 300){
			Reset(this);
			LoadNextMap();
		}
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	if (player !is null)
	{
		bool canSpawn = true;
		CBlob@[] archer;
		getBlobsByName("archer", @archer);
		for(uint i = 0; i < archer.length(); i += 1){
			if(!archer[i].hasTag("dead")){
				if(archer[i].hasTag(player.getUsername()))canSpawn = false;
			}
		}
		if(canSpawn)Respawn(this, player);
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

		CBlob @newBlob = server_CreateBlob(this.get_string("default class"), getSafeTeam(), getSpawnLocation(player));
		newBlob.server_SetPlayer(player);
		return newBlob;
	}

	return null;
}

Vec2f getSpawnLocation(CPlayer@ player)
{
	CBlob@[] ruins;
	getBlobsByName("ruins", @ruins);
	
	if(ruins.length > 0)return ruins[XORRandom(ruins.length)].getPosition();

	CMap@ map = getMap();
	if (map !is null)
	{
		f32 x = XORRandom(2) == 0 ? 32.0f : map.tilemapwidth * map.tilesize - 32.0f;
		return Vec2f(x, map.getLandYAtX(s32(x / map.tilesize)) * map.tilesize - 16.0f);
	}
	
	return Vec2f(0, 0);
}


shared class TagCore : RulesCore
{

	TagCore() {}

	TagCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}

	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		server_CreateBlob("Entities/Meta/WARMusic.cfg");
	}

	void Update()
	{

		if (rules.isGameOver()) { return; }

		RulesCore::Update(); //update respawns

	}

};

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());
	RespawnSystem spawns();
	TagCore core(this, spawns);
	this.set_s16("postgametimer",0);
	this.Untag("GameStarted");
	this.SetGlobalMessage("");
}

void DoSpawnPlayer(CPlayer@ player)
{
	if (player !is null)
	if (canSpawnPlayer(player))
	{
		if (player.getBlob() !is null)
		{
			CBlob @blob = player.getBlob();
			blob.server_SetPlayer(null);
			blob.server_Die();
		}

		CBlob @newBlob = server_CreateBlob("archer", getSafeTeam(), getSpawnLocation(player));
		newBlob.server_SetPlayer(player);
		player.server_setTeamNum(XORRandom(200)+1);
	}
}

bool canSpawnPlayer(CPlayer@ player)
{
	if (player !is null)
	{
		bool canSpawn = true;
		CBlob@[] archer;
		getBlobsByName("archer", @archer);
		for(uint i = 0; i < archer.length(); i += 1){
			if(!archer[i].hasTag("dead")){
				if(archer[i].hasTag(player.getUsername()))canSpawn = false;
			}
		}
		return canSpawn;
	}
	return false;
}

int getSafeTeam()
{
	int team = XORRandom(50)+50;
	for(uint j = 0; j < 100; j += 1){
		bool canLeave = true;
		CBlob@[] archer;
		getBlobsByName("archer", @archer);
		for(uint i = 0; i < archer.length(); i += 1){
			if(!archer[i].hasTag("dead")){
				if(archer[i].getTeamNum() == team)canLeave = false;
			}
		}
		if(canLeave)break;
		team = XORRandom(50)+50;
	}
	return team;
}