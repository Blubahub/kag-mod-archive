/////////////////////////////////////////
// Zombie Rules Implementation :)

#define SERVER_ONLY

/////////////////////////////////////////
//classes used for config info
class ZombieSpawnSetup
{
	string name;		//name used for spawning
	float value;		//value used to determine wave size
	ZombieSpawnSetup(string n, float v)
	{
		name = n;
		value = v;
	}
};

/////////////////////////////////////////
//global zombies variables
int day;
f32 nextwavetime;
bool wasdaytime;

int gameovertimer;

//the zombies to spawn
//(sorted largest value to smallest
// for the spawning algorithm)
const ZombieSpawnSetup[] zombies =
{
	ZombieSpawnSetup("ZombieKnight", 5.0f),
	
	ZombieSpawnSetup("Greg", 3.0f),
	ZombieSpawnSetup("VeryStrongSkeleton", 3.0),
	ZombieSpawnSetup("VeryStrongZombie", 3.0),	

	ZombieSpawnSetup("StrongSkeleton", 2.0),
	ZombieSpawnSetup("StrongZombie", 2.0),	

	ZombieSpawnSetup("Zombie", 1.0f),
	ZombieSpawnSetup("Skeleton", 1.0f),
};

/////////////////////////////////////////
//configurable functions - change these to

void SpawnPlayer(CPlayer@ p, Vec2f pos)
{
	print("TODO: spawn player: " + p.getUsername() + " at (" + pos.x + "," + pos.y + ")");

	server_CreateBlob("colt1911", 0, pos);
	CBlob@ b = server_CreateBlob("builder", 0, pos);
	b.server_SetPlayer(p);
}

void SpawnZombie(string name, Vec2f pos)
{
	print("TODO: spawn zombie: " + name + " at (" + pos.x + "," + pos.y + ")");
	server_CreateBlob( name, 1, pos);
}

/////////////////////////////////////////
//hooks

//every frame
void onTick(CRules@ this)
{
	//checks run every now and then to avoid gumming up performance too much
	if (getGameTime() % 11 != 0)
	{
		return;
	}

	//get everything we need for a frame

	CMap@ map = getMap();
	f32 current_time = map.getDayTime();
	bool daytime = current_time > 0.2f && current_time < 0.8f;
	bool midnight = current_time > 0.99f || current_time < 0.1f;
	bool dawn = !wasdaytime && daytime;
	CPlayer@[] players = collectPlayers(this);

	// Display a global message of the day.
	this.SetGlobalMessage( "Day "+ day); // TODO: Move this down further. or into player HUD.

	//respawn players
	if (this.isWarmup() || dawn)
	{
		CPlayer@[] dead = filterNeedRespawn(players);
		if (dead.length > 0)
		{
			DoRespawns(dead);
		}
	}

	if (this.isWarmup())
	{
		//if has at least one player, and is night time, set game on!
		if (!daytime && players.length > 0)
		{
			day = 1;
			nextwavetime = 0.0f; //spawn immediately when time to spawn
			this.SetCurrentState(GAME);
		}
	}
	else if (this.isMatchRunning())
	{
		//reset variables at the start of each day
		if (dawn)
		{
			day++;
			nextwavetime = 0.0f;
		}
		//if time to spawn
		else if (midnight)
		{
			//spawn zombies if it's time for a wave
			if (current_time >= nextwavetime)
			{
				SpawnZombieWave(this);
				nextwavetime += 1.0f;		//for now, only one wave
			}
		}

		//if everyone's dead
		//note: automatically triggered if everyone leaves
		//      or join
		if (gameovertimer == -1)
		{
			CPlayer@[] dead = filterNeedRespawn(players);
			if (dead.length == players.length)
			{
				//10 seconds of gameover timer
				//gameovertimer = 30 * 10;
				
				//5 seconds of gameover timer
				//Changed from 30 * 5 to 30 * 2
				gameovertimer = 30 * 2;
				this.SetTeamWon(1); //zombies win
				this.SetCurrentState(GAME_OVER);
			}
		}
	}
	else if (this.isGameOver())
	{
		this.SetGlobalMessage( "No one survived... the Zombies have won. You survived: "+ day + " days."); // End of game message. TODO add an if statement for grammar
		//count down timer
		gameovertimer--;
		//if timer over
		if (gameovertimer == 0)
		{
			LoadNextMap();
		}
	}

	wasdaytime = daytime;
}

//intialisation
//reset anything that needs to be reset
void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	gameovertimer = -1;
	day = 0;
	wasdaytime = false;
	this.SetCurrentState(WARMUP);
	CMap@ map = getMap();
	if (map !is null)
	{
		map.SetDayTime(0.4f);
	}
}

//simple player management
// force into a team on join
// only allow swapping to spectator team, or back to the main team
// kill player's blob on them leaving or swapping team
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(0);
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (newteam != this.getSpectatorTeamNum())
		newteam = 0;

	KillOwnedBlob(player);
	player.server_setTeamNum(newteam);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	KillOwnedBlob(player);
}

/////////////////////////////////////////
//helper functions

Random _edgeRandom();
Vec2f randomEdgePosition()
{
	const s32 edgeVariation = 4; //range that you can spawn in of the edge, in tiles

	CMap@ map = getMap();
	s32 x = 1;
	if (_edgeRandom.NextRanged(2) == 0)
	{
		x = (map.tilemapwidth - 2);
		x -= _edgeRandom.NextRanged(edgeVariation);
	}
	else
	{
		x += _edgeRandom.NextRanged(edgeVariation);
	}
	s32 y = map.getLandYAtX(x) - 2;
	return Vec2f((x + 0.5f) * map.tilesize, (y + 0.5f) * map.tilesize);
}

//collect players actually playing the game
//aka not spectators
CPlayer@[] collectPlayers(CRules@ this)
{
	CPlayer@[] players;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.getTeamNum() != this.getSpectatorTeamNum())
		{
			players.push_back(p);
		}
	}
	return players;
}

//get players that need a respawn (dont have a blob)
CPlayer@[] filterNeedRespawn(CPlayer@[] players)
{
	CPlayer@[] filtered;
	for (uint i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];
		if (p.getBlob() is null)
		{
			filtered.push_back(p);
		}
	}
	return filtered;
}

//do the respawns for a set of players that need it
void DoRespawns(CPlayer@[] players)
{
	for (uint i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];
		Vec2f pos = randomEdgePosition();
		//TODO: respawn the player at pos here
		SpawnPlayer(p, pos);
	}
}

//do the zombie spawn logic
void SpawnZombieWave(CRules@ this)
{
	//new random, seeded by time (different each wave/game)
	Random _zombieRandom(Time());
	//the total value of this wave
	float value = Maths::Sqrt(day * 2.0f) + day * 2.0f;
	print("value: "+value+" day: "+day);

	while (value > 0)
	{
		//start on a random zombie
		u32 i = _zombieRandom.NextRanged(zombies.length - 1);
		while (i < zombies.length - 2)
		{
			//if this zombie is worth too much, iterate forward
			if (zombies[i].value > value)
				i++;
			else
				break;
		}
		SpawnZombie(zombies[i].name, randomEdgePosition());
		value -= zombies[i].value;
	}
}

//kill the blob if they have one (on switching team, or leaving)
void KillOwnedBlob(CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_Die();
	}
}

