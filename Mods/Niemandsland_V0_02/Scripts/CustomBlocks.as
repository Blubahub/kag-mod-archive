
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace rot_mapcolours
{
	enum CustomTiles
	{
        kamp              = 0xFFD3BEFF,
		kiln              = 0xFFD369FF
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
    switch (pixel.color)
    {
        case rot_mapcolours::kamp: spawnBlob(map, "kamp", offset, -1); break;
        case rot_mapcolours::kiln: spawnBlob(map, "kiln", offset, -1); break;
    }
}