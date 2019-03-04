
namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_whatever = 300
	};
};

const SColor color_ruin(0xff808000);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if(color_ruin == pixel){
		server_CreateBlob("ruins", -1, getMap().getTileWorldPosition(offset));
	}
}