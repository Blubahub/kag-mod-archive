// loads a classic KAG .PNG map

// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "MinimapHook.as";

// Custom map colors for challenges
namespace ftl_colors
{
	enum color
	{
		checkpoint    = 0xFFF7E5FD
	};
}

class FTLPNGLoader : PNGLoader
{
	FTLPNGLoader()
	{
		super();
	}

	//override this to extend functionality per-pixel.
	void handlePixel(const SColor &in pixel, int offset) override
	{
		PNGLoader::handlePixel(pixel, offset);

		switch (pixel.color)
		{
		case ftl_colors::checkpoint: AddMarker(map, offset, "checkpoint"); break;
		};
	}
};

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING FTL PNG MAP " + fileName);
	//MiniMap::Initialise();
	return FTLPNGLoader().loadMap(map, fileName);
}
