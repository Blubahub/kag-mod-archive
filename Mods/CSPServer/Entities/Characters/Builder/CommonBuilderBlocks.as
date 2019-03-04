// CommonBuilderBlocks.as

#include "BuildBlock.as";
#include "Requirements.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[]@ blocks)
{
	{   // stone_block
		BuildBlock b( CMap::tile_castle, "stone_block", "$stone_block$",
						"Stone Block\nBasic building block" );
		//AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 10 );
		blocks.push_back( b );
	}
	{   // back_stone_block
		BuildBlock b( CMap::tile_castle_back, "back_stone_block", "$back_stone_block$",
						"Back Stone Wall\nExtra support" );
		//AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 2 );
		blocks.push_back( b );
	}
	{   // stone_door
		BuildBlock b( 0, "stone_door", "$stone_door$",
						"Stone Door\nPlace next to walls" );
		//AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 50 );
		blocks.push_back( b );
	}
	{   // spikes
		BuildBlock b( 0, "spikes", "$spikes$",
						"Spikes\nPlace on Stone Block\nfor Retracting Trap" );
		//AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 30 );
		blocks.push_back( b );
	}
	{   // trap
		BuildBlock b( 0, "trap_block", "$trap_block$",
						"Trap Block\nOnly enemies can pass" );
		//AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 25 );
		blocks.push_back( b );
	}

	{   // wood_block
		BuildBlock b( CMap::tile_wood, "wood_block", "$wood_block$",
						"Wood Block\nCheap block\nwatch out for fire!" );
		//AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks.push_back( b );
	}
	{   // back_wood_block
		BuildBlock b( CMap::tile_wood_back, "back_wood_block", "$back_wood_block$",
						"Back Wood Wall\nCheap extra support" );
		//AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 2 );
		blocks.push_back( b );
	}
	{   // wooden_door
		BuildBlock b( 0, "wooden_door", "$wooden_door$",
						"Wooden Door\nPlace next to walls" );
		//AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 30 );
		blocks.push_back( b );
	}
	{   // ladder
		BuildBlock b( 0, "ladder", "$ladder$",
						"Ladder\nAnyone can climb it" );
		//AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks.push_back( b );
	}
	{   // platform
		BuildBlock b( 0, "wooden_platform", "$wooden_platform$",
						"Wooden Platform\nOne way platform" );
		//AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 15 );
		blocks.push_back( b );
	}

	// COMPONENTS
	{   // wire
		BuildBlock b(0, "wire", "$wire$", "Wire" );
		blocks.push_back(b);
	}
	{   // junction
		BuildBlock b(0, "junction", "$junction$", "Junction" );
		blocks.push_back(b);
	}
	{   // diode
		BuildBlock b(0, "diode", "$diode$", "Diode" );
		blocks.push_back(b);
	}
	{   // resistor
		BuildBlock b(0, "resistor", "$resistor$", "Resistor" );
		blocks.push_back(b);
	}
	{   // inverter
		BuildBlock b(0, "inverter", "$inverter$", "Inverter" );
		blocks.push_back(b);
	}
	{   // oscillator
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator" );
		blocks.push_back(b);
	}
	{   // transistor
		BuildBlock b(0, "transistor", "$transistor$", "Transistor" );
		blocks.push_back(b);
	}
	{   // toggle
		BuildBlock b(0, "toggle", "$toggle$", "Toggle" );
		blocks.push_back(b);
	}
	{   // randomizer
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer" );
		blocks.push_back(b);
	}
	{   // emitter
		BuildBlock b(0, "emitter", "$emitter$", "Emitter" );
		blocks.push_back(b);
	}
	{   // receiver
		BuildBlock b(0, "receiver", "$receiver$", "Receiver" );
		blocks.push_back(b);
	}

	// SOURCE
	{    // coin slot
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot" );
		blocks.push_back(b);
	}
	{   // lever
		BuildBlock b(0, "lever", "$lever$", "Lever" );
		blocks.push_back(b);
	}
	{   // push button
		BuildBlock b(0, "push_button", "$pushbutton$", "Button" );
		blocks.push_back(b);
	}
	{   // pressure plate
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate" );
		blocks.push_back(b);
	}

	// LOAD
	{   // lamp
		BuildBlock b(0, "lamp", "$lamp$", "Lamp" );
		blocks.push_back(b);
	}
	{   // magazine
		BuildBlock b(0, "magazine", "$magazine$", "Magazine" );
		blocks.push_back(b);
	}
	{   // bolter
		BuildBlock b(0, "bolter", "$bolter$", "Bolter" );
		blocks.push_back(b);
	}
	{   // dispenser
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser" );
		blocks.push_back(b);
	}
	{   // obstructor
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor" );
		blocks.push_back(b);
	}
	{   // spiker
		BuildBlock b(0, "spiker", "$spiker$", "Spiker" );
		blocks.push_back(b);
	}
}