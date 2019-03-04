#include "Hitters.as";
#include "CustomBlocks.as";

uint start_blizzard = 6000 + XORRandom(6000);
uint end_blizzard = start_blizzard + 1000 + XORRandom(1000);

void onRestart(CRules@ this)
{
	u32 time = getGameTime();
	
	start_blizzard = time + 6000 + XORRandom(6000);
	end_blizzard = start_blizzard + 1000 + XORRandom(1000);
}

void onTick(CRules@ this)
{
	if (getNet().isServer())
	{
		u32 time = getGameTime();
//*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******
		if (time == start_blizzard)
		{
			CBlob@ blizzard = server_CreateBlobNoInit("blizzard");
			blizzard.Init();
			blizzard.server_SetTimeToDie((end_blizzard - start_blizzard) / 30);
			blizzard.set_s32("timetodie", int((end_blizzard - start_blizzard)/30)*30);
			blizzard.Sync("timetodie", false);
			
			start_blizzard = end_blizzard + 6000 + XORRandom(6000);
			end_blizzard = start_blizzard + 1000 + XORRandom(1000);
		}

		CBlob@[] blizzard;
		getBlobsByName("blizzard", @blizzard);
			
		if (blizzard.length != 0)
		{
			if (getGameTime() % 2 != 0) return;
			CMap@ map = getMap();
			if (map is null || map.tilemapwidth < 2) return;

			f32 x = XORRandom(map.tilemapwidth*map.tilesize);
			Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
			Vec2f top = Vec2f(x, map.tilesize);
			Vec2f end;

			if (map.rayCastSolid(top, bottom, end))
			{
				f32 y = end.y;
				Vec2f pos = Vec2f(x, y -map.tilesize);
				if(y<=8) return;
				pos = Vec2f(int(pos.x/map.tilesize)*map.tilesize, int(pos.y/map.tilesize)*map.tilesize)+Vec2f(map.tilesize/2,map.tilesize/2);
				if(map.isInWater(pos))
				{
					Vec2f newpos = spawnIce(map, pos);
					map.server_SetTile(newpos, CMap::tile_ice);
					map.server_setFloodWaterWorldspace(newpos, true);
					return;
				}
				pos = diagonalsCheck(map, pos);
				if(map.isInWater(pos))
				{
					map.server_SetTile(pos, CMap::tile_ice);
					map.server_setFloodWaterWorldspace(pos, true);
					return;
				}
				if(isTileIce(map.getTile(pos+Vec2f(0,map.tilesize)).type))
					return;
				bool spawnblock = false;
				CBlob@[] blobs;
				if(map.getBlobsInRadius(pos, 1, blobs))
				{
					for(int i = 0; i < blobs.length; i++)
					{
						CBlob@ b = blobs[i];
						if(b !is null)
						{
							if(b.getName() == "bush" || b.getName() == "flowers" || b.getName() == "grain_plant" || b.getName() == "seed")
								b.server_Die();
							else if(b.getName() == "ruins" || b.getName() == "facbase" || b.hasTag("player"))
							{
								return;
							}
							else if(b.getName() == "SnowPile")
							{
								if(b.getInitialHealth() <= b.getHealth())
								{
									spawnblock = true;
									b.server_Die();
								}
								else
								{
									b.server_Heal(0.5);
									return;
								}
							}
						}
					}
				}
				if(spawnblock)
					map.server_SetTile(pos, CMap::tile_snow);
				else
				{
					CBlob@ pile = server_CreateBlob("SnowPile", -1, pos);
					pile.getShape().SetStatic(true);
					pile.server_SetHealth(0.25);
					if(!map.isTileBackground(map.getTile(pos)) || isGrassTile(map.getTile(pos).type))
						map.server_SetTile(pos, CMap::tile_empty);
				}
			}
		}
//*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******Blizzard*******

//*******Aurora Borealis*******Aurora Borealis*******Aurora Borealis*******Aurora Borealis*******Aurora Borealis*****************

//*******Aurora Borealis*******Aurora Borealis*******Aurora Borealis*******Aurora Borealis*******Aurora Borealis*****************
	}
	
	//rcon CBlob@ newme = server_CreateBlob('builder', -1, Vec2f(0,0)); CPlayer@ player = getPlayerByUsername('GoldenGuy'); newme.server_SetPlayer(player);
}

Vec2f spawnIce(CMap@ map, Vec2f pos)
{
	if(!map.isInWater(pos-Vec2f(0,map.tilesize))) return pos;
    return spawnIce(map, pos-Vec2f(0,map.tilesize));
}

Vec2f diagonalsCheck(CMap@ map, Vec2f pos)
{
	if(map.isInWater(pos))
		return pos;
	if(!map.isTileSolid(map.getTile(pos+Vec2f(0,map.tilesize))))
		return diagonalsCheck(map, pos+Vec2f(0,map.tilesize));
	int l = 0;
	if(!map.isTileSolid(map.getTile(pos+Vec2f(map.tilesize,map.tilesize))) && !map.isTileSolid(map.getTile(pos+Vec2f(map.tilesize,0))))
		l += 1;
	if(!map.isTileSolid(map.getTile(pos+Vec2f(-map.tilesize,map.tilesize))) && !map.isTileSolid(map.getTile(pos+Vec2f(-map.tilesize,0))))
		l += 2;
	switch(l)
	{
		case 0:
			return pos;
		case 1:
			return diagonalsCheck(map, pos+Vec2f(map.tilesize,map.tilesize));
		case 2:
			return diagonalsCheck(map, pos+Vec2f(-map.tilesize,map.tilesize));
		case 3:
			return XORRandom(2) == 0 ? diagonalsCheck(map, pos+Vec2f(map.tilesize,map.tilesize)) : diagonalsCheck(map, pos+Vec2f(-map.tilesize,map.tilesize));
	}
	return pos;
}

void onRender(CRules@ this)
{
	CBlob@[] blizzard;
	getBlobsByName("blizzard", @blizzard);
			
	if (blizzard.length != 0)
	{
		CBlob@ blizzardblob = blizzard[0];
		s32 spec = 0;
		if(blizzardblob.get_s32("timetodie")-blizzardblob.getTickSinceCreated() > blizzardblob.getTickSinceCreated())
			spec = blizzardblob.getTickSinceCreated();
		else
			spec = (blizzardblob.get_s32("timetodie")-blizzardblob.getTickSinceCreated());
		const f32 right = getScreenWidth();
		const f32 bottom = getScreenHeight();
		GUI::DrawRectangle(Vec2f_zero, Vec2f(right, bottom),
		                   SColor(Maths::Clamp(spec*1.8f, 0, 40+blizzardblob.get_f32("modifier")*180), 255, 255, 255));
	}
}