
void onBlobDie(CRules@ this, CBlob@ blob)
{
	if ( blob is null )
		return;
	
	CPlayer@ victimPlayer = blob.getPlayer(); 	
	if ( victimPlayer !is null )
	{
		int victimTeamNum = victimPlayer.getTeamNum();
		
		//check for existing gravestones for victim
		bool spawnGravestone = true;		
		CBlob@[] gravestones;
		if (getBlobsByName("gravestone", @gravestones))
		{
			for (uint step = 0; step < gravestones.length; ++step)
			{
				CBlob@ gravestone = gravestones[step];
				if ( gravestone is null )
					continue;
			
				CPlayer@ gravePlayer = getPlayerByNetworkId( gravestone.get_u16( "owner_player" ) );		
				if ( gravePlayer !is null )
				{
					if (gravePlayer is victimPlayer)
						spawnGravestone = false;
				}
			}
		}
		
		//spawn gravestone if none exists for victim
		if ( spawnGravestone == true )
		{
			if ( blob !is null )
			{
				CBlob@ gravestone = server_CreateBlob("gravestone", victimTeamNum, blob.getPosition());
				if (gravestone !is null)
				{
					gravestone.setVelocity(Vec2f(XORRandom(12) - 6, -6));
					gravestone.set_u16( "owner_player", victimPlayer.getNetworkID() );
				}			
			}
			else
			{
				spawnGraveAtBase( victimPlayer );
			}
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	this.set_bool("join",true);
	this.SyncToPlayer("join", player);
	
	if ( player !is null )
	{
		int victimTeamNum = player.getTeamNum();
		
		//check for existing gravestones for player
		bool spawnGravestone = true;		
		CBlob@[] gravestones;
		if (getBlobsByName("gravestone", @gravestones))
		{
			for (uint step = 0; step < gravestones.length; ++step)
			{
				CBlob@ gravestone = gravestones[step];
				if ( gravestone is null )
					continue;
			
				CPlayer@ gravePlayer = getPlayerByNetworkId( gravestone.get_u16( "owner_player" ) );		
				if ( gravePlayer !is null )
				{
					if (gravePlayer is player)
						spawnGravestone = false;
						
					CBlob@ playerBlob = player.getBlob();
					if ( playerBlob !is null )
					{
						spawnGravestone = false;
					}
				}
			}
		}
		
		//spawn gravestone if none exists for player and player is dead
		if ( spawnGravestone == true )
		{
			spawnGraveAtBase( player );
		}		
	}
}

void spawnGraveAtBase( CPlayer@ player )
{
	//spawn grave at the base
	Vec2f spawnLocation = Vec2f( 32, 32 );
	if (player !is null)
	{		
		spawnLocation = getSpawnLocation( player );
	}
	
	CBlob@ gravestone = server_CreateBlob("gravestone", player.getTeamNum(), spawnLocation);
	if (gravestone !is null)
	{
		gravestone.setVelocity(Vec2f(XORRandom(12) - 6, -6));
		gravestone.set_u16( "owner_player", player.getNetworkID() );	
	}
}

Vec2f getSpawnLocation( CPlayer@ player )
{
	CBlob@[] spawns;
	CBlob@[] teamspawns;

	if (getBlobsByName("tdm_spawn", @spawns))
	{
		for (uint step = 0; step < spawns.length; ++step)
		{
			if (spawns[step].getTeamNum() == player.getTeamNum())
			{
				teamspawns.push_back(spawns[step]);
			}
		}
	}

	if (teamspawns.length > 0)
	{
		int spawnindex = XORRandom(997) % teamspawns.length;
		return teamspawns[spawnindex].getPosition();
	}

	return Vec2f(0, 0);
}
