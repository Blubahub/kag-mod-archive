Random _teamrandom(0x7ea177);

s32 getMinimumTeam(CRules@ this, const int higherThan = -1)
{
    const int teamsCount = this.getTeamsCount();
    int[] playersperteam;
    for(int i = 0; i < teamsCount; i++)
        playersperteam.push_back(0);

    //gather the per team player counts
    const int playersCount = getPlayersCount();
    for(int i = 0; i < playersCount; i++)
    {
        CPlayer@ p = getPlayer(i);
        s32 pteam = p.getTeamNum();
        if(pteam >= 0 && pteam < teamsCount)
        {
            playersperteam[pteam]++;
        }
    }

    //calc the minimum player count
    int minplayers = 1000;
    for(int i = 0; i < teamsCount; i++)
    {
        if (playersperteam[i] < higherThan)
            playersperteam[i] = 1000;
        minplayers = Maths::Min(playersperteam[i], minplayers);
    }

    //choose a random team with minimum player count
    s32 team = 0;
    do {
        team = (team + 1) % teamsCount;
    } while(playersperteam[team] != minplayers);

    return team;
}

string getTeamMarkerString( const u8 team )
{
    switch (team)
    {
        case 0: return "blue spawn";
        case 1: return "red spawn";
        case 2: return "green spawn";
        case 3: return "pink spawn";
        default: return "neutral spawn";
    }
    return "unknown";
}

int _spawnNum = -1;

Vec2f getSpawnPosition(const int team = -1)
{
    Vec2f[] spawns;
    CMap@ map = getMap();
    if (team < 0)
    {
        _spawnNum++;
        if (_spawnNum >= 4){
            _spawnNum = 0;
        }

        if (map.getMarkers( getTeamMarkerString(_spawnNum), spawns )) {
            return spawns[ _teamrandom.NextRanged(spawns.length) ];
        }
    }
    else{
        if (map.getMarkers( getTeamMarkerString(team), spawns )) {
            return spawns[ _teamrandom.NextRanged(spawns.length) ];
        }
    }

    warn("Spawns markers not found for team " + _spawnNum );
    return Vec2f( map.tilemapwidth*map.tilesize*0.5f, map.tilemapheight*map.tilesize*0.5f );
}

Vec2f getFirstSpawnPosition(const u8 team)
{
    Vec2f[] spawns;
    CMap@ map = getMap();
    if (map.getMarkers( getTeamMarkerString(team), spawns ))
    {
        return spawns[0];
    }

    warn("Spawns markers not found for team " + team );
    return Vec2f( map.tilemapwidth*map.tilesize*0.5f, map.tilemapheight*map.tilesize*0.5f );
}

u8 getOpposingTeam( CPlayer@ player )
{
    return (player.getTeamNum() + 1) % 2;
}

int _team = 1;

CBlob@ SpawnPlayer( CRules@ this, CPlayer@ player )
{
    if (player !is null)
    {
        // remove previous players blob
        CBlob @blob = player.getBlob();
        if (blob !is null)
        {
            CBlob @blob = player.getBlob();
            blob.server_SetPlayer( null );
            blob.server_Die();
        }

        const u8 teamsCount = 2;
        u8 team = player.getTeamNum();
        team = team > 32 ? getMinimumTeam(this) : team;
        u8 classIndex = player.getClassNum();

        if (player.isBot()){
            printf("Adding bot to team " + team + ", class " + classIndex );
        }

        player.server_setTeamNum(team);
        player.server_setClassNum( classIndex );

        CBlob @newBlob = server_CreateBlobNoInit( "soldier" );
        if (newBlob !is null)
        {
            newBlob.server_setTeamNum( team );
            newBlob.setPosition( getSpawnPosition(team) );
            newBlob.server_SetPlayer( player );
            newBlob.set_u8("class", classIndex );
            if(getRules().exists("spawn_skin"))
                newBlob.set_u8("skin", getRules().get_u8("spawn_skin"));
            newBlob.Init();
            if (newBlob.isBot()){
                newBlob.getBrain().server_SetActive( true );
            }
        }

        return newBlob;
    }

    return null;
}

bool hasMenus(CRules@ this)
{
    return this.get_s16("in menu") > 0;
}
