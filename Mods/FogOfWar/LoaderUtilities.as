// LoaderUtilities.as

#include "DummyCommon.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

/*
TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
}
*/

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
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

	if (getGameTime() < 1 || getRules().hasTag("map is loading"))
	{
		return;
	}

	if (getNet().isClient())
	{
		return;
	}

	CRules@ rules = getRules();
    
	uint[] tiles_to_check;
	getMap().get("tiles to check", tiles_to_check);

	CBitStream stream;
	stream.write_u32(index);

    switch (tile_new)
    {
        case (CMap::tile_ground_back):
        case (CMap::tile_castle_back):
        case (CMap::tile_castle_back_moss):
        case (CMap::tile_wood_back):
        case (CMap::tile_ladder_ground):
        case (CMap::tile_ladder_castle):
        case (CMap::tile_ladder_wood):
			rules.SendCommand(rules.getCommandID("add tile"), stream);
			break;

        default:
			rules.SendCommand(rules.getCommandID("remove tile"), stream);
			break;
    }

	CBitStream _stream;

	rules.SendCommand(rules.getCommandID("get rooms"), _stream);
}