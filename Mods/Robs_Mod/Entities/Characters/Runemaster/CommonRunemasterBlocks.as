// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as";
#include "Requirements.as";
#include "RuneIcons.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	CRules@ rules = getRules();
	const bool CTF = rules.gamemode_name == "CTF";
	const bool TTH = rules.gamemode_name == "TTH";
	const bool SBX = rules.gamemode_name == "Sandbox";

	getRuneIcons();
	
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(0, "touchrune", "$touchrune$", "Rune: Touch\nActivates on touch");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "sightrune", "$sightrune$", "Rune: Sight\nActivates on sight");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "witnessrune", "$witnessrune$", "Holy Rune: Witness\nActivates on far sight");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "curserune", "$curserune$", "Evil Rune: Curse\nActivates and sticks on touch");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	
	{
		BuildBlock b(0, "firerune", "$firerune$", "Rune: Flame\nHOTHOTHOT");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "waterrune", "$waterrune$", "Rune: Drop\nCan't... breathe...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "earthrune", "$earthrune$", "Rune: Rock\nSo... heavy...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "airrune", "$airrune$", "Rune: Wind\nNothing");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	
	{
		BuildBlock b(0, "fleshrune", "$fleshrune$", "Rune: Flesh\nSo, alive");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "plantrune", "$plantrune$", "Rune: Timber\nSo, normal");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "consumerune", "$consumerune$", "Rune: Devour\nEat...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "growrune", "$growrune$", "Rune: Nourish\nGrow...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	/*
	{
		BuildBlock b(0, "polyrune", "$polyrune$", "Rune: Change\nConstantly morphing");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "telerune", "$telerune$", "Rune: Move\nConstantly shifting");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "negrune", "$negrune$", "Rune: Order\nInforcing");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "chaosrune", "$chaosrune$", "Rune: Chaos\nDefying...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	*/
	
	{
		BuildBlock b(0, "lightrune", "$lightrune$", "Holy Rune: Light\nSo bright...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "liferune", "$liferune$", "Holy Rune: Life\nFeels good...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "hasterune", "$hasterune$", "Holy Rune: Quick\nFast and speedy");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "curerune", "$curerune$", "Holy Rune: Cleanse\nCured and cleaned");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	
	{
		BuildBlock b(0, "darkrune", "$darkrune$", "Evil Rune: Dark\nSo dark...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "deathrune", "$deathrune$", "Evil Rune: Death\nFeels cold...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "slowrune", "$slowrune$", "Evil Rune: Slow\nTake... your... time...");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "infectrune", "$infectrune$", "Evil Rune: Plague\nGross and infectious");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}

}