
#include "BuildBlock.as"
#include "Requirements.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	CRules@ rules = getRules();
	const bool CTF = rules.gamemode_name == "CTF";
	const bool TTH = rules.gamemode_name == "TTH";
	const bool SBX = rules.gamemode_name == "Sandbox";

	BuildBlock[] page_0;
	blocks.push_back(page_0);

	{   // stone_block
		BuildBlock b( CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 10 );
		blocks[0].push_back(b);
	}
	{   // back_stone_block
		BuildBlock b( CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 2 );
		blocks[0].push_back(b);
	}
	{   // stone_door
		BuildBlock b( 0, "stone_door", "$stone_door$", "Stone Door" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 50 );
		blocks[0].push_back(b);
	}    

	{   // wood_block
		BuildBlock b( CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks[0].push_back(b);
	}
	{   // back_wood_block
		BuildBlock b( CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 2 );
		blocks[0].push_back(b);
	}
	{   // wooden_door
		BuildBlock b( 0, "wooden_door", "$wooden_door$", "Wooden Door" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 30 );
		blocks[0].push_back(b);
	}

	{   // trap
		BuildBlock b( 0, "trap_block", "$trap_block$", "Trap Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 25 );
		blocks[0].push_back(b);
	}	
	{   // trap
	    AddIconToken( "$trap_block2$", "trap_block2.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "trap_block2", "$trap_block2$", "Stone Trap Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 45 );
		blocks[0].push_back(b);
	}
	{   // trap
	    AddIconToken( "$trap_block3$", "trap_block3.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "trap_block3", "$trap_block3$", "Hidden Trap Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 45 );
		blocks[0].push_back(b);
	}
	{   // ladder
		BuildBlock b( 0, "ladder", "$ladder$", "Ladder" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks[0].push_back(b);
	}
	
	{   // spikes
		BuildBlock b( 0, "spikes", "$spikes$", "Spikes" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 30 );
		blocks[0].push_back(b);
	}
	{   
		AddIconToken( "$triangle$", "triangle.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "triangle", "$triangle$", "Triangle" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 25 );
		blocks[0].push_back(b);
	}
	{   // platform
		BuildBlock b( 0, "wooden_platform", "$wooden_platform$", "Wooden Platform" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 20 );
		blocks[0].push_back(b);
	}
	
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		blocks[0].push_back(b);
		//b.size.Set(40, 24);
		//blocks[0].insertAt(9, b);
	}
	
}
