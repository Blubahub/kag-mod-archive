
#include "BuildBlock.as"
#include "Requirements.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks( BuildBlock[]@ blocks )
{
	bool gold_structures = getRules().get_bool("gold_structures");
	{   // stone_block
		BuildBlock b( CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 10 );
		blocks.push_back( b );
	}
	{   // back_stone_block
		BuildBlock b( CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 2 );
		blocks.push_back( b );
	}
	{   // stone_door
		BuildBlock b( 0, "stone_door", "$stone_door$", "Stone Door" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 50 );
		blocks.push_back( b );
	}    

	{   // wood_block
		BuildBlock b( CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks.push_back( b );
	}
	{   // back_wood_block
		BuildBlock b( CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 2 );
		blocks.push_back( b );
	}
	{   // wooden_door
		BuildBlock b( 0, "wooden_door", "$wooden_door$", "Wooden Door" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 30 );
		blocks.push_back( b );
	}

	{   // trap
		BuildBlock b( 0, "trap_block", "$trap_block$", "Trap Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 25 );
		blocks.push_back( b );
	}	
	{   // ladder
		BuildBlock b( 0, "ladder", "$ladder$", "Ladder" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks.push_back( b );
	}
	
	{   // spikes
		BuildBlock b( 0, "spikes", "$spikes$", "Spikes" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 30 );
		blocks.push_back( b );
	}
	{   
		AddIconToken( "$triangle$", "triangle.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "triangle", "$triangle$", "Triangle" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 25 );
		blocks.push_back( b );
	}
	{   // platform
		BuildBlock b( 0, "wooden_platform", "$wooden_platform$", "Wooden Platform" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 20 );
		blocks.push_back( b );
	}
	if (gold_structures)
	{
		{   
			AddIconToken( "$goldbrick$", "goldbrick.png", Vec2f(8,8), 0);
			BuildBlock b( 0, "GoldBrick", "$goldbrick$", "Gold Brick" );
			AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 25 );
			blocks.push_back( b );
		}
		{   
			AddIconToken( "$gold_door$", "1x1GoldDoorIcon.png", Vec2f(10,8), 0);
			BuildBlock b( 0, "gold_door", "$gold_door$", "Gold Door" );
			AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 75 );
			blocks.push_back( b );
		}
	}
}
