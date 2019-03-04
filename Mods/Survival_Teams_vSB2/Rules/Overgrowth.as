#define SERVER_ONLY
#include "canGrow.as";
#include "MakeSeed.as";
#include "Hitters.as";

// A tiny mod by TFlippy

const string[] seeds =
{
	"tree_pine",
	"tree_bushy",
	"bush",
	"grain_plant",
	"flowers"
};

const Vec2f[] dir =
{
	Vec2f(8, 0),
	Vec2f(-8, 0),
	Vec2f(0, 8)
};

float tickrate = 5;

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	tickrate = Maths::Ceil(30 / (3 + 0.02 * map.tilemapwidth));

	print("Overgrowth tickrate: " + tickrate);
}

void DecayStuff()
{
	CMap@ map = getMap();
	
	int newPos = XORRandom(map.tilemapwidth) * map.tilesize;
	int newLandY = map.getLandYAtX(newPos / 8) * 8;
	
	Vec2f tilePos = Vec2f(newPos, newLandY - 8);
	Vec2f offset = Vec2f(tilePos.x + (XORRandom(6) - 3) * 8, tilePos.y + (XORRandom(6) - 3) * 8);
	
	CBlob@[] blobs;
	map.getBlobsInRadius(tilePos, 16, @blobs);
	
	// map.server_DestroyTile(offset, 2.0f);
	
	if (map.getTile(tilePos).type != CMap::tile_ground)
	{
		return;
	}
		
	switch(map.getTile(offset).type)
	{
		case CMap::tile_castle:
			map.server_SetTile(offset, CMap::tile_castle_moss);
			break;
			
		case CMap::tile_castle_back:
			map.server_SetTile(offset, CMap::tile_castle_back_moss);
			break;
			
		case CMap::tile_castle_moss:
			if (XORRandom(100) < 50 && !map.isTileSolid(offset + Vec2f(0, -8)) && blobs.length < 2) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(2)]);
			break;
			
		case CMap::tile_castle_back_moss:
			if (XORRandom(100) < 50 && map.isTileSolid(offset + Vec2f(0, 8)) && blobs.length < 2) server_MakeSeed(tilePos, seeds[XORRandom(2)]);
			break;
	}
	
	if (!map.isTileSolid(tilePos + Vec2f(0, -8)))
	{
		switch(map.getTile(tilePos + Vec2f(0, -8)).type)
		{
			case CMap::tile_empty:
				map.server_SetTile(tilePos + Vec2f(0, -8), CMap::tile_grass + XORRandom(3));
				if (XORRandom(2) == 0 && blobs.length < 2) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(seeds.length)]);
				break;
				
			case CMap::tile_castle_back:
				map.server_SetTile(tilePos + Vec2f(0, -8), CMap::tile_castle_back_moss);
				break;
				
			case CMap::tile_ground_back:
				if (XORRandom(2) == 0 && blobs.length < 2) server_MakeSeed(tilePos + Vec2f(0, -8), "bush");
				break;
		}
		
		for (int i = 0; i < dir.length; i++)
		{
			if (map.getTile(tilePos + dir[i]).type == CMap::tile_castle)
			{
				map.server_SetTile(tilePos + dir[i], CMap::tile_castle_moss);
			}
		}
	}
}

void onTick(CRules@ this)
{
	if (getGameTime() % tickrate == 0)
	{
		DecayStuff();
		// print("Overgrowth tickrate: " + tickrate);
	}
}