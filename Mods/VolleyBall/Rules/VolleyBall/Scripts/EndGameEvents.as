#define SERVER_ONLY

void onInit(CRules@ this)
{
	Random _r( getGameTime() );
	switch ( _r.NextRanged(4) )
	{
		case 0: DropBigBalls();  break;
		case 1: DropExplosives();  break;
		case 2: DropGregs();  break;
		case 3: DropBigBisons(); break;
		//case 4: DropFishies();  break;
	}
}

void DropBigBalls()
{
	for (int i = 0; i < 50; i++)
	{
		CBlob@ b = server_CreateBlob("bigbeachball");
		if (b !is null)
		{
			CMap@ map = getMap();
			f32 mapWidth = (map.tilemapwidth * map.tilesize);
			f32 mapHeight = (map.tilemapheight * map.tilesize);

			b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));					
			b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*5));
		}
	}
}

void DropBigBisons()
{
	for (int i = 0; i < 25; i++)
	{
		CBlob@ b = server_CreateBlob("bison");
		if (b !is null)
		{			
			CMap@ map = getMap();
			f32 mapWidth = (map.tilemapwidth * map.tilesize);	
			f32 mapHeight = (map.tilemapheight * map.tilesize);

			b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));	
			b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*5));
		}
	}
}

void DropExplosives()
{
	for (int i = 0; i < 35; i++)
	{
		CBlob@ b = server_CreateBlob("mine");
		if (b !is null)
		{			
			CMap@ map = getMap();
			f32 mapWidth = (map.tilemapwidth * map.tilesize);	
			f32 mapHeight = (map.tilemapheight * map.tilesize);

			b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
			b.server_setTeamNum(XORRandom(8));
			b.set_u8("mine_timer", 45);
			b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*20));
		}
	}
	for (int i = 0; i < 15; i++)
	{
		CBlob@ b = server_CreateBlob("keg");
		if (b !is null)
		{			
			CMap@ map = getMap();
			f32 mapWidth = (map.tilemapwidth * map.tilesize);	
			f32 mapHeight = (map.tilemapheight * map.tilesize);

			b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
			b.set_f32("keg_time", 99999.0f);
			b.SendCommand(b.getCommandID("activate"));
			b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*30));
		}
	}
}

void DropFishies()
{
	for (int i = 0; i < 50; i++)
	{
		CBlob@ b = server_CreateBlob("fishy");
		if (b !is null)
		{			
			CMap@ map = getMap();
			f32 mapWidth = (map.tilemapwidth * map.tilesize);	
			f32 mapHeight = (map.tilemapheight * map.tilesize);

			b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
			//b.server_setTeamNum(XORRandom(8));
			b.set_u8("age", 3);
			b.SetMass(6.0f);
			b.getShape().setElasticity(0.4f);
			b.SetFacingLeft(XORRandom(2) == 0);
			b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*20));
		}
	}
}

void DropGregs()
{
	for (int i = 0; i < 15; i++)
	{
		CBlob@ b = server_CreateBlob("greg");
		if (b !is null)
		{			
			CMap@ map = getMap();
			f32 mapWidth = (map.tilemapwidth * map.tilesize);	
			f32 mapHeight = (map.tilemapheight * map.tilesize);

			//b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));

			b.SetFacingLeft(XORRandom(2) == 0);
			b.setPosition(Vec2f(XORRandom(mapWidth), 0));
		}
	}
}