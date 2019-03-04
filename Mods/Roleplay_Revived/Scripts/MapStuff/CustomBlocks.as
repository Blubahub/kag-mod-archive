
#include "BasePNGLoader.as";//needed for adding markers and what not

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_whatever = 300
	};
};


namespace rp_mapcolors
{
	enum color
	{
		// TILES
		tile_ground            = 0xFF844715, // ARGB(255, 132,  71,  21);

		// SPAWNS
		Alliance1Spawn		   = 0xFF39AADE // ARGB(255, 57, 170, 222);

		//OTHER

	}
}

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	switch (pixel.color)
	{
		case rp_mapcolors::Alliance1Spawn:		AddMarker(map,offset,"Alliance1Spawn"); break;
	}
}