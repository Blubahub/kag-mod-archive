#include "LoaderUtilities.as";
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */
/*
namespace CMap
{
	enum CustomTiles
	{
		tile_customblockhelper = 7,
		tile_goldenblock = 160,
		tile_goldenblock_d0,
		tile_goldenblock_d1,
		tile_goldenblock_d2,
		tile_goldenblock_d3,
		tile_bluegoldore = 240,
		tile_bluegoldore_d0,
		tile_bluegoldore_d1,
		tile_bluegoldore_d2,
		tile_bluegoldore_d3,
		tile_bluegoldore_d4,
		tile_bluegoldenblock = 246,
		tile_bluegoldenblock_d0,
		tile_bluegoldenblock_d1,
		tile_bluegoldenblock_d2,
		tile_bluegoldenblock_d3,
		tile_mixedgoldenblock = 251,
		tile_mixedgoldenblock_d0,
		tile_mixedgoldenblock_d1,
		tile_mixedgoldenblock_d2,
		tile_mixedgoldenblock_d3
	};
};*/

const SColor color_customblockhelper(255, 255, 210, 191);
const SColor color_bluegoldore(255, 2, 90, 200);
const SColor color_masterore(255, 226, 27, 17);
const SColor color_magicore(255, 255, 104, 172);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == color_customblockhelper)
	{ 										
		map.SetTile(offset, CMap::tile_customblockhelper ); 
		map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
		map.AddTileFlag( offset, Tile::BACKGROUND );
	}
	else if (pixel == color_bluegoldore)
	{ 										
		map.SetTile(offset, 261 + XORRandom(4) );
	}
	else if (pixel == color_masterore)
	{ 										
		map.SetTile(offset, 281 + XORRandom(3) );
	}
	else if (pixel == color_magicore)
	{ 										
		map.SetTile(offset, 288 );
	}
}