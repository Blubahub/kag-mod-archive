
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_archerblock = 300,
		tile_switch = 301
	};
};

namespace map_colors
{
	enum CustomColors
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_archerblock = 0xFF000000,
		tile_switch = 0xFF000100
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == map_colors::tile_archerblock)
	{
        map.SetTile(offset, CMap::tile_archerblock );
        //map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION);
    }
	else if (pixel == map_colors::tile_switch)
	{
		map.SetTile(offset, CMap::tile_switch );
        //map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION);
	}
}
