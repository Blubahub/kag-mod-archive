
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
		tile_ground           	   = 0xFF844715, // ARGB(255, 132, 71, 21);

		// SPAWNS
		humans_spawn_main		   = 0xFF39AADE, // ARGB(255, 57, 170, 222);
		orcs_spawn_main  		   = 0xFFCE163B, // ARGB(255, 206, 22, 59);
		elves_spawn_main 		   = 0xFF07D911, // ARGB(255, 7, 217, 7);
		dwarfs_spawn_main		   = 0xFF920FF7  // ARGB(255, 146, 15, 247);

		//OTHER

	}
}

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	switch (pixel.color)
	{
		case rp_mapcolors::humans_spawn_main:		AddMarker(map,offset,"HumanMainSpawn"); break;
		case rp_mapcolors::orcs_spawn_main:			AddMarker(map,offset,"OrcMainSpawn");   break;
		case rp_mapcolors::elves_spawn_main:		AddMarker(map,offset,"ElveMainSpawn");  break;
		case rp_mapcolors::dwarfs_spawn_main:		AddMarker(map,offset,"DwarfMainSpawn"); break;

	}
}