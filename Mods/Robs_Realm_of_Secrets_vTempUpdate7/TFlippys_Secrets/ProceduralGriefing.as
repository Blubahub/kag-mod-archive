
void CreatePit(Vec2f inPos)
{
	CMap@ map = getMap();
	
	uint8 holeSize = 6;
	
	Vec2f center = Vec2f(inPos.x - (holeSize / 2) * map.tilesize, inPos.y);
	uint16 h = map.tilemapheight - center.y / 8;
		
	for (int y = 0; y < h + 2; y++)
	{
		for (int x = 0; x < holeSize + 4; x++)
		{
			map.server_SetTile(center + Vec2f(x - 2, y) * map.tilesize, CMap::tile_empty);
		}
	}
		
	for (int side = -1; side < 2; side += 2)
	{
		print("" + side);
	
		for (int y = 0; y < h;)
		{
			int8 modifier = 4 * -y / h;
			uint8 rnd = XORRandom(5) + Maths::Abs(modifier);
			
			CullSquare(Vec2f(center.x + (XORRandom(2) + holeSize / 2 - modifier) * side * map.tilesize, (map.tilemapheight - y) * map.tilesize), rnd);

			y = y + rnd / 2.5f;
		}
	}
}

void CullSquare(Vec2f inPos, uint inSize)
{
	CMap@ map = getMap();
	uint8 offset = inSize / 2;
	
	for (int y = 0; y < inSize + XORRandom(1); y++)
	{
		for (int x = 0; x < inSize + XORRandom(3); x++)
		{
			map.server_SetTile(inPos + Vec2f(x, y - offset - 1) * map.tilesize, CMap::tile_empty);
		}
	} 
}