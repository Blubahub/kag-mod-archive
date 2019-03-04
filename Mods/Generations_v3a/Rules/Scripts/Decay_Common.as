#include "canGrow.as";
#include "MakeSeed.as";
#include "Hitters.as";

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


void DecayStuff(int times){
	for(int i = 0;i < times;i++){
		Decay();
	}
}

void Decay()
{
	CMap@ map = getMap();
	
	Vec2f tilePos = Vec2f(XORRandom(map.tilemapwidth) * map.tilesize,XORRandom(map.tilemapheight) * map.tilesize);
	
	uint16 tile = map.getTile(tilePos).type;
	
	CBlob@[] blobs;
	map.getBlobsInRadius(tilePos, 32, @blobs);
	
	bool overgrow = false;
	
	for(int i = 0;i < blobs.length && !overgrow;i++){
		string name = blobs[i].getName();
		if(name == "tree_bushy")overgrow = true;
		else if(name == "tree_pine")overgrow = true;
		else if(name == "grain_plant")overgrow = true;
		else if(name == "bush")overgrow = true;
		else if(name == "flowers")overgrow = true;
	}
	
	for(int i = -4;i <= 4 && !overgrow;i++)
	for(int j = -4;j <= 4 && !overgrow;j++){
		if(map.isTileGrass(map.getTile(tilePos+Vec2f(i*8,j*8)).type))overgrow = true;
		else if(map.getTile(tilePos+Vec2f(i*8,j*8)).type == CMap::tile_castle_moss)overgrow = true;
		else if(map.getTile(tilePos+Vec2f(i*8,j*8)).type == CMap::tile_castle_back_moss)overgrow = true;
	}
	
	if(overgrow){
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
	}
	
	if (map.isTileWood(tile) && tile != CMap::tile_wood_d0) //Damage wood
	{
		map.server_DestroyTile(tilePos, 0.5f);
	}
	
	if(XORRandom(10) == 0)
	{
		if(map.isTileBackground(map.getTile(tilePos)) && map.isTileBackground(map.getTile(tilePos + Vec2f(0, 8))) && map.isTileBackground(map.getTile(tilePos + Vec2f(0, 16))))
		if(map.isTileSolid(map.getTile(tilePos + Vec2f(0, -8)).type)) //Grow ivy
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