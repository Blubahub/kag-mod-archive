// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "BasePNGLoader.as";
//#include "CustomBlocks.as";

namespace CMap
{
	enum CustomTiles
	{
		tile_customblockhelper = 7,
		tile_goldenblock = 256,
		tile_goldenblock_d0,
		tile_goldenblock_d1,
		tile_goldenblock_d2,
		tile_goldenblock_d3,
		tile_bluegoldore_t0 = 261,
		tile_bluegoldore_t1,
		tile_bluegoldore_t2,
		tile_bluegoldore_t3,
		tile_bluegoldore_t4,
		tile_bluegoldore_t5,
		tile_bluegoldenblock = 267,
		tile_bluegoldenblock_d0,
		tile_bluegoldenblock_d1,
		tile_bluegoldenblock_d2,
		tile_bluegoldenblock_d3,
		tile_mixedgoldenblock = 272,
		tile_mixedgoldenblock_d0,
		tile_mixedgoldenblock_d1,
		tile_mixedgoldenblock_d2,
		tile_mixedgoldenblock_d3,
		tile_bluegoldore_d0 = 277,
		tile_bluegoldore_d1,
		tile_bluegoldore_d2,
		tile_bluegoldore_d3,
		tile_masterore_t0 = 281,
		tile_masterore_t1,
		tile_masterore_d0,
		tile_masterore_d1,
		tile_masterore_d2,
		tile_masterore_d3,
		tile_masterore_d4,
		tile_magicore = 288,
		tile_magicore_d0,
		tile_magicore_d1,
		tile_magicore_d2
	};
};

void onInit(CMap@ this)
{
    this.legacyTileMinimap = false; //use for all tiles
    this.MakeMiniMap(); //regenerate here because onInit is called late
}

void CalculateMinimapColour( CMap@ this, u32 offset, TileType tile, SColor &out col)
{
    if (this.isTileSolid(tile) || tile > 255)
	{
		TileType leftside = this.getTile( offset - 1).type;
		TileType rightside = this.getTile( offset + 1).type;
		TileType upside = this.getTile( offset - this.tilemapwidth).type;
		TileType downside = this.getTile( offset + this.tilemapwidth).type;
		if(
		(!this.isTileSolid(leftside) && leftside < 256) ||
		(!this.isTileSolid(rightside) && rightside < 256) ||
		(!this.isTileSolid(upside) && upside < 256) ||
		(!this.isTileSolid(downside) && downside < 256)
		)
		col = SColor(0xff844715);
		else
		col = SColor(0xffC4873A);
	}
	else if (!this.isTileSolid(tile) && tile < 256 && tile != 0)
	{
		TileType leftside = this.getTile( offset - 1).type;
		TileType rightside = this.getTile( offset + 1).type;
		TileType upside = this.getTile( offset - this.tilemapwidth).type;
		TileType downside = this.getTile( offset + this.tilemapwidth).type;
		if(
		(leftside == 0) ||
		(rightside == 0) ||
		(downside == 0) ||
		(upside == 0)
		)
		col = SColor(0xffC4873A);
		else
		col = SColor(0xffF3AC5C);
	}
	else if (this.getTile(offset).type == 0)
	col = SColor(0xffEDCCA6);
}

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	//if(map.getTile(offset).type > 255)
	//{
	//	CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
	//	if(blob !is null)
	//	{
	//		blob.server_Die();
	//	}
	//}
	if((map.getTile(offset).type > 260 && map.getTile(offset).type < 267) || (map.getTile(offset).type > 276 && map.getTile(offset).type < 292))
	{
		return false;
	}
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		//print("Hit - Old: " + oldTileType + "; Index: " + index);
		switch(oldTileType)
		{

				//blue gold ore
			case CMap::tile_bluegoldore_t0:
			case CMap::tile_bluegoldore_t1:
			case CMap::tile_bluegoldore_t2:
			case CMap::tile_bluegoldore_t3:
			case CMap::tile_bluegoldore_t4:
			case CMap::tile_bluegoldore_t5:
			{
				OnGoldTileHit(map, index);
				return CMap::tile_bluegoldore_d0;
			}

			case CMap::tile_bluegoldore_d0:
			case CMap::tile_bluegoldore_d1:
			case CMap::tile_bluegoldore_d2:
			{
				OnGoldTileHit(map, index);
				return oldTileType + 1;
			}

			case CMap::tile_bluegoldore_d3:
			{
				OnGoldTileDestroyed(map, index);
				return CMap::tile_ground_back;
			}

				//blue golden block
			case CMap::tile_bluegoldenblock:
			{
				OnGoldTileHit(map, index);
				return CMap::tile_bluegoldenblock_d0;
			}

			case CMap::tile_bluegoldenblock_d0:
			case CMap::tile_bluegoldenblock_d1:
			case CMap::tile_bluegoldenblock_d2:
			{
				OnGoldTileHit(map, index);
				return oldTileType + 1;
			}

			case CMap::tile_bluegoldenblock_d3:
			{
				OnGoldTileDestroyed(map, index);
				return CMap::tile_empty;
			}

				//mixed golden block
			case CMap::tile_mixedgoldenblock:
			{
				OnGoldTileHit(map, index);
				return CMap::tile_mixedgoldenblock_d0;
			}

			case CMap::tile_mixedgoldenblock_d0:
			case CMap::tile_mixedgoldenblock_d1:
			case CMap::tile_mixedgoldenblock_d2:
			{
				OnGoldTileHit(map, index);
				return oldTileType + 1;
			}

			case CMap::tile_mixedgoldenblock_d3:
			{
				OnGoldTileDestroyed(map, index);
				return CMap::tile_empty;
			}
		
				//golden block
			case CMap::tile_goldenblock:
			{
				OnGoldTileHit(map, index);
				return CMap::tile_goldenblock_d0;
			}
		
			case CMap::tile_goldenblock_d0:
			case CMap::tile_goldenblock_d1:
			case CMap::tile_goldenblock_d2:
			{
				OnGoldTileHit(map, index);
				return oldTileType + 1;
			}
		
			case CMap::tile_goldenblock_d3:
			{
				OnGoldTileDestroyed(map, index);
				return CMap::tile_empty;
			}
			
				//master ore
			case CMap::tile_masterore_t0:
			case CMap::tile_masterore_t1:
			{
				OnGoldTileHit(map, index);
				return CMap::tile_masterore_d0;
			}
		
			case CMap::tile_masterore_d0:
			case CMap::tile_masterore_d1:
			case CMap::tile_masterore_d2:
			case CMap::tile_masterore_d3:
			{
				OnGoldTileHit(map, index);
				return oldTileType + 1;
			}
		
			case CMap::tile_masterore_d4:
			{
				OnStoneTileDestroyed(map, index);
				return CMap::tile_ground_back;
			}
			
				//magic ore
			case CMap::tile_magicore:
			{
				OnMOTileHit(map, index);
				return CMap::tile_magicore_d0;
			}
		
			case CMap::tile_magicore_d0:
			case CMap::tile_magicore_d1:
			{
				OnMOTileHit(map, index);
				return oldTileType + 1;
			}
		
			case CMap::tile_magicore_d2:
			{
				OnMOTileDestroyed(map, index);
				return CMap::tile_ground_back;
			}
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{

	switch(tile_new)
	{
		case CMap::tile_empty:
		map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
		break;
	}

	if (map.getTile(index).type > 255)
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			//case CMap::tile_empty:
			//map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
			//break;

				//blue gold ore
			case CMap::tile_bluegoldore_t0:
			case CMap::tile_bluegoldore_t1:
			case CMap::tile_bluegoldore_t2:
			case CMap::tile_bluegoldore_t3:
			case CMap::tile_bluegoldore_t4:
			case CMap::tile_bluegoldore_t5:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				//map.AddTileFlag(index, Tile::SPARE_0 | Tile::SPARE_2 | Tile::SPARE_3 | Tile::SPARE_4);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

			case CMap::tile_bluegoldore_d0:
			case CMap::tile_bluegoldore_d1:
			case CMap::tile_bluegoldore_d2:
			case CMap::tile_bluegoldore_d3:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

				//blue golden block
			case CMap::tile_bluegoldenblock:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}

			case CMap::tile_bluegoldenblock_d0:
			case CMap::tile_bluegoldenblock_d1:
			case CMap::tile_bluegoldenblock_d2:
			case CMap::tile_bluegoldenblock_d3:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

				//mixed gold block
			case CMap::tile_mixedgoldenblock:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}

			case CMap::tile_mixedgoldenblock_d0:
			case CMap::tile_mixedgoldenblock_d1:
			case CMap::tile_mixedgoldenblock_d2:
			case CMap::tile_mixedgoldenblock_d3:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

				//golden block
			case CMap::tile_goldenblock:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}

			case CMap::tile_goldenblock_d0:
			case CMap::tile_goldenblock_d1:
			case CMap::tile_goldenblock_d2:
			case CMap::tile_goldenblock_d3:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}
			
				//master ore
			case CMap::tile_masterore_t0:
			case CMap::tile_masterore_t1:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

			case CMap::tile_masterore_d0:
			case CMap::tile_masterore_d1:
			case CMap::tile_masterore_d2:
			case CMap::tile_masterore_d3:
			case CMap::tile_masterore_d4:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}
			
				//magic ore
			case CMap::tile_magicore:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

			case CMap::tile_magicore_d0:
			case CMap::tile_magicore_d1:
			case CMap::tile_magicore_d2:
			{
				OnMOTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}
		}
	}
	if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
}

void OnGoldTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND );
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnGoldTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_gold.ogg", pos, 1.0f, 1.0f);
	}
}

void OnStoneTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnMOTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND );
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_dirt.ogg", pos, 1.0f, 1.0f);
	}
}

void OnMOTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_dirt.ogg", pos, 1.0f, 1.0f);
	}
}