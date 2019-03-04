#define SERVER_ONLY

#include "Disco_functions.as"

const string[] classes = { "knight", "archer" };
int realWarmUpTime = 10;
int warmUpTime = realWarmUpTime + 3;

bool isSingleTeamMode = true;


void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (!isSingleTeamMode) this.SetCurrentState(WARMUP);
	else this.SetCurrentState(GAME);
	warmUpTime = realWarmUpTime + 3;
	setupBases();
    resetPlayerSpawnPoint();
    killPlayers(this);
}

void onTick(CRules@ this)
{
	if (getGameTime() % getTicksASecond() == 0) warmUpTime -= 1;

	if (this.isWarmup()) 
	{
		warmUpMessage(this, warmUpTime); 
	}
	else if (warmUpTime == 0 || isSingleTeamMode)
	{
		this.SetGlobalMessage("");
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(255);

	player.set_string("spawn class", classes[XORRandom(classes.length)]);
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	Respawn(this, player);
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (player is null || isSingleTeamMode) return;

	if (teamSize(newteam) + 1 > teamSize(player.getTeamNum()) || 
			(this.getSpectatorTeamNum() == newteam && teamSize(newteam) > teamSize(getOtherTeamNum(player)))) return; //TODO: notify why you can't swap


	if (player.getBlob() !is null)
	{
		CBlob@ blob = player.getBlob();
		blob.server_SetPlayer(null);
		blob.server_Die();
	}

	player.server_setTeamNum(newteam);

	if (this.getSpectatorTeamNum() == newteam) return;

	Respawn(this, player);
	resetPlayerSpawnPoint();
}