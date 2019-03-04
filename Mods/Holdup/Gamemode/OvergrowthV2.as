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

float tickrate = 1;

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	//tickrate = Maths::Ceil(30 / (3 + 0.02 * map.tilemapwidth));

	print("Overgrowth tickrate: " + tickrate);
}

void DecayStuffOld()
{
	CMap@ map = getMap();
	
	int newPos = XORRandom(map.tilemapwidth) * map.tilesize;
	int newLandY = map.getLandYAtX(newPos / 8) * 8;
	
	Vec2f tilePos = Vec2f(newPos, newLandY - 8);
	Vec2f offsetPos = Vec2f(tilePos.x + (XORRandom(10) - 5) * 8, tilePos.y + (XORRandom(6) - 3) * 8);
	Vec2f offsetChainPos;
	
	uint16 tile = map.getTile(tilePos).type;
	uint16 offsetTile = map.getTile(offsetPos).type;
	
	CBlob@[] blobs;
	map.getBlobsInRadius(tilePos, 32, @blobs);
	
	if (map.isTileGround(tile) && !map.isInWater(tilePos + Vec2f(0, -8)))
	{
		if (map.getTile(tilePos + Vec2f(0, -8)).type == CMap::tile_empty)
		{
			map.server_SetTile(tilePos + Vec2f(0, -8), CMap::tile_grass + XORRandom(3));
			if (XORRandom(2) == 0 && blobs.length < 4) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(seeds.length)]);
		}
		else if (!map.isTileSolid(tilePos + Vec2f(0, -8)))
		{
			if (XORRandom(2) == 0 && blobs.length < 4) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(3)]);
		}

		offsetChainPos = Vec2f(offsetPos.x + (XORRandom(2) - 1) * 8, offsetPos.y + (XORRandom(2) - 1) * 8);
		
		for (int i = 0; i < 6; i++)
		{
			if (map.getTile(offsetChainPos).type == CMap::tile_castle_back)
			{
				if (XORRandom(100) < 80) map.server_SetTile(offsetChainPos, CMap::tile_castle_back_moss); else map.server_DestroyTile(offsetChainPos, 5.0f);
			}
			else if (map.getTile(offsetChainPos).type == CMap::tile_castle)
			{
				map.server_SetTile(offsetChainPos, CMap::tile_castle_moss);
			}
			offsetChainPos = Vec2f(offsetChainPos.x + (XORRandom(2) - 1) * 8, offsetChainPos.y - (XORRandom(2)) * 8);
		}
		
		if (map.isTileCastle(offsetTile))
		{
			map.server_SetTile(offsetPos, CMap::tile_castle_moss);
		}
		else if (map.isTileWood(offsetTile) && offsetTile != CMap::tile_wood_d0)
		{
			map.server_DestroyTile(offsetPos, 0.5f);
		}
	}
	else
	{
		return;
	}
}

void DecayStuff()
{
	CMap@ map = getMap();
	
	Vec2f tilePos = Vec2f(XORRandom(map.tilemapwidth) * map.tilesize,XORRandom(map.tilemapheight) * map.tilesize);
	
	uint16 tile = map.getTile(tilePos).type;

	//It would be nice to check for nature here before spreading, but honestly TC is laggy as is, that'd only make it worse
	//CBlob@[] blobs;
	//map.getBlobsInRadius(tilePos, 32, @blobs);
	
	if(map.isTileCastle(tile)) //Mossy tiles
	{
		map.server_SetTile(tilePos, CMap::tile_castle_moss);
	}
	else if(map.getTile(tilePos).type == CMap::tile_castle_back) //Mossy tiles
	{
		map.server_SetTile(tilePos, CMap::tile_castle_back_moss);
	}
	else if(!map.isInWater(tilePos))
	{	//Grass tiles
		if(map.getTile(tilePos).type == CMap::tile_empty && (map.isTileGround(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileStone(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileThickStone(map.getTile(tilePos + Vec2f(0, 8)).type))) 
		{
			map.server_SetTile(tilePos, CMap::tile_grass + XORRandom(3));
			if (XORRandom(2) == 0) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(seeds.length)]);
		}
	}
	else if (map.isTileWood(tile) && tile != CMap::tile_wood_d0) //Damage wood
	{
		map.server_DestroyTile(tilePos, 0.5f);
	}
	
	if(XORRandom(10) == 0)
	{
		if(map.isTileBackground(map.getTile(tilePos)) && map.isTileSolid(map.getTile(tilePos + Vec2f(0, -8)).type)) //Grow ivy
		{
			for(int i = 0; i < 20; i++){
				if(i*8+tilePos.x > 0)
				if(!map.isTileSolid(map.getTile(tilePos + Vec2f(0, -(8+8*i))).type)){
					
					if(map.isTileGrass(map.getTile(tilePos + Vec2f(0, -(8+8*i))).type)){
						server_CreateBlob("ivy",-1,tilePos+Vec2f(0,16));
					}
					
					break;
				}
			}
		}
	}
}

void MudSlide(){
	CMap@ map = getMap();
	
	for(int i = 0; i < 50; i += 1){
	
		Vec2f tilePos = Vec2f(XORRandom(map.tilemapwidth) * map.tilesize,XORRandom(map.tilemapheight) * map.tilesize);
		
		if(map.getSectorAtPosition(tilePos, "no build") is null)
		if(map.isTileBackgroundNonEmpty(map.getTile(tilePos))) //All background gets converted
		if(map.isTileSolid(map.getTile(tilePos + Vec2f(0, 8)).type)){ //Only above solid blocks
		
			if(checkForGround(map.getTile(tilePos + Vec2f(-8, 0)).type)) //Checks for any native ground tile to eiher the left or right
			if(map.isTileSolid(map.getTile(tilePos + Vec2f(8, 0)).type) || map.isTileSolid(map.getTile(tilePos + Vec2f(8, 8)).type) || map.isTileSolid(map.getTile(tilePos + Vec2f(8, 16)).type))
			{
				map.server_SetTile(tilePos, CMap::tile_ground); //Set to ground obviously
			}
			if(checkForGround(map.getTile(tilePos + Vec2f(8, 0)).type))
			if(map.isTileSolid(map.getTile(tilePos + Vec2f(-8, 0)).type) || map.isTileSolid(map.getTile(tilePos + Vec2f(-8, 8)).type) || map.isTileSolid(map.getTile(tilePos + Vec2f(-8, 16)).type))
			{
				map.server_SetTile(tilePos, CMap::tile_ground); //Set to ground obviously
			}
			
			if(XORRandom(100) == 0){ //Tiny chance for roof mud drip
				for(int j = 0; j < 40; j++){
					if(j*8+tilePos.x > 0)
					if(map.isTileSolid(map.getTile(tilePos + Vec2f(0, -(8+8*j))).type)){
						
						if(map.isTileGround(map.getTile(tilePos + Vec2f(0, -(8+8*j))).type) || map.isTileStone(map.getTile(tilePos + Vec2f(0, -(8+8*j))).type) || map.isTileThickStone(map.getTile(tilePos + Vec2f(0, -(8+8*j))).type)){
							map.server_SetTile(tilePos, CMap::tile_ground);
						}
						
						break;
					}
				}
			}
			
		}
	}
}

bool checkForGround(int tile){
	CMap @map = getMap();
	return map.isTileGround(tile) || map.isTileStone(tile) || map.isTileThickStone(tile) || map.isTileGold(tile);
}

void onTick(CRules@ this)
{
	if (getGameTime() % tickrate == 0)
	{
		CBlob@[] rain;
		getBlobsByName("rain", @rain);
		
		if(rain.length > 0)MudSlide();
		
		for(int i = 0; i < 1+rain.length*5; i += 1)
		DecayStuff();
		// print("Overgrowth tickrate: " + tickrate);
	}
}