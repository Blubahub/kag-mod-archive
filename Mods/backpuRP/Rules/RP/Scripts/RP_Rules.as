//RP rules

#define SERVER_ONLY

#include "EXP_sys.as";


void onInit(CRules@ this)
{
	onRestart(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)//set player team too 254 (so the user_interface.as can spam menu open)
{
	print("team is now 254");
	player.Tag("New blob");//Set player to new blob (so EXP can be loaded)
	player.server_setTeamNum(254);//Set team num
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if(victim !is null)
	{
		int victimCoins = victim.getCoins() / 2;
		victim.server_setCoins(victimCoins);//Half coins
		victim.Untag("EXP Menu");//Untag EXP and Grave so menu does not stay up when they respawn
		victim.Untag("Grave Nearby");
		CBlob@ blob = server_CreateBlobNoInit("Grave");//Make the new grave blob with text.
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
		victim.set_u32("respawn time",getGameTime() + (15*30)); //set respawn time (15 seconds)
		victim.SyncToPlayer("respawn time",victim);
	}
}


void onTick(CRules@ this)
{
	s32 currentGameTime = getGameTime();

	for(u8 i = 0; i < getPlayerCount(); i++) //for each player in game
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && player.get_u32("respawn time") <= currentGameTime) //if player is dead and its time to respawn
			{
				string teamPos;
				switch(player.getTeamNum()) // set teamNum
				{
					case 0: teamPos = "Team0Spawn"; break;
					case 1: teamPos = "Team1Spawn"; break;
					case 2: teamPos = "Team2Spawn"; break;
					case 3: teamPos = "Team3Spawn"; break;
				}
				if(player.getTeamNum() < 253)//as long as they are not team 254 (not using 255 right now (might do for spectating))
				{
					print("spawning");//spawn player
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
							for(int a = 0; a < 2; a++)
							{
								player.set_bool(newPlayerBlob.getName()+"_Square_"+a,isSquareUnlockedFromFile(player.getUsername(), newPlayerBlob.getName(), a));
								player.SyncToPlayer(newPlayerBlob.getName()+"_Square_"+a, player);

							}
						}
					}
				}				
			}
			else if(player.hasTag("New blob") && blob !is null)//load EXP for the new blob (change class or just switched)
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
		if(getMap().getMarker("HumanMainSpawn", spawn))//Look for markets
		{
			server_CreateBlob("HumanMainSpawn", 0, spawn);//Is human, so make human spawn
			rules.set_Vec2f("Team0Spawn", spawn);//Says where the Team0Spawn is
			rules.set_string("Team0", "Humans");//Tells everybody what Team0 is (Humans in this case)
			rules.Sync("Team0Spawn", false);//Sync to all
			rules.Sync("Team0", false);//Sync to all
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

	this.set_string("Team2","Elves");//Temp until we add in those spawns
	this.set_string("Team1","Dwarfs");
	this.set_u8("0 1", 2);//Status of each team 
	this.set_u8("0 2", 2);//1 = war
	this.set_u8("0 3", 2);//2 = neutral
	this.set_u8("1 2", 2);//3 = friends
	this.set_u8("1 3", 2);
	this.set_u8("2 3", 2);//its set up with numbers so it can be used for all races, could change later for a better name

	if(getNet().isServer())
	{
		this.Sync("0 1",  false);//sync to all
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

	for(u8 i = 0; i < getPlayerCount(); i++) //for each player in game
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			player.server_setTeamNum(254);
		}
	}

	//this.set("core",@core);
	//this.set("start_gametime", getGameTime() + core.warmUpTime);
	//this.set_u32("game_end_time", getGameTime() + core.gameDuration); 
}