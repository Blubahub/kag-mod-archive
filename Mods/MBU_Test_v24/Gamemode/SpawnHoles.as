#define SERVER_ONLY;

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	
	Vec2f tilePos = Vec2f(XORRandom(map.tilemapwidth) * map.tilesize,XORRandom(map.tilemapheight-1) * map.tilesize);
	Vec2f tilePosUnder = tilePos+Vec2f(0,8);
	
	uint16 tile = map.getTile(tilePos).type;
	uint16 tile_under = map.getTile(tilePosUnder).type;

	if(map.isTileGroundBack(tile) && map.isTileGround(tile_under) && !map.isInWater(tilePos))
	{
		server_CreateBlob("mouse_hole",-1,tilePos);
	}
	
	CBlob@[] list;
	getBlobsByName("mouse_hole", @list);
	
	if(list.length >= 10)this.RemoveScript("SpawnHoles.as");
}