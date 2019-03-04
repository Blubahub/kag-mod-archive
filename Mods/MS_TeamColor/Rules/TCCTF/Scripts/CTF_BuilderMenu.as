
#include "BuildBlock.as"
#include "CommonBuilderBlocks.as"

#include "WARCosts.as"
//should really make ctf costs at some point.. :)

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (blob !is null && player !is null && blob.getName() == "builder")
	{
		BuildBlock[] blocks;

		addCommonBuilderBlocks(blocks);

		{
			// building
			BuildBlock b(0, "building", "$building$",
			             "Workshop\nStand in an open space\nand tap this button.");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", COST_WOOD_WORKSHOP);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks.insert(blocks.size() - 1, b); //insert so that it's offset on the spikes :)
		}

		blob.set(blocks_property, blocks);
	}
}
