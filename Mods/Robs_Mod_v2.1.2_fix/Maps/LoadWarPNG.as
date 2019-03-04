// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "WAR_Technology.as";

const SColor color_hall(255, 211, 249, 193);

const SColor color_tradingpost_1(0xff8888ff);
const SColor color_tradingpost_2(0xffff8888);

const SColor color_mechhall(0xffffbe0a);
const SColor color_blackmarket(0xff130d1d);
const SColor color_zombie(0xff261a3a);

const SColor color_blueprincess(0xff80c8ff);
const SColor color_redprincess(0xffff80C8);

enum Offset
{
	blue_team_scroll = offsets_count,
	red_team_scroll,
	crap_scroll,
	medium_scroll,
	super_scroll,
	war_offsets_count
};


//the loader

class WarPNGLoader : PNGLoader
{

	WarPNGLoader()
	{
		super();

		//add missing offset arrays
		int count = war_offsets_count - offsets_count;
		while (count -- > 0)
		{
			offsets.push_back(array<int>(0));
		}
	}

	//override this to extend functionality per-pixel.
	void handlePixel(SColor pixel, int offset)
	{
		PNGLoader::handlePixel(pixel, offset);

		if (pixel == color_hall)
		{
			spawnBlob(map, "hall", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		// TRADING POST
		else if (pixel == color_tradingpost_1)
		{
			spawnBlob(map, "tradingpost", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_tradingpost_2)
		{
			spawnBlob(map, "tradingpost", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_mechhall){
			CBlob@ hall = spawnBlob(map, "mechanicshall", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}else if (pixel == color_blackmarket){
			CBlob@ hall = spawnBlob(map, "blackmarket", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_zombie)
		{
			CBlob@ zombie = spawnBlob(map, "zombie", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_blueprincess)
		{
			CBlob@ princess = spawnBlob(map, "princess", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_redprincess)
		{
			CBlob@ princess = spawnBlob(map, "princess", offset, 1);
			offsets[autotile_offset].push_back(offset);
		}

	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		PNGLoader::handleOffset(type, offset, position, count);

		const Vec2f pos = getSpawnPosition(map, offset);
	}
}

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING WAR PNG MAP " + fileName);

	WarPNGLoader loader();

	return loader.loadMap(map , fileName);
}
