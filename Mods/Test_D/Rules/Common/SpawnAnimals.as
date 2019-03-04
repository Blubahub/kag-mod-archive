#define SERVER_ONLY

Random _random(Time());

void onInit( CRules@ this )
{
	CMap@ map = getMap();
	Vec2f[] positions;
	if (map.getMarkers("croc", positions))
	{
		Vec2f pos = positions[ _random.Next() % positions.length ];
		server_CreateBlob("croc", -1, pos);
	}	
}

void onRestart( CRules@ this )
{
	onInit( this );
}