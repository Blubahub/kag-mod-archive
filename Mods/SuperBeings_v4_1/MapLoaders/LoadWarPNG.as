// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "WAR_Technology.as";

const SColor color_hall(255, 211, 249, 193);

const SColor color_tradingpost_1(0xff8888ff);
const SColor color_tradingpost_2(0xffff8888);

const SColor color_mechhall(0xffffbe0a);
const SColor color_blackmarket(0xff130d1d);
const SColor color_ruin(0xff808000);


//the loader

class WarPNGLoader : PNGLoader
{

	WarPNGLoader()
	{
		super();
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
		else if (pixel == color_blue_main_spawn)
		{
			CBlob@ hall = spawnBlob(map, "hall", offset, 0);
			if (hall !is null) // add research to first hall
			{
				hall.AddScript("Researching.as");
				hall.Tag("script added");
			}
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_red_main_spawn)
		{
			CBlob@ hall = spawnBlob(map, "hall", offset, 1);
			if (hall !is null) // add research to first hall
			{
				hall.AddScript("Researching.as");
				hall.Tag("script added");
			}
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_mechhall){
			CBlob@ hall = spawnBlob(map, "mechanicshall", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_blackmarket){
			CBlob@ hall = spawnBlob(map, "blackmarket", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_ruin)
		{
			CBlob@ ruins = spawnBlob(map, "ruins", offset, -1);
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
