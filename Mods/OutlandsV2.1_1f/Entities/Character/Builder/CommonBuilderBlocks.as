
#include "BuildBlock.as";
#include "Requirements.as";
#include "CustomBlocks.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	AddIconToken("$dirt_block$", "World.png", Vec2f(8, 8), CMap::tile_ground);
	AddIconToken("$goldenblock$", "World.png", Vec2f(8, 8), CMap::tile_goldenblock);
	AddIconToken("$bluegoldenblock$", "World.png", Vec2f(8, 8), CMap::tile_bluegoldenblock);
	AddIconToken("$mixedgoldenblock$", "World.png", Vec2f(8, 8), CMap::tile_mixedgoldenblock);
	AddIconToken("$atm$", "ATM.png", Vec2f(32, 16), 0);
	AddIconToken("$mixer$", "Mixer.png", Vec2f(16, 16), 7);
	AddIconToken("$duplicator$", "Duplicator.png", Vec2f(40, 24), 0);
	AddIconToken("$upgrader$", "Upgrader.png", Vec2f(40, 24), 0);
	AddIconToken("$table$", "Table.png", Vec2f(8, 8), 0);
	AddIconToken("$chair$", "Chair.png", Vec2f(8, 8), 0);
	AddIconToken("$stonetriangle$", "StoneTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$woodentriangle$", "WoodenTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$goldentriangle$", "GoldenTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$bluegoldentriangle$", "BlueGoldenTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$cdoor$", "CDoor.png", Vec2f(16, 8), 0);
	AddIconToken("$csdoor$", "CSDoor.png", Vec2f(16, 8), 0);
	AddIconToken("$cgdoor$", "CGDoor.png", Vec2f(16, 8), 0);
	
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "cdoor", "$cdoor$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "csdoor", "$csdoor$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "cgdoor", "$cgdoor$", "Golden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stonetriangle", "$stonetriangle$", "Stone Triangle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "woodentriangle", "$woodentriangle$", "Wooden Triangle");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "goldentriangle", "$goldentriangle$", "Golden Triangle");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "bluegoldentriangle", "$bluegoldentriangle$", "Blue Golden Triangle");
		AddRequirement(b.reqs, "blob", "mat_bluegold", "Blue Gold", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "chair", "$chair$", "Chair");
		AddRequirement(b.reqs, "blob", "mat_wood", "wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "table", "$table$", "Table");
		AddRequirement(b.reqs, "blob", "mat_wood", "wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_goldenblock, "goldenblock", "$goldenblock$", "Golden Block from normal gold");
		AddRequirement(b.reqs, "blob", "mat_gold", "gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bluegoldenblock, "bluegoldenblock", "$bluegoldenblock$", "Golden Block from blue gold");
		AddRequirement(b.reqs, "blob", "mat_bluegold", "blue gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_mixedgoldenblock, "mixedgoldenblock", "$mixedgoldenblock$", "Reinforced Golden Block");
		AddRequirement(b.reqs, "blob", "mat_mixedgold", "mixed gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground, "dirt_block", "$dirt_block$", "Dirt\nFor planting.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[0].push_back(b);
	}
	

	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 20);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		blocks[1].push_back(b);
	}
	BuildBlock[] page_2;
	blocks.push_back(page_2);
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "atm", "$atm$", "ATM\nYou can trade your materials\nin to coins, and back.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 50);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "mixer", "$mixer$", "Mixer\nYou can mix gold to reinforce it.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 80);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 20);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "duplicator", "$duplicator$", "Duplicator\nYou can multiply materials with magic.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_puremagic", "Pure Magic", 20);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "upgrader", "$upgrader$", "Upgrader\nYou can upgrade stuff.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 80);
		AddRequirement(b.reqs, "blob", "mat_masterstone", "Master Stone", 120);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
}