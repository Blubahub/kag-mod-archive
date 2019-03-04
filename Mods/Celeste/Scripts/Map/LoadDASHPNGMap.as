// loads a classic KAG .PNG map
// fileName is "" on client!

#include "BasePNGLoader.as";
#include "CustomBlocks.as";

namespace dash_colors
{
	enum color
	{
		color_test_block = 0xFFFF58c4
	};
}

class DASHPNGLoader : PNGLoader
{
	DASHPNGLoader()
	{
		super();
	}

	void handlePixel(const SColor &in pixel, int offset) override
	{
		PNGLoader::handlePixel(pixel, offset);

		switch (pixel.color)
		{
			case dash_colors::color_test_block:
			{
				print("loaded block");
				map.SetTile(offset, CMap::tile_testblock);
				break;
			}
		};
	}
}


bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING PNG MAP " + fileName);

	PNGLoader loader();

	return loader.loadMap(map, fileName);
}
