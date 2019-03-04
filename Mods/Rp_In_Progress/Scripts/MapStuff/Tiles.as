// tile flags
/*
	Tile::SPARE_0			= 1
	Tile::SOLID				= 4
	Tile::BACKGROUND		= 2
	Tile::LADDER			= 8
	Tile::LIGHT_PASSES		= 16
	Tile::WATER_PASSES		= 32
	Tile::FLAMMABLE			= 64
	Tile::PLATFORM			= 128
	Tile::LIGHT_SOURCE		= 256
	Tile::MIRROR			= 512
	Tile::FLIP				= 1024
	Tile::ROTATE			= 2048
	Tile::COLLISION			= 4096
	Tile::SPARE_2			= 8192			collapsing
	Tile::SPARE_3			= 16384			dont update nearest
	Tile::SPARE_4			= 32768
*/
// tile flags end

// background   0000 0000 0001 0100
// solid        0001 0000 0000 0010

//#include "FallingTiles.as"

int64[] positions;

namespace CMap
{
	enum CustomTiles
	{
		tile_dirt = 1,
		tile_dirt_v1,
		tile_dirt_v2,
		tile_dirt_d1,
		tile_dirt_d2,
		tile_dirt_d3,
		tile_dirtbackground,
		tile_dirtbackground_v1,
		tile_dirtbackground_v2,
		tile_dirtbackground_v3,
		tile_dirtbackground_v4,
		tile_dirtbackground_v5,
		tile_dirtbackground_v6,
		tile_dirtbackground_v7,
		tile_dirtbackground_v8,
		tile_dirtbackground_v9,
		tile_dirtbackground_v10,
		tile_dirtbackground_v11,
		tile_dirtbackground_v12,
		tile_dirtbackground_v13,
		tile_dirtbackground_v14,
		tile_dirtbackground_v15,
		tile_dirtbackground_v16,
		tile_dirtbackground_v17,
		tile_dirtbackground_v18,
		tile_dirtbackground_v19,
		tile_paper,
		tile_paper_v1,
		tile_paper_v2,
		tile_paper_v3,
		tile_paper_d1,
		tile_leftover,				//some wierd spot
		tile_stonewall,
		tile_stonewall_v1,
		tile_stonewall_v2,
		tile_stonewall_v3,
		tile_stonewall_v4,
		tile_stonewall_d1,
		tile_stonewall_d2,
		tile_stonewall_d3,
		tile_stonewall_d4,
		tile_stonewall_d5,
		tile_stonewall_d6,
		tile_stonebackground,
		tile_stonebackground_v1,
		tile_stonebackground_v2,
		tile_stonebackground_v3,
		tile_stonebackground_d1,
		tile_stonebackground_d2,
		tile_stonebackground_d3,
		tile_stonebackground_d4,
		tile_woodwall,
		tile_woodwall_v1,
		tile_woodwall_v2,
		tile_woodwall_d1,
		tile_woodwall_d2,
		tile_woodwall_d3,
		tile_woodwall_d4,
		tile_woodwall_d5,
		tile_hardstoneore,
		tile_hardstoneore_v1,
		tile_hardstoneore_d1,
		tile_hardstoneore_d2,
		tile_hardstoneore_d3,
		tile_hardstoneore_d4,
		tile_stoneore,
		tile_stoneore_v1,
		tile_stoneore_d1,
		tile_stoneore_d2,
		tile_stoneore_d3,
		tile_stoneore_d4,
		tile_stoneore_d5,
		tile_stoneore_d6,
		tile_goldore = 80,
		tile_goldore_v1,
		tile_goldore_d1,
		tile_goldore_d2,
		tile_goldore_d3,
		tile_goldore_d4,
		tile_window,
		tile_window_v1,
		tile_window_v2,
		tile_window_v3,
		skip,
		skip2,
		tile_copperore,
		tile_copperore_v1,
		tile_copperore_d1,
		tile_copperore_d2,
		tile_copperore_d3,
		tile_hardrock = 106, // :^)
		tile_hardrock_v1,
		tile_hardrock_v2,
		tile_hardrock_v3,
		tile_hardrock_v4,
		tile_hardrock_v5,
		tile_glass,
		tile_glass_v1,
		tile_glass_v2,
		tile_glass_v3,
		tile_glass_v4,
		tile_glass_v5,
		tile_glass_v6,
		tile_glass_v7,
		tile_glass_v8,
		tile_glass_v9,
		tile_glass_v10,
		tile_glass_v11,
		tile_glass_v12,
		tile_glass_v13,
		tile_glass_v14,
		tile_glass_v15,
		tile_glass_d1,
		tile_bglass,
		tile_bglass_v1,
		tile_bglass_v2,
		tile_bglass_v3,
		tile_bglass_v4,
		tile_bglass_v5,
		tile_bglass_v6,
		tile_bglass_v7,
		tile_bglass_v8,
		tile_bglass_v9,
		tile_bglass_v10,
		tile_bglass_v11,
		tile_bglass_v12,
		tile_bglass_v13,
		tile_bglass_v14,
		tile_bglass_v15,
		tile_bglass_d1,
		tile_woodbackground,
		tile_woodbackground_v1,
		tile_woodbackground_v2,
		tile_woodbackground_v3,
		tile_woodbackground_v4,
		tile_woodbackground_d1,
		tile_goldwall = 161,
		tile_goldwall_v1,
		tile_copperwall,
		tile_copperwall_v1,
		tile_copperwall_d1,
		tile_copperwall_d2,
		tile_copperwall_d3,
		tile_copperwall_d4,
		tile_goldwall_d1,
		tile_goldwall_d2,
		tile_goldwall_d3,
		tile_goldwall_d4,
		tile_vine,
		tile_vine_v1,
		tile_vine_v2,
		tile_vine_v3,
		tile_vine_v4,
		tile_vine_v5,
		tile_vine_v6,
		tile_vine_v7,
		tile_vine_v8,
		tile_vine_v9,
		tile_vine_v10,
		tile_vine_v11,
		tile_vine_v12,
		tile_vine_v13,
		tile_vine_v14,
		tile_vine_v15,
		tile_vine_v16,
		tile_vine_v17,
		tile_vine_v18,
		tile_vine_d1,
		tile_vine_d2,
		tile_oldstonebackground,
		tile_oldstonebackground_v1,
		tile_oldstonebackground_v2,
		tile_oldstonebackground_v3,
		tile_oldstonebackground_v4,
		tile_oldstonebackground_v5,
		tile_stonewallmoss,
		tile_stonewallmoss_v1,
		tile_stonewallmoss_v2,
		tile_stonebackgroundmoss,
		tile_stonebackgroundmoss_v1,
		tile_stonebackgroundmoss_v2,
		tile_stonebackgroundmoss_v3,
		tile_stonebackgroundmoss_v4,
		tile_framedrubble = 224,
		tile_framedrubble_v1,
		tile_framedrubble_v2,
		tile_framedrubble_v3,
		tile_framedrubble_d1,
		tile_framedrubble_d2,
		tile_newrubble,
		tile_newrubble_v1,
		tile_newrubble_v2,
		tile_newrubble_v3,
		tile_newrubble_v4,
		tile_charredwoodwall,
		tile_charredwoodwall_d1,
		tile_charredwoodwall_d2,
		tile_newgrass,
		tile_newgrass_v1,
		tile_newgrass_v2,
		tile_newgrass_d1,
		tile_newgrass_d2,
		tile_newgrass_d3,
		tile_ironwall,
		tile_ironwall_v1,
		tile_ironwall_d1,
		tile_ironwall_d2,
		tile_ironwall_d3,
		tile_ironwall_d4,
	};
};

class BlockInfo
{
    string name;
    int DefaultTile;
	int Variative;
    int HitStart;
	int HitEnd;
    int TransformIndex;
	bool SaveBehind;

    int support;
	bool collapse;
    uint flags;

	f32 collapseDamage;
	f32 collapsePlaceSelfHarmModif;
	f32 collapsePlaceChance;

    string place_sound;
    string hit_sound;
    string destroy_sound;

	SColor map_color;
   
    BlockInfo(string name, int DefaultTile, int Variative, int HitStart, int HitEnd, int TransformIndex, int support, bool collapse, uint flags, f32 collapseDamage, f32 collapsePlaceSelfHarm, f32 collapsePlaceChance, string place_sound, string hit_sound, string destroy_sound, SColor map_color)
    {
        this.name = name;
       
        this.DefaultTile = DefaultTile;
		this.Variative = Variative;
        this.HitStart = HitStart;
		this.HitEnd = HitEnd;
        this.TransformIndex = TransformIndex;
		this.SaveBehind = false;
       
        this.support = support;
		this.collapse = collapse;
        this.flags = flags;

		this.collapseDamage = collapseDamage;
		this.collapsePlaceSelfHarmModif = collapsePlaceSelfHarm;
		this.collapsePlaceChance = collapsePlaceChance;
       
        this.hit_sound = hit_sound;
        this.destroy_sound = destroy_sound;
        this.place_sound = place_sound;
		
		this.map_color = map_color;
    }
	
	BlockInfo(string name, int DefaultTile, int Variative, int HitStart, int HitEnd, int TransformIndex, bool SaveBehind, int support, bool collapse, uint flags, f32 collapseDamage, f32 collapsePlaceSelfHarm, f32 collapsePlaceChance, string place_sound, string hit_sound, string destroy_sound, SColor map_color)
    {
        this.name = name;
       
        this.DefaultTile = DefaultTile;
		this.Variative = Variative;
        this.HitStart = HitStart;
		this.HitEnd = HitEnd;
        this.TransformIndex = TransformIndex;
		this.SaveBehind = SaveBehind;
       
        this.support = support;
		this.collapse = collapse;
        this.flags = flags;

		this.collapseDamage = collapseDamage;
		this.collapsePlaceSelfHarmModif = collapsePlaceSelfHarm;
		this.collapsePlaceChance = collapsePlaceChance;
       
        this.hit_sound = hit_sound;
        this.destroy_sound = destroy_sound;
        this.place_sound = place_sound;
		
		this.map_color = map_color;
    }
};
 
BlockInfo[] Blocks =    {
							BlockInfo("placeholder",
							CMap::tile_empty, 0, 
							CMap::tile_empty, CMap::tile_empty, CMap::tile_empty, 
							0, false, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE, 
							0.0f, 0.0f, 0.0f,
							"", "", "", 
							SColor(0xFFFFFFFF)),

							BlockInfo("dirt",
							CMap::tile_dirt, 1, 
							CMap::tile_dirt_d1, CMap::tile_dirt_d3, CMap::tile_dirtbackground, 
							-1, false, Tile::SOLID | Tile::COLLISION, 
							0.0f, 0.0f, 0.0f,
							"", "dig_dirt.ogg", "destroy_dirt.ogg", 
							SColor(0xFF844715)),

							BlockInfo("dirt background", 
							CMap::tile_dirtbackground, 4, 
							CMap::tile_dirtbackground, CMap::tile_dirtbackground, CMap::tile_dirtbackground, 
							-1, false, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES, 
							0.0f, 0.0f, 0.0f,
							"", "", "", 
							SColor(0xFF3B1406)),

							BlockInfo("stone wall", 
							CMap::tile_stonewall, 7, 
							CMap::tile_stonewall_d1, CMap::tile_stonewall_d6, CMap::tile_empty, 
							14, true, Tile::SOLID | Tile::COLLISION, 
							1.5f, 0.6f, 0.8f,
							"build_wall.ogg", "PickStone.ogg", "destroy_wall.ogg", 
							SColor(0xFF647160)),

							BlockInfo("stone background", 
							CMap::tile_stonebackground, 8, 
							CMap::tile_stonebackground_d1, CMap::tile_stonebackground_d4, CMap::tile_empty, 
							14, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES, 
							0.0f, 0.0f, 0.0f,
							"build_wall.ogg", "PickStone.ogg", "destroy_wall.ogg", 
							SColor(0xFF3A3A1F)),

							BlockInfo("gold ore", 
							CMap::tile_goldore, 2, 
							CMap::tile_goldore_d1, CMap::tile_goldore_d4, CMap::tile_dirtbackground, 
							-1, false, Tile::SOLID | Tile::COLLISION, 
							0.0f, 0.0f, 0.0f,
							"", "dig_stone.ogg", "destroy_gold.ogg", 
							SColor(0xFFFEA53D)),

							BlockInfo("hard stone ore", 
							CMap::tile_hardstoneore, 2, 
							CMap::tile_hardstoneore_d1, CMap::tile_hardstoneore_d4, CMap::tile_stoneore, 
							-1, false, Tile::SOLID | Tile::COLLISION, 
							0.0f, 0.0f, 0.0f,
							"", "dig_stone", "destroy_stone.ogg", 
							SColor(0xFF42484B)),
							
							BlockInfo("stone ore", 
							CMap::tile_stoneore, 2, 
							CMap::tile_stoneore_d1, CMap::tile_stoneore_d6, CMap::tile_dirtbackground, 
							-1, false, Tile::SOLID | Tile::COLLISION, 
							0.0f, 0.0f, 0.0f,
							"", "dig_stone", "destroy_stone.ogg", 
							SColor(0xFF8B6849)),

							BlockInfo("gold wall", 
							CMap::tile_goldwall, 2, 
							CMap::tile_goldwall_d1, CMap::tile_goldwall_d4, CMap::tile_empty, true, 
							16, true, Tile::SOLID | Tile::COLLISION, 
							2.0f, 0.8f, 0.7f,
							"build_wall.ogg", "dig_stone.ogg", "destroy_gold.ogg", 
							SColor(0xFFFFD67D)),

							BlockInfo("wood background", 
							CMap::tile_woodbackground, 10, 
							CMap::tile_woodbackground_d1, CMap::tile_woodbackground_d1, CMap::tile_empty, 
							6, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES | Tile::FLAMMABLE, 
							0.0f, 0.0f, 0.0f,
							"build_wood.ogg", "hit_wood.ogg", "destroy_wood.ogg", 
							SColor(0xFF552A11)),

							BlockInfo("wood wall",
							CMap::tile_woodwall, 9, 
							CMap::tile_woodwall_d1, CMap::tile_woodwall_d5, CMap::tile_empty, 
							6, true, Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE, 
							0.5f, 0.6f, 1.0f,
							"build_wood.ogg", "hit_wood.ogg", "destroy_wood.ogg", 
							SColor(0xFFC48715)),

							BlockInfo("stone wall moss", 
							CMap::tile_stonewallmoss, 14, 
							CMap::tile_stonewall_d1, CMap::tile_stonewall_d6, CMap::tile_empty, 
							14, true, Tile::SOLID | Tile::COLLISION, 
							1.5f, 0.5f, 0.8f,
							"build_wall.ogg", "PickStone.ogg", "destroy_wall.ogg", 
							SColor(0xFF648F60)),

							BlockInfo("stone background moss", 
							CMap::tile_stonebackgroundmoss, 15, 
							CMap::tile_stonebackground_d1, CMap::tile_stonebackground_d4, CMap::tile_empty, 
							14, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES, 
							0.0f, 0.0f, 0.0f,
							"build_wall.ogg", "PickStone.ogg", "destroy_wall.ogg", 
							SColor(0xFF315212)),

							BlockInfo("copper ore", 
							CMap::tile_copperore, 2, 
							CMap::tile_copperore_d1, CMap::tile_copperore_d3, CMap::tile_dirtbackground, 
							-1, false, Tile::SOLID | Tile::COLLISION, 
							0.0f, 0.0f, 0.0f,
							"", "dig_stone.ogg", "destroy_gold.ogg", 
							SColor(0xFFB76022)),

							BlockInfo("copper wall", 
							CMap::tile_copperwall, 2, 
							CMap::tile_copperwall_d1, CMap::tile_copperwall_d4, CMap::tile_empty, true,
							10, true, Tile::SOLID | Tile::COLLISION, 
							2.0f, 0.7f, 0.8f,
							"build_wall.ogg", "dig_stone.ogg", "destroy_stone.ogg", 
							SColor(0xFF914007)),
							
							BlockInfo("glass wall", 
							CMap::tile_glass, 3, 
							CMap::tile_glass_d1, CMap::tile_glass_d1, CMap::tile_empty, true,
							18, true, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE,
							0.2f, 0.9f, 0.4f,
							"build_wall.ogg", "GlassBreak2.ogg", "GlassBreak1.ogg", 
							SColor(0xFF4F91A7)),

							BlockInfo("glass background", 
							CMap::tile_bglass, 3, 
							CMap::tile_bglass_d1, CMap::tile_bglass_d1, CMap::tile_empty, 
							18, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE, 
							0.0f, 0.0f, 0.0f,
							"build_wall.ogg", "GlassBreak2.ogg", "GlassBreak1.ogg", 
							SColor(0xFF132B34)),
							
							BlockInfo("hard rock", 
							CMap::tile_hardrock, 16, 
							CMap::tile_hardrock, CMap::tile_hardrock, CMap::tile_hardrock, 
							-1, false, Tile::SOLID | Tile::COLLISION, 
							0.0f, 0.0f, 0.0f,
							"", "", "", 
							SColor(0xFF2D342D)),

							BlockInfo("vine", 
							CMap::tile_vine, 5, 
							CMap::tile_vine_d1, CMap::tile_vine_d2, CMap::tile_empty, true,
							6, true, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES | Tile::FLAMMABLE,
							0.3f, 0.3f, 0.7f,
							"arrow_hitfast_ground.ogg", "cut_grass1.ogg", "cut_grass2.ogg", 
							SColor(0xFF72AF0F)),
							
							BlockInfo("charred wood wall",
							CMap::tile_charredwoodwall, 0, 
							CMap::tile_charredwoodwall_d1, CMap::tile_charredwoodwall_d2, CMap::tile_empty, 
							6, true, Tile::SOLID | Tile::COLLISION, 
							0.1f, 0.6f, 1.0f,
							"", "dig_dirt.ogg", "destroy_wood.ogg", 
							SColor(0xFF232323)),

							BlockInfo("rubble",
							CMap::tile_newrubble, 6, 
							CMap::tile_newrubble, CMap::tile_newrubble, CMap::tile_empty, 
							6, false, Tile::SOLID | Tile::COLLISION, 
							0.5f, 0.6f, 1.0f,
							"", "Rubble", "Rubble", 
							SColor(0xFF3B4015)),
						
							BlockInfo("window",
							CMap::tile_window, 11, 
							CMap::tile_window, CMap::tile_window, CMap::tile_empty, 
							8, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::FLAMMABLE, 
							0.0f, 0.0f, 0.0f,
							"build_wood.ogg", "hit_wood.ogg", "destroy_wood.ogg", 
							SColor(0xFF683314)),
							
							BlockInfo("paper", 
							CMap::tile_paper, 8, 
							CMap::tile_paper_d1, CMap::tile_paper_d1, CMap::tile_empty, 
							8, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::FLAMMABLE,  
							0.0f, 0.0f, 0.0f,
							"build_wood.ogg", "hit_wood.ogg", "destroy_wood.ogg",
							SColor(0xFF8B6849)),
							
							BlockInfo("framed rubble", 
							CMap::tile_framedrubble, 8, 
							CMap::tile_framedrubble_d1, CMap::tile_framedrubble_d2, CMap::tile_empty, 
							8, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES,  
							0.0f, 0.0f, 0.0f,
							"build_wall.ogg", "PickStone.ogg", "destroy_wall.ogg", 
							SColor(0xFF3A3512)),
							
							BlockInfo("old stone background", 
							CMap::tile_oldstonebackground, 12, 
							CMap::tile_oldstonebackground, CMap::tile_oldstonebackground, CMap::tile_stonebackground_d1, 
							14, true, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES, 
							0.0f, 0.0f, 0.0f,
							"build_wall.ogg", "", "PickStone.ogg", 
							SColor(0xFF313412)),
							
							BlockInfo("grass", 
							CMap::tile_newgrass, 13, 
							CMap::tile_newgrass_d1, CMap::tile_newgrass_d3, CMap::tile_empty, 
							0, true, Tile::WATER_PASSES | Tile::LIGHT_PASSES | Tile::FLAMMABLE, 
							0.0f, 0.0f, 0.0f,
							"", "cut_grass.ogg", "cut_grass.ogg", 
							SColor(0xFF649B0D)),
							
							BlockInfo("iron wall", 
							CMap::tile_ironwall, 2, 
							CMap::tile_ironwall_d1, CMap::tile_ironwall_d4, CMap::tile_empty, true,
							10, true, Tile::SOLID | Tile::COLLISION, 
							2.0f, 0.7f, 0.8f,
							"build_wall.ogg", "dig_stone.ogg", "destroy_stone.ogg", 
							SColor(0xFF929E8E)),
	
	//BlockInfo(string name, int DefaultTile, int Variative, int HitStart, int HitEnd, int TransformIndex, int support, bool collapse, uint flags, f32 collapseDamage, f32 collapsePlaceSelfHarm, f32 collapsePlaceChance, string place_sound, string hit_sound, string destroy_sound, SColor map_color),
};

bool isBlockSolid(CMap@ map, u32 index)
{
	TileType tile = map.getTile(index).type;
	for(int i = 0;i < Blocks.length;i++)
	{
        BlockInfo @Block = Blocks[i];
		if(tile == Block.DefaultTile || (tile >= Block.HitStart && tile <= Block.HitEnd) || isOneOfTheVariations(tile, Block.DefaultTile, Block.Variative))
		{
			if(Block.name != "" && (Block.flags & (Tile::SOLID + Tile::COLLISION)) > 0)
			{
				return true;
			}
		}
	}
	return false;
}

bool isBlockSolidTT(CMap@ map, TileType tile)
{
	for(int i = 0;i < Blocks.length;i++)
	{
        BlockInfo @Block = Blocks[i];
		if(tile == Block.DefaultTile || (tile >= Block.HitStart && tile <= Block.HitEnd) || isOneOfTheVariations(tile, Block.DefaultTile, Block.Variative))
		{
			if(Block.name != "" && (Block.flags & (Tile::SOLID + Tile::COLLISION)) > 0)
				return true;
		}
	}
	return false;
}

bool isOneOfTheVariations(u32 offset, int DefaultTile, u32 Variative)
{
	switch(Variative)
	{
		case 0:
			return false;

		case 2:
			return offset == DefaultTile+1;
		
		case 3:
			return offset > DefaultTile && offset <= DefaultTile+15;
		case 4:
			return offset > DefaultTile && offset <= DefaultTile+19;
		
		case 5:
			return offset > DefaultTile && offset <= DefaultTile+18;
		
		case 6:
		case 7:
		case 10:
		case 15:
			return offset > DefaultTile && offset <= DefaultTile+4;
		
		case 8:
		case 11:
			return offset > DefaultTile && offset <= DefaultTile+3;
		
		case 1:
		case 9:
		case 13:
		case 14:
			return offset > DefaultTile && offset <= DefaultTile+2;
		
		case 12:
		case 16:
			return offset > DefaultTile && offset <= DefaultTile+5;
	}
	return false;
}

TileType getVariation(CMap@ map, int DefaultTile, u32 index, int Variative)
{
	switch(Variative)
	{
		case 0:
			return DefaultTile;

		case 1:
		{
			if(!isBlockSolid(map, index-map.tilemapwidth))
			{
				if(map.getTile(index-map.tilemapwidth).type >= CMap::tile_newgrass && map.getTile(index-map.tilemapwidth).type <= CMap::tile_newgrass_d3)
					return DefaultTile+2;
				else
					return DefaultTile+1;
			}
			else
				return DefaultTile;
		}
		
		case 2:
		{
			if((index / map.tilemapwidth + index % map.tilemapwidth) % 2 == 0)
				return DefaultTile+1;
			else
				return DefaultTile;
		}
		
		case 3:
		{
			u8 mask = 0;
			Vec2f pos = map.getTileWorldPosition(index);
			for (u8 i = 0; i < 4; i++)
			{
				u16 tile = map.getTile(pos + directions[i]).type;
				if (tile >= DefaultTile && tile <= DefaultTile+15)
					mask |= 1 << i;
			}
			return DefaultTile+mask;
		}

		case 4:
		{
			u8 mask = 0;
			Vec2f pos = map.getTileWorldPosition(index);
			for (u8 i = 0; i < 4; i++)
			{
				u16 tile = map.getTile(pos + directions[i]).type;
				if (tile > 0)
					mask |= 1 << i;
			}
			//return DefaultTile+mask;
			if(mask == 15)
				return DefaultTile+mask+((index / map.tilemapwidth + index % map.tilemapwidth) % 5);
			else
				return DefaultTile+mask;
		}
		
		case 5:
		{
			u8 mask = 0;
			Vec2f pos = map.getTileWorldPosition(index);
			for (u8 i = 0; i < 4; i++)
			{
				u16 tile = map.getTile(pos + directions[i]).type;
				if (tile >= DefaultTile && tile <= DefaultTile+18)
					mask |= 1 << i;
			}
			if(mask == 15)
				return DefaultTile+mask+((index / map.tilemapwidth + index % map.tilemapwidth) % 4);
			else
				return DefaultTile+mask;
		}
		
		case 6:
		{
			u8 mask = 0;
			if(map.getTile(index-1).type != 0)
				mask += 1;
			if(map.getTile(index+1).type != 0)
				mask += 2;
			if(isBlockSolid(map, index-map.tilemapwidth))
				mask = 4;
			return DefaultTile+mask;
		}
		
		case 7:
		{
			if(!isBlockSolid(map, index-map.tilemapwidth) && map.getTile(index-map.tilemapwidth).type > 0)
				return DefaultTile+2;
			if(isBlockSolid(map, index-map.tilemapwidth) && (!isBlockSolid(map, index+map.tilemapwidth) && map.getTile(index+map.tilemapwidth).type > 0))
				return DefaultTile+3;
			if(isBlockSolid(map, index-map.tilemapwidth) && isBlockSolid(map, index+map.tilemapwidth) && ((!isBlockSolid(map, index+1) && map.getTile(index+1).type > 0) || (!isBlockSolid(map, index-1) && map.getTile(index-1).type > 0)))
				return DefaultTile+4;
			return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 2);
		}
		
		case 8:
		{
			u8 mask = 0;
			if(map.getTile(index-map.tilemapwidth).type <= DefaultTile+3 && map.getTile(index-map.tilemapwidth).type >= DefaultTile)
				mask += 1;
			if(map.getTile(index+map.tilemapwidth).type <= DefaultTile+3 && map.getTile(index+map.tilemapwidth).type >= DefaultTile && mask == 1)
				mask += 2;
			if(mask == 2 || mask == 3)
				return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 2)+2;
			return DefaultTile+mask;
		}
		
		case 9:
		{
			if(!isBlockSolid(map, index+map.tilemapwidth) && map.getTile(index+map.tilemapwidth).type > 0)
				return DefaultTile+1;
			if(isBlockSolid(map, index-map.tilemapwidth) && isBlockSolid(map, index+map.tilemapwidth) && ((!isBlockSolid(map, index+1) && map.getTile(index+1).type > 0) || (!isBlockSolid(map, index-1) && map.getTile(index-1).type > 0)))
				return DefaultTile+2;
			return DefaultTile;
		}
		
		case 10:
		{
			if((map.getTile(index+1).type >= DefaultTile && map.getTile(index+1).type <= DefaultTile+4) && (map.getTile(index-1).type >= DefaultTile && map.getTile(index-1).type <= DefaultTile+4))
				return DefaultTile;
			else
			{
				if(map.getTile(index+1).type >= DefaultTile && map.getTile(index+1).type <= DefaultTile+4)
				{
					if(!(map.getTile(index-map.tilemapwidth).type >= DefaultTile && map.getTile(index-map.tilemapwidth).type <= DefaultTile+4) && (map.getTile(index+map.tilemapwidth).type >= DefaultTile && map.getTile(index+map.tilemapwidth).type <= DefaultTile+4))
						return DefaultTile+3;
					return DefaultTile+1;
				}
				
				if(map.getTile(index-1).type >= DefaultTile && map.getTile(index-1).type <= DefaultTile+4)
				{
					if(!(map.getTile(index-map.tilemapwidth).type >= DefaultTile && map.getTile(index-map.tilemapwidth).type <= DefaultTile+4) && (map.getTile(index+map.tilemapwidth).type >= DefaultTile && map.getTile(index+map.tilemapwidth).type <= DefaultTile+4))
						return DefaultTile+4;
					return DefaultTile+2;
				}
				return DefaultTile;
			}
		}
		
		case 11:
		{
			u8 mask = 0;
			if(map.getTile(index-map.tilemapwidth).type <= DefaultTile+3 && map.getTile(index-map.tilemapwidth).type >= DefaultTile)
				mask += 1;
			if(map.getTile(index+map.tilemapwidth).type <= DefaultTile+3 && map.getTile(index+map.tilemapwidth).type >= DefaultTile)
				mask += 2;
			return DefaultTile+mask;
		}
		
		case 12:
		{
			if(map.getTile(index-map.tilemapwidth).type > 0)
			{
				if(isBlockSolid(map, index+map.tilemapwidth))
					return DefaultTile+3;
				else
				{
					if(map.getTile(index-1).type > 0 && map.getTile(index+1).type > 0)
						return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 2)+4;
					else
					{
						if(map.getTile(index-1).type > 0 || map.getTile(index+1).type > 0)
						{
							if(map.getTile(index-1).type > 0)
								return DefaultTile+2;
							if(map.getTile(index+1).type > 0)
								return DefaultTile+1;
						}
						else
							return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 2)+1;
					}
				}
			}
			return DefaultTile;
		}
		
		case 13:
		{
			return map.getTile(index).type;
		}
		
		case 14:
		{
			if(!isBlockSolid(map, index-map.tilemapwidth) && map.getTile(index-map.tilemapwidth).type > 0)
				return DefaultTile+2;
			else if(!isBlockSolid(map, index+map.tilemapwidth) && map.getTile(index+map.tilemapwidth).type > 0)
				return DefaultTile+1;
			else
				return DefaultTile;
		}
		
		case 15:
		{
			if(isBlockSolid(map, index-map.tilemapwidth) || map.getTile(index-map.tilemapwidth).type <= 0)
				return DefaultTile;
			else if(isBlockSolid(map, index+map.tilemapwidth) || map.getTile(index+map.tilemapwidth).type <= 0)
				return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 2)+1;
			else
				return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 2)+3;
		}
		
		case 16:
		{
			return DefaultTile+((index / map.tilemapwidth + index % map.tilemapwidth) % 6);
		}
	}
	return DefaultTile;
}

const Vec2f[] directions = {	Vec2f(0, -8),
								Vec2f(0, 8),
								Vec2f(8, 0),
								Vec2f(-8, 0)};

BlockInfo@ getBlock(CMap@ map, u32 index)
{
	TileType tile = map.getTile(index).type;
	for(int i = 0;i < Blocks.length;i++)
	{
        BlockInfo@ Block = Blocks[i];
		if(tile == Block.DefaultTile || (tile >= Block.HitStart && tile <= Block.HitEnd) || isOneOfTheVariations(tile, Block.DefaultTile, Block.Variative))
			return Block;
	}
	return Blocks[0];
}

BlockInfo@ getBlockTT(CMap@ map, TileType tile)
{
	for(int i = 0;i < Blocks.length;i++)
	{
        BlockInfo@ Block = Blocks[i];
		if(tile == Block.DefaultTile || (tile >= Block.HitStart && tile <= Block.HitEnd) || isOneOfTheVariations(tile, Block.DefaultTile, Block.Variative))
			return Block;
	}
	return Blocks[0];
}

void updateNearest(CMap@ map, u32 index)
{
	if(!map.hasTileFlag(index+map.tilemapwidth, Tile::SPARE_2) && map.getTile(index+map.tilemapwidth).type != CMap::tile_empty)
	{
		TileType DownTile = map.getTile(index+map.tilemapwidth).type;
		BlockInfo@ DownBlock = getBlock(map, index+map.tilemapwidth);
		if(DownBlock !is null && (DownTile == DownBlock.DefaultTile || isOneOfTheVariations(DownTile, DownBlock.DefaultTile, DownBlock.Variative)))
		{
			map.server_SetTile(map.getTileWorldPosition(index+map.tilemapwidth) ,getVariation(map, DownBlock.DefaultTile, index+map.tilemapwidth, DownBlock.Variative));
			if(getNet().isClient())
				map.SetTile(index+map.tilemapwidth ,getVariation(map, DownBlock.DefaultTile, index+map.tilemapwidth, DownBlock.Variative));
		}
	}
	if(!map.hasTileFlag(index-map.tilemapwidth, Tile::SPARE_2) && map.getTile(index-map.tilemapwidth).type != CMap::tile_empty)
	{
		TileType UpTile = map.getTile(index-map.tilemapwidth).type;
		BlockInfo@ UpBlock = getBlock(map, index-map.tilemapwidth);
		if(UpBlock.name == "grass" && !isBlockSolid(map, index))
			map.server_SetTile(map.getTileWorldPosition(index-map.tilemapwidth), CMap::tile_empty);
		else if(UpBlock !is null && (UpTile == UpBlock.DefaultTile || isOneOfTheVariations(UpTile, UpBlock.DefaultTile, UpBlock.Variative)))
		{
			map.server_SetTile(map.getTileWorldPosition(index-map.tilemapwidth),getVariation(map, UpBlock.DefaultTile, index-map.tilemapwidth, UpBlock.Variative));
			if(getNet().isClient())
				map.SetTile(index-map.tilemapwidth ,getVariation(map, UpBlock.DefaultTile, index-map.tilemapwidth, UpBlock.Variative));
		}
	}
	if(!map.hasTileFlag(index+1, Tile::SPARE_2) && map.getTile(index+1).type != CMap::tile_empty)
	{
		TileType RightTile = map.getTile(index+1).type;
		BlockInfo@ RightBlock = getBlock(map, index+1);
		//if(RightBlock.name == "rubble" && map.getTile(index+1+map.tilemapwidth).type == CMap::tile_empty)
		//	collapseRubble(map, index+1);
		//else 
		if(RightBlock !is null && (RightTile == RightBlock.DefaultTile || isOneOfTheVariations(RightTile, RightBlock.DefaultTile, RightBlock.Variative)))
		{
			map.server_SetTile(map.getTileWorldPosition(index+1) ,getVariation(map, RightBlock.DefaultTile, index+1, RightBlock.Variative));
			if(getNet().isClient())
				map.SetTile(index+1 ,getVariation(map, RightBlock.DefaultTile, index+1, RightBlock.Variative));
		}
	}
	if(!map.hasTileFlag(index-1, Tile::SPARE_2) && map.getTile(index-1).type != CMap::tile_empty)
	{
		TileType LeftTile = map.getTile(index-1).type;
		BlockInfo@ LeftBlock = getBlock(map, index-1);
		//if(LeftBlock.name == "rubble" && map.getTile(index-1+map.tilemapwidth).type == CMap::tile_empty)
		//	collapseRubble(map, index-1);
		//else 
		if(LeftBlock !is null && (LeftTile == LeftBlock.DefaultTile || isOneOfTheVariations(LeftTile, LeftBlock.DefaultTile, LeftBlock.Variative)))
		{
			map.server_SetTile(map.getTileWorldPosition(index-1) ,getVariation(map, LeftBlock.DefaultTile, index-1, LeftBlock.Variative));
			if(getNet().isClient())
				map.SetTile(index-1 ,getVariation(map, LeftBlock.DefaultTile, index-1, LeftBlock.Variative));
		}
	}
}

void collapseRubble(CMap@ map, u32 index)
{
	map.SetTileSupport(index, 0);
	map.AddTileFlag(index, Tile::SPARE_2);
	positions.push_back(index);
	if(map.getTile(index-map.tilemapwidth).type >= CMap::tile_newrubble && map.getTile(index-map.tilemapwidth).type <= CMap::tile_newrubble_v4)
		collapseRubble(map, index-map.tilemapwidth);
}

void CreateRubbleParticles(CMap@ map, u32 index)
{
	CBlob@ rock = server_CreateBlob("cata_rock", 227, map.getTileWorldPosition(index));
	if (rock !is null)
	{
		rock.setVelocity(Vec2f(0, -3));
	}
}

void CreateDestroyParticles(CMap@ map, u32 index, TileType tile)
{
	Texture::createFromFile("worldtilemap", "world.png");
	ImageData@ world;
	if(Texture::exists("worldtilemap"))
		@world = Texture::data("worldtilemap");
	Vec2f position = Vec2f(int(tile % 16), int(tile / 16));
	position *= 8;
	for(int x = position.x; x < position.x+8; x++)
	{
		for(int y = position.y; y < position.y+8; y++)
		{
			if(XORRandom(3) != 2)
				continue;
			SColor color = world.get(x,y);
			if(color == SColor(0xFFFFFFFF) || color == SColor(0x00FFFFFF) || color == SColor(0xFF000000) || color == SColor(0xff130D1D))
				continue;
			CParticle@ pixel = ParticlePixel(map.getTileWorldPosition(index)+Vec2f(x-position.x+0.5,y-position.y+0.5), Vec2f(((x-position.x)-3.5)/3.5,((y-position.y)-3.5)/3.5), color, true);
			if(pixel !is null)
			{
				pixel.bounce = 0.3;
				pixel.timeout = 16;
				pixel.fastcollision = true;
			}
		}
	}
}
