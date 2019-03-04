//Grob rules
//Made by Vamist (or Vam_jam)
//Started on 22/09/2019

//What each tag does
//
//
//
//
//
//
//


#define SERVER_ONLY


void onInit(CRules@ this)
{
	onRestart(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{

}


void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	
}



void onTick(CRules@ this)
{
	for(int a = 0; a < getPlayerCount(); a++)
	{

	}
}

void victoryStuff(CRules@ this, int8 teamnum)
{
}

void spawnAtSpawn(CRules@ this)
{
	
}


void setSpawnPos()
{
	CMap@ map = getMap();
	CRules@ rules = getRules();

	if (map !is null && map.tilemapwidth != 0)
	{
		Vec2f spawn;
		Vec2f respawnPos;
		if(getMap().getMarker("blue main spawn", spawn))
		{
			respawnPos = spawn;
			respawnPos.y -= 16.0f;
			server_CreateBlob("tdm_spawn", 0, respawnPos);
			rules.set_Vec2f("0Spawn", spawn);
			rules.Sync("0Spawn",true);
		}

		if(getMap().getMarker("red main spawn", spawn))
		{
			respawnPos = spawn;
			respawnPos.y -= 16.0f;
			server_CreateBlob("tdm_spawn", 1, respawnPos);
			rules.set_Vec2f("1Spawn", spawn);
			rules.Sync("1Spawn",true);
		}

	}
}


void resetStuff(CRules@ this)
{
	
}

void onRestart(CRules@ this )
{

	this.SetCurrentState(GAME);
	this.SetGlobalMessage("");	
}