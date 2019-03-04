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

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	CRules@ rules = getRules();
	const bool CTF = rules.gamemode_name == "CTF";
	const bool TTH = rules.gamemode_name == "TTH";
	const bool SBX = true;

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
		blocks[0].push_back(b);
	}
  {
    AddIconToken("$stone_moss_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_moss);
    BuildBlock b( CMap::tile_castle_moss, "stone_moss_block", "$stone_moss_block$", "Mossy Stone Block" );
    AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
    blocks[0].push_back( b );
  }
  {
    AddIconToken("$back_stone_moss_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_back_moss);
    BuildBlock b( CMap::tile_castle_back_moss, "back_stone_moss_block", "$back_stone_moss_block$", "Mossy Back Stone Wall" );
    AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
    blocks[0].push_back( b );
  }
	
	{
		AddIconToken("$ground$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_ground);
		BuildBlock b( CMap::tile_ground, "ground", "$ground$", "Dirt" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
		blocks[0].push_back( b );
	}
	/*
	{
		AddIconToken("$grass$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_grass);
		BuildBlock b( CMap::tile_grass, "grass", "$grass$", "Grass" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
		blocks[0].push_back( b );
	}
	{
		AddIconToken( "$flowers$", "Flowers.png", Vec2f(16,16), 6);
		BuildBlock b( 0, "flowers", "$flowers$", "Flowers" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
		blocks[0].push_back( b );
	}
	{
		AddIconToken( "$bush$", "Bush.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "bush", "$bush$", "Bush" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
		blocks[0].push_back( b );
	}*/
	if(SBX)
	{
		{
			BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[0].insertAt(9, b);
		}

		BuildBlock[] page_1;
		blocks.push_back(page_1);
		{
			BuildBlock b(0, "wire", "$wire$", "Wire");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "elbow", "$elbow$", "Elbow");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "tee", "$tee$", "Tee");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "junction", "$junction$", "Junction");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "diode", "$diode$", "Diode");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "resistor", "$resistor$", "Resistor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "inverter", "$inverter$", "Inverter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "transistor", "$transistor$", "Transistor");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "toggle", "$toggle$", "Toggle");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[1].push_back(b);
		}

		BuildBlock[] page_2;
		blocks.push_back(page_2);
		{
			BuildBlock b(0, "lever", "$lever$", "Lever");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "push_button", "$pushbutton$", "Button");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}

		BuildBlock[] page_3;
		blocks.push_back(page_3);
		{
			BuildBlock b(0, "lamp", "$lamp$", "Lamp");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "colorlamp", "$colorlamp$", "Team Colored Lamp");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "emitter", "$emitter$", "Emitter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "receiver", "$receiver$", "Receiver");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "magazine", "$magazine$", "Magazine");
			AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 0);
			blocks[3].push_back(b);
		}
		{
			AddIconToken( "$infinitemagazineinventory$", "Magazine.png", Vec2f(8,8), 2);
			BuildBlock b(0, "infinitemagazine", "$infinitemagazineinventory$", "Infinite Magazine");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "bolter", "$bolter$", "Bolter");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "spiker", "$spiker$", "Spiker");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
    {
			AddIconToken( "$conveyor$", "Conveyor.png", Vec2f(8,8), 0);
			BuildBlock b(0, "conveyor", "$conveyor$", "Conveyor");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
	    {
			AddIconToken( "$booster$", "Booster.png", Vec2f(8,8), 0);
			BuildBlock b(0, "booster", "$booster$", "Booster");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
    {

			AddIconToken( "$conveyortriangle$", "ConveyorTriangle.png", Vec2f(8,8), 0);
			BuildBlock b(0, "conveyortriangle", "$conveyortriangle$", "Conveyor Triangle");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
    {
			AddIconToken( "$lifter$", "Lifter.png", Vec2f(8,8), 0);
			BuildBlock b(0, "lifter", "$lifter$", "Lifter");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[3].push_back(b);
		}
    BuildBlock[] page_4;
		blocks.push_back(page_4);
    {
      AddIconToken( "$rwood_block$", "ReinforcedWood.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "reinforced_wood", "$rwood_block$", "Reinforced Wood Block" );
      AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
      AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
      blocks[4].push_back( b );
	  }
	  {
      AddIconToken( "$rwooden_door$", "ReinforcedSwingDoor.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "rwooden_door", "$rwooden_door$", "Reinforced Wooden Door" );
      AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
      AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
      blocks[4].push_back( b );
	  }
    {
      AddIconToken( "$team_bridge$", "TeamBridge.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "team_bridge", "$team_bridge$", "Team Bridge" );
      AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
      blocks[4].push_back( b );
	  }
    {
      AddIconToken( "$chair$", "Chair.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "chair", "$chair$", "Chair" );
      AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$wtriangle$", "WoodenTriangle.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "wood_triangle", "$wtriangle$", "Wooden Triangle" );
      AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$rwtriangle$", "ReinforcedWoodenTriangle.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "rwood_triangle", "$rwtriangle$", "Reinforced Wooden Triangle" );
      AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 0 );
      AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$triangle$", "Triangle.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "triangle", "$triangle$", "Stone Triangle" );
      AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$triangle2$", "Triangle2.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "triangle2", "$triangle2$", "Stone Triangle 2" );
      AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$triangle3$", "Triangle3.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "triangle3", "$triangle3$", "Stone Triangle 3" );
      AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$gtriangle$", "GoldenTriangle.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "gold_triangle", "$gtriangle$", "Golden Triangle" );
      AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$gtriangle2$", "GoldenTriangle2.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "gold_triangle2", "$gtriangle2$", "Golden Triangle 2" );
      AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$gtriangle3$", "GoldenTriangle3.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "gold_triangle3", "$gtriangle3$", "Golden Triangle 3" );
      AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$goldbrick$", "goldbrick.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "GoldBrick", "$goldbrick$", "Gold Brick" );
      AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$gold_door$", "GoldDoor.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "gold_door", "$gold_door$", "Gold Door" );
      AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 0 );
      blocks[4].push_back( b );
    }
    {
      AddIconToken( "$ice$", "Ice.png", Vec2f(8,8), 0);
      BuildBlock b( 0, "ice", "$ice$", "Ice Block" );
      AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 0 );
      blocks[4].push_back( b );
    }
	}
}
