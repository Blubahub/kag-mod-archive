//Spawn piglets randomly
#define SERVER_ONLY

const f32 SPAWN_CHANCE_FACTOR = 0.8f;//higher values increase chance. 1 = 50/50 chance
const u16 FREQUENCY = 60 * 30;//30 = 1 second

void onTick(CRules@ this)
{
	if ( getGameTime() % FREQUENCY > 0 ) return;	

	CMap@ map = getMap();
	CBlob@[] piglets;//all the map spawns here for an initial quantity check
	Vec2f[] pigletSpots;//this will receive all the markers. it's an array

	getBlobsByName( "bf_piglet", @piglets );//actually gets the piglets
	map.getMarkers( "bf_spawnpiglet", pigletSpots );//actually gets the markers

	if ( piglets.length() >= pigletSpots.length() )
		return;

	//cycle through all piglet markers  
	for( int s = 0; s < pigletSpots.length(); s++ )
	{
		Vec2f spot = pigletSpots[s];
		
		//randomly spawn piglet if tile is clear
		if ( XORRandom( 11 ) * SPAWN_CHANCE_FACTOR >= 5  )
				server_CreateBlob( "bf_piglet", 0, spot );
	}        
}