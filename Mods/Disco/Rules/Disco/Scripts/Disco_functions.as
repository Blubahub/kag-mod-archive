//SETUP

void setupBases()
{
    Vec2f[] spawns;

    if (getMap().getMarkers("band", spawns) && spawns.length > 0)
    {
        for (int i = 0; i < 3; i++)
        {
            CBlob @newBlob = server_CreateBlobNoInit("band_member");
            if (newBlob !is null)
            {
                newBlob.server_setTeamNum(-1);
                newBlob.setPosition(spawns[0] + Vec2f(i * 16, 0));
                newBlob.set_u8("class", 1 + i);
                newBlob.Init();
            }
        }
    }
    
    spawns.clear();

    if (getMap().getMarkers("blue main spawn", spawns))
    {
        server_CreateBlob("newtent", 0, (spawns[0] + Vec2f(0,-8.0f)));
    }

    spawns.clear();

    if (getMap().getMarkers("red main spawn", spawns) && !isSingleTeamMode)
    {
        server_CreateBlob("newtent", 1, (spawns[0] + Vec2f(0,-8.0f)));
    }

    killPlayers(getRules());
    respawnPlayers(getRules());
}

void warmUpMessage(CRules@ this, int warmUpTime)
{  
    if (warmUpTime > 3) 
    {
        this.SetGlobalMessage("Match starts in " + (warmUpTime - 3));
    }
    else if (warmUpTime > 0) {
        this.SetGlobalMessage("Game start!");
        this.SetCurrentState(GAME);
    }
}

//SPAWNING

void killPlayers(CRules@ this)
{
    int players = getPlayersCount();
    for(int i = 0; i < players; i++)
    {
        CPlayer@ player = getPlayer(i);
        if(player !is null && player.getBlob() !is null)
        {
            CBlob@ blob = player.getBlob();
            blob.server_Die();
        }

    }

}

void respawnPlayers(CRules@ this)
{
    int players = getPlayersCount();
    for(int i = 0; i < players; i++)
    {
        CPlayer@ player = getPlayer(i);
        if(player !is null)
        {
            player.server_setTeamNum(255);
            Respawn(this, player);
        }

    }
}

void resetPlayerSpawnPoint()
{
    int players = getPlayersCount();
    for(int i = 0; i < players; i++)
    {
        CPlayer@ player = getPlayer(i);
        player.set_u16("spawn point network id", 0);
    }
}

Vec2f getSpawnLocation(CPlayer@ player)
{
    u16 spawn;
    u16 blobid = player.get_u16("spawn point network id");
    int team = player.getTeamNum();
    bool hasSpawnPoint = blobid != 0;
    Vec2f[] tents;

    getMap().getMarkers("blue main spawn", tents);

    if (team == 0)
    {
        if (hasSpawnPoint == false || getBlobByNetworkID(blobid) is null || getBlobByNetworkID(blobid).getTeamNum() != team)
        {
            if (tents.length() > 0) return tents[0];
        }
        else if (getBlobByNetworkID(blobid).getTeamNum() == team)
        {
            return getBlobByNetworkID(blobid).getPosition();
        }
    }

    tents.clear();

    getMap().getMarkers("red main spawn", tents);

    if (team == 1)
    {
        if (hasSpawnPoint == false || getBlobByNetworkID(blobid) is null || getBlobByNetworkID(blobid).getTeamNum() != team)
        {
            if (tents.length() > 0) return tents[0];
        }
        else if (getBlobByNetworkID(blobid).getTeamNum() == team)
        {
            return getBlobByNetworkID(blobid).getPosition();
        }
    }


    warn("getSpawnLocation spawning at 0,0: spawn not found");
    return Vec2f(0, 0);
}

CBlob@ Respawn(CRules@ this, CPlayer@ player)
{
    if (player !is null)
    {
        CBlob @blob = player.getBlob();

        if (blob !is null)
        {
            CBlob@ blob = player.getBlob();
            blob.server_SetPlayer(null);
            blob.server_Die();
        }

        if (player.lastBlobName.length() > 0)
        {
            player.set_string("spawn class", player.lastBlobName);
        }

        if (player.getTeamNum() == 255)
        {
            if (isSingleTeamMode)
            {
                player.server_setTeamNum(0);
            }
            else if (teamSize(0) > teamSize(1)) //blue has more people than red
            {
                player.server_setTeamNum(1);
            }
            else if (teamSize(1) > teamSize(0)) //red has more people than blue
            {
                player.server_setTeamNum(0);
            }
            else //else set the team to a random one
            {
                player.server_setTeamNum(XORRandom(2));
            }
        }

        CBlob@ newBlob = server_CreateBlob(player.get_string("spawn class"), player.getTeamNum(), getSpawnLocation(player));
        newBlob.server_SetPlayer(player);
        syncTeam(player, newBlob);
        return newBlob;
    }

    return null;
}

//TEAM STUFF

void syncTeam(CPlayer@ player, CBlob@ blob)
{
    if (player is null || blob is null) return;

    if (player.getTeamNum() != blob.getTeamNum())
    {
        blob.server_setTeamNum(player.getTeamNum());
    }
}

int teamSize(int team)
{
    int teamsize = 0;

    for (int i = 0; i < getPlayersCount(); i++)
    {
        if (getPlayer(i).getTeamNum() == team)
        {
            teamsize += 1;
        }
    }

    return teamsize;
}

int getOtherTeamNum(CPlayer@ player)
{
    if (player.getTeamNum() == 0)
    {
        return 1;
    }
    else if (player.getTeamNum() == 1)
    {
        return 0;
    }

    return 255;
}