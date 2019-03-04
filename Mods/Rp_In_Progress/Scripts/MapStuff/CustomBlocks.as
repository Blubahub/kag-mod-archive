#include "Tiles.as";

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	Vec2f pos = map.getTileWorldPosition(offset);
	for(int i = 0; i < Blocks.length; i++)
	{
        BlockInfo @Block = Blocks[i];
		if(pixel == Block.map_color)
		{
			map.SetTileDirt(offset, 0);
			if(Block.name == "grass")
				map.server_SetTile(pos, Block.DefaultTile + map_random.NextRanged(4));
			else
				map.server_SetTile(pos, Block.DefaultTile);
			map.AddTileFlag(offset, Block.flags);
			map.RemoveTileFlag(offset, 65535 ^ (Block.flags));
			map.SetTileDirt(offset, 0);
			return;
		}
	}
}