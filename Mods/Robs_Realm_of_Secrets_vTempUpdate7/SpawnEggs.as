#define SERVER_ONLY

const int min_chicken = 10;
const string chicken_name = "chicken";

void onTick(CRules@ this)
{
	if (getGameTime() %29 != 0) return;
	if (XORRandom(512) < 256) return; //50% chance of actually doing anything

	CMap@ map = getMap();
	if (map is null || map.tilemapwidth < 2) return; //failed to load map?

	CBlob@[] chicken;
	getBlobsByName(chicken_name, @chicken);
	
	if (chicken.length < min_chicken)
	{
		f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;

		Vec2f top = Vec2f(x, map.tilesize);
		Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
		Vec2f end;

		if (map.rayCastSolid(top, bottom, end))
		{
			f32 y = end.y;
			int i = 0;
			while (i ++ < 3)
			{
				Vec2f pos = Vec2f(x, y - i * map.tilesize);
				if (!map.isInWater(pos))
				{
					server_CreateBlob("egg", -1, pos);
					break;
				}
			}
		}
	}
}
