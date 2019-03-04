#define SERVER_ONLY

int queue, endmap = -1;

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    this.set_bool("nextmap", false);
	this.set_bool("respawn", true);
	this.SetGlobalMessage("");

	if(queue >= getPlayersCount()-1)
		queue = 0;
	else
		queue++;

	endmap = -1;
    killPlayers(this);
}

void onTick(CRules@ this)
{
    if(this.get_bool("nextmap") and endmap == -1)
        endmap = Time_Local() + 3;
	if(endmap != -1 and endmap <= Time_Local() and this.get_bool("nextmap"))
		LoadNextMap();
}

void onBlobDie( CRules@ this, CBlob@ blob )
{
    if(blob is null)
        return;

    if(blob.getPlayer() is null)
        return;

    blob.server_Die();

    if(blob.getPlayer().getTeamNum() == 1)
	{
		this.SetGlobalMessage("Runners won!");
        this.set_bool("nextmap", true);
	}
    else
    {
        this.set_bool("respawn", false);
		blob.getPlayer().set_bool("dead", true);
        bool next = true;
        for(int i = 0; i < getPlayersCount(); i++)
            if(!getPlayer(i).get_bool("dead") and getPlayer(i).getTeamNum() == 0)
            {
                next = false;
                break;
            }
        if(next)
		{
			this.SetGlobalMessage("Traper won!");
            this.set_bool("nextmap", true);
		}
    }
    return;
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	onBlobDie(this, player.getBlob());
}

void killPlayers(CRules@ this)
{
    int players = getPlayersCount();
    for(int i = 0; i < players; i++)
    {
        CPlayer@ player = getPlayer(i);
        if(player !is null)
        {
            player.server_setTeamNum(0);
            if(player.getBlob() !is null)
            {
                player.getBlob().server_Die();
            }
			onPlayerRequestSpawn(this, player);
        }
    }
}

Vec2f getSpawnLocation(int team)
{
	CMap@ map = getMap();
	Vec2f respawnPos;
	if (map.getMarker(team == 0 ? "blue main spawn" : "red main spawn", respawnPos))
		return respawnPos;

	return Vec2f(0, 0);
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	if (player is null)
		return;

    if(!this.get_bool("respawn"))
        return;

	CBlob @blob = player.getBlob();
	if (blob !is null)
	{
		CBlob @blob = player.getBlob();
		blob.server_SetPlayer(null);
		blob.server_Die();
	}

	int team = 0;
	if(getPlayer(queue) !is null and getPlayer(queue).getUsername() == player.getUsername() and
    	getMap().get_bool("traper"))
		team = 1;

	player.set_bool("dead", false);

	CBlob @newBlob = server_CreateBlob("archer", team, getSpawnLocation(team));
	newBlob.server_SetPlayer(player);
	player.server_setTeamNum(team);
}
