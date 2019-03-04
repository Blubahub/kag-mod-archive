// A* PATH-FINDING CALLBACKS

// low level

void onPathGetSuccessors( Vec2f tilepos )
{
	CMap@ map = getMap();
	Tile tile = map.getTileFromTileSpace( tilepos );

	Vec2f succ;

    if (tilepos.x > 0)
    {
    	succ.Set(tilepos.x-1, tilepos.y);
        if (isTraversable(map, succ)){
            AddPathSuccessor( succ );
        }
    }

    if (tilepos.x < map.tilemapwidth - 1)
    {
    	succ.Set(tilepos.x+1, tilepos.y);
        if (isTraversable(map, succ)){
            AddPathSuccessor( succ );
        }
    }
	     
    if (tilepos.y > 0)
    {
    	succ.Set(tilepos.x, tilepos.y-1);
        if (isTraversable(map, succ) && isReachable(map, tilepos, succ) ){
            AddPathSuccessor( succ );
        }
    }

    if (tilepos.y < map.tilemapheight - 1)
    {
    	succ.Set(tilepos.x, tilepos.y+1);
        if (isTraversable(map, succ)){
            AddPathSuccessor( succ );
        }
    }
}

bool isTraversable( CMap@ map, Vec2f tilepos )
{
	return !map.isTileSolid( map.getTileFromTileSpace( tilepos ) );
}

bool isReachable( CMap@ map, Vec2f tilepos, Vec2f next_tilepos )
{
	CMap::Tile nextTile = map.getTileFromTileSpace( Vec2f( tilepos.x, tilepos.y+1 ) );
	bool inAir = next_tilepos.y < tilepos.y 
				 && !map.isTileSolid( nextTile ) && !map.isTileLadder( nextTile );

	if (inAir)
	{
		// height
		int height = 0;
		nextTile = map.getTileFromTileSpace( next_tilepos );
		while (tilepos.y < map.tilemapheight-1 
			&& !map.isTileSolid( nextTile )	&& !map.isTileLadder( nextTile )
			)
		{
			height++;
			next_tilepos.y += 1;
			nextTile = map.getTileFromTileSpace( next_tilepos );
		}

		return height < 6;
	}
	else
		return true;
}

f32 onPathGetCost( Vec2f tilepos, Vec2f succ_tilepos )
{
	CMap@ map = getMap();

	CMap::Tile nextTile = map.getTileFromTileSpace( Vec2f( tilepos.x, tilepos.y+1 ) );
	f32 cost = (map.isTileSolid(nextTile) || map.isTileLadder(nextTile) )? 1.0f : 5.0f;

	// the higher it is the more costly
	nextTile = map.getTileFromTileSpace( tilepos );
	while (tilepos.y < map.tilemapheight-1 
	    	&& !map.isTileSolid(nextTile) && !map.isTileLadder(nextTile) )
	{
		tilepos.y += 1;
		CMap::Tile tileLeft = map.getTileFromTileSpace( Vec2f( tilepos.x-1, tilepos.y ) );
		CMap::Tile tileRight = map.getTileFromTileSpace( Vec2f( tilepos.x+1, tilepos.y ) );
		if (map.isTileSolid( tileLeft )	|| map.isTileSolid( tileRight )
			|| map.isTileLadder( tileLeft )	|| map.isTileLadder( tileRight ))
			cost += 1.0f;
		else
			cost += 5.0f;
		nextTile = map.getTileFromTileSpace( tilepos );
	}

	nextTile = map.getTileFromTileSpace( succ_tilepos );
	while (succ_tilepos.y < map.tilemapheight-1 
		   && !map.isTileSolid( nextTile ) && !map.isTileLadder( nextTile ) ) 
	{
		succ_tilepos.y += 1;
		CMap::Tile tileLeft = map.getTileFromTileSpace( Vec2f( succ_tilepos.x-1, tilepos.y ) );
		CMap::Tile tileRight = map.getTileFromTileSpace( Vec2f( succ_tilepos.x+1, tilepos.y ) );		
		if (map.isTileSolid( tileLeft ) || map.isTileSolid( tileRight )
			|| map.isTileLadder( tileLeft ) || map.isTileLadder( tileRight ))
			cost += 1.0f;
		else
			cost += 5.0f;
		nextTile = map.getTileFromTileSpace( succ_tilepos );
	}

	return cost;
}


// high level map reset callback

void onHighLevelNode( int x, int y, CMapZoneTile@ zone )
{
	CMap@ map = getMap();
	int index = x + y * map.tilemapwidth;
	bool solidAbove = map.isTileSolid(map.getTile(index - map.tilemapwidth));
	bool solidBelow = map.isTileSolid(map.getTile(index + map.tilemapwidth));
	bool solidSide = map.isTileSolid(map.getTile(index + 1)) || 
					 map.isTileSolid(map.getTile(index - 1));

	Tile solid = map.getTile(index);

	//antisqueeze
	zone.solid = false;
	if ((map.isTileSolid(solid)) || solidAbove)
	{
		zone.solid = true;
		return;
	}

	//default cost to 5
	zone.cost = 5;

	//floor is low cost
	if (solidBelow)
	{
		zone.cost = 1;
		return;
	}
	else
	{
		Vec2f p((x+0.5f)*map.tilesize, (y+0.5f)*map.tilesize);
		Vec2f next = p + Vec2f(0,3*map.tilesize);
		solidBelow = map.rayCastSolid(p, next);
		if(!solidBelow)
		{
			zone.cost += 5;
			p = next;
			next = p + Vec2f(0,4*map.tilesize);
			solidBelow = map.rayCastSolid(p, next);
			if(!solidBelow && !solidSide)
			{
				zone.cost += 15;
			}
		}
	}
}