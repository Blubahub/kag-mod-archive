
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
		/* tile_grassB = 0,
		tile_grassR = 6,
		tile_grassF = 42,
		tile_grassSn = 232,
		tile_grassSa = 245 */
		
		
	/* 			tile_grassB = 0,
		tile_grassB = 1,
		tile_grassB = 2,
		tile_grassB = 3,
		tile_grassB = 4,
		tile_grassB = 5,
		tile_grassR = 6,
		tile_grassR = 7,
		tile_grassR = 8,
		tile_grassR = 9,
		tile_grassR = 10,
		tile_grassR = 11,
		tile_grassF = 42,
		ile_grassF = 43,
		ile_grassF = 44,
		ile_grassF = 45,
		ile_grassF = 46,
		ile_grassF = 47,
		tile_grassSn = 232,
		tile_grassSn = 233,
		tile_grassSn = 234,
		tile_grassSn = 235,
		tile_grassSn = 236,
		tile_grassSn = 237,
		tile_grassSa = 245,
		tile_grassSa = 246,
		tile_grassSa = 247,
		tile_grassSa = 248,
		tile_grassSa = 249,
		tile_grassSa = 250 */
		
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	//change this in your mod
}