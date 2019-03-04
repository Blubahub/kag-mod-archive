// BF_ExtraNoBuild script

void onInit(CRules@ this)
{
    addBarrier();
}

void onRestart(CRules@ this)
{
    addBarrier();
}

void addBarrier()
{
	CMap@ map = getMap();
	f32 mapWidth = map.tilemapwidth * map.tilesize;
	f32 mapHeight = map.tilemapheight * map.tilesize;
	f32 barrierWidth = 2.0f * map.tilesize;
	f32 barrierHeight = 4.0f * map.tilesize;

	// Ceiling
    Vec2f tlCeiling = Vec2f(0.0f, 0.0f);
    Vec2f brCeiling = Vec2f(mapWidth, barrierHeight);
    map.server_AddSector(tlCeiling, brCeiling, "no build" );

	// Left
	Vec2f tlLeft = Vec2f(0.0f, 0.0f);
    Vec2f brLeft = Vec2f(barrierWidth, mapHeight);
    map.server_AddSector(tlLeft, brLeft, "no build" );

	// Right
	Vec2f tlRight = Vec2f(mapWidth - barrierWidth, 0.0f);
    Vec2f brRight = Vec2f(mapWidth, mapHeight);
    map.server_AddSector(tlRight, brRight, "no build" );
}