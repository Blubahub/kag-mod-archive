//Spawn CarrotPlants randomly
#define SERVER_ONLY

const f32 SPAWN_CHANCE_FACTOR = 1.0f;//higher values increase chance. 1 = 50/50 chance
const u16 FREQUENCY = 25 * 30;//30 = 1 second

void onTick(CRules@ this)
{
	if ( getGameTime() % FREQUENCY > 0 ) return;	

	CMap@ map = getMap();
	CBlob@[] carrotPlants;//all the map plantcarrots here for an initial quantity check
	Vec2f[] carrotSpots;//this will receive all the markers. it's an array
	CBlob@[] blobsAtTile;//this will get all the blobs at each marker

	getBlobsByName( "bf_carrotplant", @carrotPlants );//actually gets the carrots
	map.getMarkers( "bf_spawncarrot", carrotSpots );//actually gets the markers

	if ( carrotPlants.length() >= carrotSpots.length() )
		return;

	//cycle through all carrot markers  
	for( int s = 0; s < carrotSpots.length(); s++ )
	{
		Vec2f spot = carrotSpots[s];
		
		if ( !isPosFertile( map, spot ) )//marker spot is not carrot-friendly
		{
			map.RemoveMarker( "bf_spawncarrot", s );
			
			f32 side = XORRandom( 2 ) == 0 ? -1 : 1;
			if ( isPosFertile( map, spot + Vec2f( side * 8, 0 ) ) )
			{
				spot = spot + Vec2f( side * 8, 0 );
				map.AddMarker( spot, "bf_spawncarrot" );
			}
			else if ( isPosFertile( map, spot + Vec2f( -side * 8, 0 ) ) )
			{
				spot = spot + Vec2f( -side * 8, 0 );
				map.AddMarker( spot, "bf_spawncarrot" );
			}
			else//the carrot spawn is lost
				continue;
		}
		map.getBlobsInRadius( spot, 3.0f, @blobsAtTile );
		bool clear = true;
		
		//TileCheck: if any plantcarrots on it
		for( int b = 0; b < blobsAtTile.length(); b++ )
		{                  
			if ( blobsAtTile[b].getName() ==  "bf_carrotplant" || blobsAtTile[b].isCollidable() )
				clear = false;
		}

		//randomly spawn carrot if tile is clear
		if ( clear && XORRandom( 11 ) * SPAWN_CHANCE_FACTOR >= 5  )
				server_CreateBlob( "bf_carrotplant", 0, spot );
		 
		 blobsAtTile.clear();//clears the array for next iteration
	}        
}

bool isPosFertile( CMap@ this, Vec2f spot )
{
		//some tile considerations: solidBlob or no dirt ground under
		Tile tile = this.getTile( spot );
		Tile tileBelow = this.getTile( spot + Vec2f( 0, 8 ) );
		return !this.hasTileSolidBlobs( tile ) && !this.isTileSolid( tile ) && this.isTileGround( tileBelow.type );
}