#include "BuildBlock.as";
#include "Requirements.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "mageshop", "$mageshop$", "Mage Sanctuary\n Where lesser mages are trained.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		blocks[0].push_back(b);
	}
}