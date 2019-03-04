Vec2f getSpawnPosition( CMap@ map, int offset )
{
	Vec2f pos = map.getTileWorldPosition(offset);
	f32 tile_offset = map.tilesize * 0.5f;
	pos.x += tile_offset;
	pos.y += tile_offset;
	return pos;
}

CBlob@ spawnBlob( CMap@ map, const string& in name, int offset, int team, bool attached_to_map = false )
{
	CBlob@ blob = server_CreateBlob( name, team, getSpawnPosition( map, offset) );

	if (blob !is null && attached_to_map) {
		blob.getShape().SetStatic( true );
	}
	return blob;
}


void AddMarker( CMap@ map, int offset, const string& in name)
{
	map.AddMarker( map.getTileWorldPosition( offset ) + Vec2f(map.tilesize*0.5f,map.tilesize*0.5f) , name );
}

TileType getMostLikelyTile(CMap@ map, int offset)
{
	TileType t = 0;

	array<u32> lut = {offset+map.tilemapwidth, offset+1, offset-1, offset-map.tilemapwidth};

	for(int i = 0 ; i < 4; i++)
	{
		TileType other = map.getTile(lut[i]).type;
		if (TWMap::isTileMostLikelyCandidate(other))
		{
			t = other;
			break;
		}
	}

	return t;
}

void PlaceMostLikelyTile( CMap@ map, int offset, bool pregame = false )
{
	TileType t = getMostLikelyTile(map, offset);

	if(pregame)
	{
		map.SetTile( offset, t ); //will be serialised anyway
	}
	else
	{
		map.server_SetTile( map.getTileWorldPosition(offset), t );
	}
}
