
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

const SColor color_tile_grass2(255, 0, 225, 85);
const SColor color_tile_metal2(255, 85, 5, 65);
const SColor color_tile_metal3(255, 85, 5, 95);

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_grass2 = 232,
		tile_metal2 = 233,
		tile_metal3 = 234
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == color_tile_grass2){
		map.SetTile(offset, CMap::tile_grass2 );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );	
	}
	if (pixel == color_tile_metal2){
		map.SetTile(offset, CMap::tile_metal2 );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
	}
	if (pixel == color_tile_metal3){
		map.SetTile(offset, CMap::tile_metal3 );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
	}
	//change this in your mod
}