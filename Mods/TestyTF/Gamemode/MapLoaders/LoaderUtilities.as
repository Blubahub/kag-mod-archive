#include "DummyCommon.as";
#include "ParticleSparks.as";

namespace CMap
{
	enum CustomTiles
	{ 
		tile_iron = 384,
		tile_iron_d0,
		tile_iron_d1,
		tile_iron_d2,
		tile_iron_d3,
		tile_iron_d4,
		tile_iron_d5,
		tile_iron_d6,
		tile_iron_d7,
		tile_iron_d8,
		tile_glass = 394,
		tile_glass_d0,
		tile_plasteel = 396,
		tile_plasteel_d0,
		tile_plasteel_d1,
		tile_plasteel_d2,
		tile_plasteel_d3,
		tile_plasteel_d4,
		tile_plasteel_d5,
		tile_plasteel_d6,
		tile_plasteel_d7,
		tile_plasteel_d8,
		tile_plasteel_d9,
		tile_plasteel_d10,
		tile_plasteel_d11,
		tile_plasteel_d12,
		tile_plasteel_d13,
		tile_plasteel_d14,
		tile_matter = 412,
		tile_matter_d0,
		tile_matter_d1,
		tile_matter_d2,
		tile_brick_v0 = 416,
		tile_brick_v1,
		tile_brick_v2,
		tile_brick_v3,
		tile_brick_d0,
		tile_brick_d1,
		tile_brick_d2,
		tile_brick_d3,
		tile_brick_d4,
		tile_brick_d5,
		tile_brick_d6,
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
				
				
			case CMap::tile_plasteel:
				return CMap::tile_plasteel_d0;
				
			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
				return oldTileType + 1;
				
			case CMap::tile_plasteel_d14:
				return CMap::tile_empty;
				
			case CMap::tile_matter:
				return CMap::tile_matter_d0;
				
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
				return oldTileType + 1;
				
			case CMap::tile_matter_d2:
				return CMap::tile_empty;
				
			case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				return CMap::tile_brick_d0;
				
			case CMap::tile_brick_d0:
			case CMap::tile_brick_d1:
			case CMap::tile_brick_d2:
			case CMap::tile_brick_d3:
			case CMap::tile_brick_d4:
			case CMap::tile_brick_d5:
				return oldTileType + 1;
				
			case CMap::tile_brick_d6:
				return CMap::tile_empty;
		}
	}
	
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if (tile_new == CMap::tile_ground && getNet().isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

	if (map.getTile(index).type > 255)
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
				
			case CMap::tile_plasteel:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
						
			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
			case CMap::tile_plasteel_d14:
				OnPlasteelTileHit(map, index);
				break;
				
			case CMap::tile_matter:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
			case CMap::tile_matter_d2:
				OnMatterTileHit(map, index);
				break;
				
			case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_brick_d0:
			case CMap::tile_brick_d1:
			case CMap::tile_brick_d2:
			case CMap::tile_brick_d3:
			case CMap::tile_brick_d4:
			case CMap::tile_brick_d5:
			case CMap::tile_brick_d6:
				OnBrickTileHit(map, index);
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

void OnPlasteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}

void OnMatterTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_stone.ogg", pos, 0.8f, 1.2f);
		// sparks(pos, 1, 1);
	}
}

void OnBrickTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}