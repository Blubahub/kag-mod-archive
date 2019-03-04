
#include "BasePNGLoader.as";

float tickrate = 30*60*15;

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	
	map.RemoveAllSectors();
	
	if(isServer() && getGameTime() >= map.tilemapwidth*2){
		
		int x = getGameTime() % tickrate;

		if(x < map.tilemapwidth){
		
			if(x == 0)SaveMap(map,"MainMap.png");
			if(x == 1)SaveMap(map,"backups/backup"+Time()+".png");
		
			bool cancelRaise = false;
			bool canErode = true;
			int DeadZoneStartY = -1;
			int DeadZoneEndY = -1;
			
			for(int y = map.tilemapheight-2;y >= 0;y--){
				int tile = map.getTile(Vec2f(x*8,y*8-8)).type;
				
				if(tile == CMap::tile_empty)if(map.isTileGrass(map.getTile(Vec2f(x*8,y*8)).type))continue;
				
				if(!map.isTileGrass(tile)){
					if(map.isTileGround(tile) && XORRandom(map.tilemapheight)*4 < y)tile = CMap::tile_stone;
					else if(map.isTileStone(tile) && XORRandom(map.tilemapheight)*6 < y)tile = CMap::tile_thickstone;
					else if(map.isTileThickStone(tile) && XORRandom(map.tilemapheight)*8 < y)tile = CMap::tile_gold;
					map.server_SetTile(Vec2f(x*8,y*8), tile);
					
					//if(XORRandom(5) != 0)map.server_setFloodWaterWorldspace(Vec2f(x*8,y*8), map.isInWater(Vec2f(x*8,y*8-8)));
					//map.server_setFloodWaterWorldspace(Vec2f(x*8,y*8-8), false);
				} else {
					map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_empty);
					//MinY = y*8;
					//break;
				}
				
				//map.RemoveSectorsAtPosition(Vec2f(x*8,y*8));
			}
			
			for(int y = 0;y < map.tilemapheight;y++){
				int tile = map.getTile(Vec2f(x*8,y*8)).type;
				int under = map.getTile(Vec2f(x*8,y*8+8)).type;
				
				if(DeadZoneEndY == -1)if(map.isTileSolid(tile))DeadZoneStartY = y*8;
				
				if(map.isTileSolid(under)){
					if(map.isTileGroundStuff(under) && map.isTileSolid(under) && map.isTileGroundBack(tile)){
						map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_ground);
						DeadZoneEndY = y*8;
					}
				}
				
				if(map.isTileSolid(Vec2f(x*8,y*8+8))){
					break;
				}
			}
			
			if(!cancelRaise){
				CBlob@[] blobs;
				getBlobs(@blobs);
				
				for(int i = 0;i < blobs.length;i++){
					Vec2f pos = blobs[i].getPosition();
					
					
					
					if(pos.y >= 8)
					if(pos.y < DeadZoneStartY || pos.y > DeadZoneEndY)
					if(pos.x >= x*8 && pos.x < x*8+8){
					
						blobs[i].setPosition(pos+Vec2f(0,+8));
						
						if(blobs[i].getShape() !is null)if(blobs[i].getShape().isStatic())blobs[i].getShape().UpdateStaticBody();
					
					}
					
					
					
					if(pos.y >= map.tilemapheight*8-24)blobs[i].server_Die();
				}
			}
		}
		
		if(getGameTime() >= map.tilemapwidth){
			x = (getGameTime()-map.tilemapwidth) % tickrate;
		
			if(x < map.tilemapwidth){
				for(int y = map.getLandYAtX(x)-1;y < map.tilemapheight;y++){
					if(map.isInWater(Vec2f(x*8,y*8))){
						if(map.isTileGrass(map.getTile(Vec2f(x*8,y*8)).type))map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_empty);
						if(XORRandom(2) == 0){
							if(map.isTileGroundStuff(map.getTile(Vec2f(x*8-8,y*8)).type))map.server_SetTile(Vec2f(x*8-8,y*8), CMap::tile_empty);
							if(map.isTileGroundStuff(map.getTile(Vec2f(x*8+8,y*8)).type))map.server_SetTile(Vec2f(x*8+8,y*8), CMap::tile_empty);
							if(map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8+8)).type))map.server_SetTile(Vec2f(x*8,y*8+8), CMap::tile_empty);
						}
					} else {
						MudSlide(x*8,y*8);
					}
				}
			}
		}
	}
}

void MudSlide(int x, int y){
	CMap@ map = getMap();

	Vec2f tilePos = Vec2f(x,y);
	
	if(map.getSectorAtPosition(tilePos, "no build") is null)
	if(map.isTileBackgroundNonEmpty(map.getTile(tilePos))) //All background gets converted
	if(!CheckPosBlocked(tilePos))
	//if(map.isTileSolid(map.getTile(tilePos + Vec2f(0, 8)).type))
	{ //Only above solid blocks
	
		bool set = false;
	
		if(checkForGround(map.getTile(tilePos + Vec2f(-8, 0)).type) || checkForGround(map.getTile(tilePos + Vec2f(8, 0)).type)) //Checks for any native ground tile to eiher the left or right
		for(int i = tilePos.y/8;i < map.tilemapheight;i++){
			if(CheckPosBlocked(Vec2f(x,i*8)) || map.isTileSolid(Vec2f(x,i*8)))
			{
				map.server_SetTile(Vec2f(x,i*8-8), CMap::tile_ground); //Set to ground obviously
				break;
			}
		}
		
		/*
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
		}*/
		
	}
}

bool CheckPosBlocked(Vec2f middle){
	CMap @map = getMap();
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius(middle, map.tilesize, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (!b.isAttached())
			{
				Vec2f bpos = b.getPosition();

				const string bname = b.getName();

				bool cantBuild = isBlocking(b);

				// cant place on any other blob
				if (cantBuild &&
					!b.hasTag("dead") &&
					!b.hasTag("material") &&
					!b.hasTag("projectile"))
				{
					f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
					bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
					f32 width = rotated ? b.getHeight() : b.getWidth();
					f32 height = rotated ? b.getWidth() : b.getHeight();
					if ((middle.x > bpos.x - width * 0.5f) && (middle.x < bpos.x + width * 0.5f)
						&& (middle.y > bpos.y - height * 0.5f) && (middle.y < bpos.y + height * 0.5f))
					{
						return true;
					}
				}
			}
		}
	}
	
	return false;
}

bool isBlocking(CBlob@ blob)
{
	string name = blob.getName();
	if (name == "heart" || name == "log" || name == "food" || name == "fishy" || name == "steak" || name == "grain")
		return false;

	return blob.isCollidable() || blob.getShape().isStatic();
}

bool checkForGround(int tile){
	CMap @map = getMap();
	return map.isTileGround(tile) || map.isTileStone(tile) || map.isTileThickStone(tile) || map.isTileGold(tile);
}