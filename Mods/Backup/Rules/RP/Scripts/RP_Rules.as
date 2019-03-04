//RP rules

#define SERVER_ONLY

#include "EXP_sys.as";


void onInit(CRules@ this)
{
	onRestart(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	print("team is now 254");
	player.Tag("New blob");
	player.server_setTeamNum(254);
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if(victim !is null)
	{
		int victimCoins = victim.getCoins() / 2;
		victim.server_setCoins(victimCoins);
		victim.Untag("EXP Menu");
		victim.Untag("Grave Nearby");
		CBlob@ blob = server_CreateBlobNoInit("Grave");
		if (blob !is null)
		{
			blob.setPosition(victim.getBlob().getPosition());
			if (!blob.exists("text"))
			{
				blob.set_string("text", victim.getUsername() + " had died here. May they now rest in piece."); // Should be ok even if the server and the client run it?
				blob.Sync("text",false);
				blob.set_u16("coins",victimCoins);
				blob.Sync("coins",false);
			}
		}
		victim.set_u32("respawn time",getGameTime() + (15*30));
		victim.SyncToPlayer("respawn time",victim);
	}
}


void onTick(CRules@ this)
{
	s32 currentGameTime = getGameTime();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && player.get_u32("respawn time") <= currentGameTime)
			{
				string teamPos;
				switch(player.getTeamNum())
				{
					case 0: teamPos = "Team0Spawn"; break;
					case 1: teamPos = "Team1Spawn"; break;
					case 2: teamPos = "Team2Spawn"; break;
					case 3: teamPos = "Team3Spawn"; break;
				}
				if(player.getTeamNum() < 253)
				{
					print("spawning");
					CBlob@ newPlayerBlob = server_CreateBlob("builder");//TODO spawn last blob the player was
					
					if (newPlayerBlob !is null)
					{
						newPlayerBlob.setPosition(this.get_Vec2f(teamPos));
						newPlayerBlob.server_setTeamNum(player.getTeamNum());
						newPlayerBlob.server_SetPlayer(player);
						if(player.hasTag("New blob"))
						{
							player.Untag("New blob");
							loadAll(player.getUsername(), newPlayerBlob.getName());//Loads both EXP and Level for that class
						}
					}
				}				
			}
			else if(player.hasTag("New blob") && blob !is null)
			{
				player.Untag("New blob");
				loadAll(player.getUsername(), blob.getName());
			}
		}

	}
}


void SpawnTheSpawns()
{
	CMap@ map = getMap();
	CRules@ rules = getRules();

	if (map !is null && map.tilemapwidth != 0)
	{
		Vec2f spawn;
		if(getMap().getMarker("HumanMainSpawn", spawn))
		{
			server_CreateBlob("HumanMainSpawn", 0, spawn);
			rules.set_Vec2f("Team0Spawn", spawn);
			rules.set_string("Team0", "Humans");
			rules.Sync("Team0Spawn", false);
			rules.Sync("Team0", false);
		}
		if(getMap().getMarker("OrcMainSpawn", spawn))
		{
			server_CreateBlob("OrcMainSpawn", 3, spawn);
			rules.set_Vec2f("Team3Spawn", spawn);
			rules.set_string("Team3", "Orcs");
			rules.Sync("Team3Spawn", false);
			rules.Sync("Team3", false);
		}

	}
}


void resetPlayerTeam()
{
	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			player.server_setTeamNum(254);
		}
	}

}

void onRestart( CRules@ this )
{

	this.set_string("Team2","Elves");
	this.set_string("Team1","Dwarfs");
	this.set_u8("0 1", 2);
	this.set_u8("0 2", 2);
	this.set_u8("0 3", 2);
	this.set_u8("1 2", 2);
	this.set_u8("1 3", 2);
	this.set_u8("2 3", 2);

	if(getNet().isServer())
	{
		this.Sync("0 1",  false);
		this.Sync("0 2",  false);
		this.Sync("0 3",  false);
		this.Sync("1 2",  false);
		this.Sync("1 3",  false);
		this.Sync("2 3",  false);
		this.Sync("Team2", false);
		this.Sync("Team1", false);
	}

	/*RPSpawns spawns();
	RPCore core(this,spawns);
	core.SpawnTheSpawns();*/
	SpawnTheSpawns();
	resetPlayerTeam();

	this.SetCurrentState(GAME);
	this.SetGlobalMessage("");

	//this.set("core",@core);
	//this.set("start_gametime", getGameTime() + core.warmUpTime);
	//this.set_u32("game_end_time", getGameTime() + core.gameDuration); 
}