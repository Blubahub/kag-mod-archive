#define SERVER_ONLY

void onInit(CRules@ this)
{
    this.addCommandID("join");
	this.addCommandID("captureFac");
    this.addCommandID("killFac");
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    if(cmd == this.getCommandID("captureFac"))
    {
        u8 newteam = params.read_u8();
		u8 oldTeam = params.read_u8();
		CBlob@[] blobs;
		getBlobsByTag("wooden", blobs);
		getBlobsByTag("stone", blobs);
		for(u8 o = 0; o < blobs.length(); o++)
		{
			CBlob@ b = blobs[o];
			if(b !is null && b.getTeamNum() == oldTeam && !b.hasTag("faction_base") && b.getName() != "ruins" && !b.hasTag("player"))
			{
				b.server_setTeamNum(newteam);
			}
		}
		for(u8 i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if(player !is null)
			{
				CBlob@ blob = player.getBlob();
				if(blob is null)
					player.server_setTeamNum(100+getNumNeutrals());
			}
		}
		this.set_s16("tickets_team_"+oldTeam, 25);
		this.Sync("tickets_team_"+oldTeam, true);
    }
	if(cmd == this.getCommandID("killFac"))
    {
        u8 team = params.read_u8();
		CBlob@[] blobs;
		getBlobsByTag("wooden", blobs);
		getBlobsByTag("stone", blobs);
		for(u8 o = 0; o < blobs.length(); o++)
		{
			CBlob@ b = blobs[o];
			if(b !is null && b.getTeamNum() == team && !b.hasTag("faction_base") && b.getName() != "ruins" && !b.hasTag("player"))
			{
				b.server_Die();
			}
		}
		for(u8 i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if(player !is null)
			{
				CBlob@ blob = player.getBlob();
				if(blob is null)
					player.server_setTeamNum(100+getNumNeutrals());
			}
		}
		this.set_s16("tickets_team_"+team, 25);
		this.Sync("tickets_team_"+team, true);
    }
}

void onTick(CRules@ this)
{
	/*CBlob@[] facbases;
	getBlobsByName("facbase", @facbases);
	if(facbases.length() != 0)
	{
		for (uint facs = 0; facs < facbases.length; facs++)
		{
			CBlob@ facbase = facbases[facs];
			if(facbase !is null)
			{
				bool remove = true;
				u8 team = facbase.getTeamNum();
				for(u8 p = 0; p < getPlayerCount(); p++)
				{
					CPlayer@ player = getPlayer(p);
					if(player !is null && player.getTeamNum() == team)
					{
						remove = false;
						break;
					}
				}
				if(remove)
					facbase.server_Die();
			}
		}
	}*/
}

int getNumNeutrals()
{
	int num = 0; 
	for(int i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null && player.getTeamNum() >= 100)
		{
			num++;
		}
	}
	return num;
}