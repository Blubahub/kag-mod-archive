
#include "BasePNGLoader.as";

const SColor color_airlock(0xffFF643C);

const SColor color_room1x1(0xff838383);
const SColor color_room2x1(0xff848484);
const SColor color_room1x2(0xff858585);
const SColor color_room2x2(0xff868686);

const SColor color_reactor(0xffff3737);
const SColor color_pilot_seat(0xffff6414);
const SColor color_oxygen(0xff3264FF);

//the loader

class TDMPNGLoader : PNGLoader
{

	TDMPNGLoader()
	{
		super();
	}

	//override this to extend functionality per-pixel.
	void handlePixel(SColor pixel, int offset)
	{
		PNGLoader::handlePixel(pixel, offset);

		if (pixel == color_airlock)
		{
			spawnBlob(map, "airlock", offset, 0, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_room1x1)
		{
			spawnBlob(map, "onebyoneroom", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_room2x1)
		{
			spawnBlob(map, "twobyoneroom", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_room1x2)
		{
			spawnBlob(map, "onebytworoom", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_room2x2)
		{
			spawnBlob(map, "twobytworoom", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_reactor)
		{
			spawnBlob(map, "reactorroom", offset, 0);
			
			spawnBlob(map, "mat_scrap", offset, 0);
			spawnBlob(map, "mat_scrap", offset, 0);
			spawnBlob(map, "mat_scrap", offset, 0);
			spawnBlob(map, "mat_scrap", offset, 0);
			spawnBlob(map, "mat_scrap", offset, 0);
			
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_pilot_seat)
		{
			spawnBlob(map, "pilots_seat", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_oxygen)
		{
			spawnBlob(map, "oxygen_generator", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		PNGLoader::handleOffset(type, offset, position, count);
	}
};

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING SPACE PNG MAP " + fileName);

	TDMPNGLoader loader();

	return loader.loadMap(map , fileName);
}
