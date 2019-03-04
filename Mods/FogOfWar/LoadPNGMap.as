// loads a classic KAG .PNG map
// fileName is "" on client!

#include "BasePNGLoader.as";

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING PNG MAP " + fileName);

	getRules().Tag("map is loading");

	PNGLoader loader();

	return loader.loadMap(map, fileName);
}
