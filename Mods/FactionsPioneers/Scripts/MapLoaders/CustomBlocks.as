#include "BasePNGLoader.as"

const SColor color_BlueGold(255, 2, 140, 255);
const SColor color_sparkwood_tree(        0xFF2A0B47); // ARGB(255, 42,  11, 71);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
    if (pixel == color_sparkwood_tree)
    {
        CBlob@ tree = server_CreateBlobNoInit("tree_sparkwood");
        if(tree !is null)
        {
            tree.Tag("startbig");
            tree.setPosition( getSpawnPosition( map, offset ) );
            tree.Init();
            if (map.getTile(offset).type == CMap::tile_empty)
            {
                map.SetTile(offset, CMap::tile_grass + map_random.NextRanged(3) );
            }
        }
    }
	else if (pixel == color_BlueGold)
	{ 										
		CBlob@ BGold = server_CreateBlobNoInit("BlueGold");
        if(BGold !is null)
        {
            BGold.setPosition( getSpawnPosition( map, offset ) );
            BGold.Init();
			if (map.getTile(offset).type == CMap::tile_empty)
            {
                map.SetTile(offset, CMap::tile_ground_back );
            }
        }
	}
}