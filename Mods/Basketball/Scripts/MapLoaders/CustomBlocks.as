/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */
#include "Logging.as"

const SColor color_basketball(0xFFF16639); // ARGB(255,241,102,57);
const SColor color_basketball_hoop(0xFF00EE00); // ARGB(255,0,238,0);
const SColor color_migrant(0xFF123456); // ARGB(18,52,86);
const SColor color_tradingpost_1(0xff8888ff); // easier to handle these here than use TDM png loader
const SColor color_tradingpost_2(0xffff8888);

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_whatever = 300
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
    if (pixel == color_basketball) {
        log("HandleCustomTile", "Called for basketball");
        spawnBlob(map, "basketball", offset, -1);
        PlaceMostLikelyTile(map, offset);
    }
    else if (pixel == color_basketball_hoop) {
        log("HandleCustomTile", "Called for basketball hoop");
        spawnBlob(map, "basketballhoop", offset, -1);
        PlaceMostLikelyTile(map, offset);
    }
    else if (pixel == color_migrant) {
        log("HandleCustomTile", "Called for migrant");
        spawnBlob(map, "migrant", offset, -1);
        PlaceMostLikelyTile(map, offset);
    }
    else if (pixel == color_tradingpost_1) {
        log("HandleCustomTile", "Called for trading post 1");
        spawnBlob(map, "tradingpost", offset, 0);
        PlaceMostLikelyTile(map, offset);
    }
    else if (pixel == color_tradingpost_2) {
        log("HandleCustomTile", "Called for trading post 2");
        spawnBlob(map, "tradingpost", offset, 1);
        PlaceMostLikelyTile(map, offset);
    }
}
