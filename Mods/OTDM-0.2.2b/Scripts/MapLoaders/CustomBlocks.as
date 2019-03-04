
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

const SColor color_tile_metal(255, 85, 5, 35);
const SColor color_tile_metal2(255, 85, 5, 65);
const SColor color_tile_metal3(255, 85, 5, 95);

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_metal = 232,
		tile_metal2 = 233,
		tile_metal3 = 234
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == color_tile_metal){
		map.SetTile(offset, CMap::tile_metal );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );		
	}
	if (pixel == color_tile_metal2){
		map.SetTile(offset, CMap::tile_metal2 );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );		
	}
	if (pixel == color_tile_metal3){
		map.SetTile(offset, CMap::tile_metal3 );
		//map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE ); I want these 3 tiles to be always visible, so they are LIGHT_SOURCE
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );		
	}
	//change this in your mod
}