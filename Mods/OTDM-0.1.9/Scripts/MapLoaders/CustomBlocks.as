
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

const SColor color_tile_brick(255, 85, 5, 35);

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_brick = 232
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == color_tile_brick){
		map.SetTile(offset, CMap::tile_brick );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );		
	}
	//change this in your mod
}