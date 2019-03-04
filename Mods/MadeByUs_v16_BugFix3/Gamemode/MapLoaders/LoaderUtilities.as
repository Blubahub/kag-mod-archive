#include "DummyCommon.as";
#include "ParticleSparks.as";

namespace CMap
{
	enum CustomTiles
	{ 
		tile_iron = 384,
		tile_iron_d0 = 385,
		tile_iron_d1 = 386,
		tile_iron_d2 = 387,
		tile_iron_d3 = 388,
		tile_iron_d4 = 389,
		tile_iron_d5 = 390,
		tile_iron_d6 = 391,
		tile_iron_d7 = 392,
		tile_iron_d8 = 393,
		tile_glass = 394,
		tile_glass_d0 = 395
	};
};

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(map.getTile(offset).type > 255)
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		// print("Hit - Old: " + oldTileType + "; Index: " + index);
		
		switch(oldTileType)
		{
			case CMap::tile_iron:
				return CMap::tile_iron_d0;
				
			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
				return oldTileType + 1;
				
			case CMap::tile_iron_d8:
				return CMap::tile_empty;
				
			case CMap::tile_glass:
				return CMap::tile_glass_d0;
				
			case CMap::tile_glass_d0:
				return CMap::tile_empty;
		}
	}
	
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if(map.getTile(index).type > 255)
	{
		u32 id = tile_new;
		
		map.SetTileSupport(index, 10);
		
		// print("Set - Old: " + tile_old + "; New: " + tile_new);
		
		switch(tile_new)
		{		
			case CMap::tile_iron:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
						
			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:	
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
			case CMap::tile_iron_d8:
				OnIronTileHit(map, index);
				break;
				
			case CMap::tile_glass:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_glass_d0:
				OnGlassTileHit(map, index);
				break;
		}
	}
}

void OnIronTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
		sparks(pos, 1, 1);
	}
}

void OnGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
		// sparks(pos, 1, 1);
	}
}