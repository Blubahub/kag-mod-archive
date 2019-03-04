// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "WAR_Technology.as";

const SColor color_hall(255, 211, 249, 193);

const SColor color_tradingpost_1(0xff8888ff);
const SColor color_tradingpost_2(0xffff8888);

const SColor color_mechhall(0xffffbe0a);
const SColor color_blackmarket(0xff130d1d);
const SColor color_ruin(0xff808000);


const SColor color_info_desert(0xffffc896);

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
		
		// Map Info
		if (pixel == color_info_desert)
		{
			spawnBlob(map, "info_desert", offset, -1);
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
