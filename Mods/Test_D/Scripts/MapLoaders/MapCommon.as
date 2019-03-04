#include "GameColours.as";

namespace TWMap
{
	// tiles
	const SColor color_bgdecor(0xff2c333f);
	const SColor color_bgdecor_room(0xff523644);

	const SColor color_dirt(0xff95754a);
	const SColor color_dirt_grass(0xff9fba40);
	const SColor color_sand(0xffffff80);

	const SColor color_dark_solid(0xff615445);

	const SColor color_bush(0xffa9ff37);
	const SColor color_bgbushdecor_leaves(0xff40905f);
	const SColor color_bgbushdecor_trunk(0xff204830);
	const SColor color_bgbushdecor_branch(0xff183266);

	const SColor color_bunker(0xffa8a8a8);
	const SColor color_bunker_wall(0xff6a6e74);
	const SColor color_bunker_wood(0xff9f8f79);
	const SColor color_rubble(0xff749c84);
	const SColor color_rubble_background(0xff3a4e42);

	const SColor color_woodbridge(0xffc6ac69);
	const SColor color_crate(0xffb27a4c);
	const SColor color_roof(0xff9f482f);

	const SColor color_reeds(0xff092435);

	const SColor color_cactus(0xff94e39b);
	const SColor color_flower(0xffda3838);

	const SColor color_water(0xff00c0ff);
	const SColor color_swamp_bed(0xff7793c4);

	const SColor color_ladder(0xffd6b1a3);

	const SColor color_mountstone(0xff5470a2);
	const SColor color_snow(0xffd4d4d4);

	const SColor color_black_background(0xff000000);

	// objects
	const SColor color_neutral_spawn(255, 255, 255, 255);
	const SColor color_blue_spawn(255, 0, 255, 255);
	const SColor color_red_spawn(255, 255, 0, 0);
	const SColor color_green_spawn(255, 0, 255, 0);
	const SColor color_pink_spawn(255, 255, 0, 255);
	const SColor color_classchange(0xfff8ff31);
	const SColor color_campaignview(0xffff09b7);
	const SColor color_bottle(0xfff971cb);
	const SColor color_band(0xff7f045b);
	const SColor color_hoop(0xff943b0a);
	const SColor color_dispenser(0xffc42b08);
	const SColor color_shop(0xff9a0367);
	const SColor color_billboard(0xff8d65b3);

	// AI markers
	const SColor color_blue_sniperspot(0xff44A6D8);
	const SColor color_red_sniperspot(0xffD92F6F);

	// truck
	const SColor color_skirmish_truck(0xffb3c800);
	const SColor color_blue_truck(0xff005ac8);
	const SColor color_red_truck(0xffc80034);

	const SColor color_croc(0xff34c452);

	//auto-areas
	const SColor color_auto_cave(0xff893e4b);
	const SColor color_auto_cave_grassy(0xff586c5e);
	const SColor color_auto_cave_sand(0xffa76e58);

	enum Blocks
	{
		tile_empty = 0,
		tile_placemostlikely,

		//decor row

		tile_bgdecor_door_horiz = 16,
		tile_bgdecor_door_vert,
		tile_bgdecor_girder_horiz,
		tile_bgdecor_girder_vert,
		tile_bgdecor_panel,
		tile_bgdecor_vent,
		tile_bgdecor_ramp_left,
		tile_bgdecor_ramp_right,
		tile_bgdecor_struct_vert,
		tile_bgdecor_struct_horiz,
		tile_bgdecor_handle_top,
		tile_bgdecor_handle_bottom,
		tile_bgdecor_handle_left,
		tile_bgdecor_handle_right,
		tile_bgdecor_crate,
		tile_bgdecor_wire,
		//inside roof decor

		tile_roofdecor_1 = 62,
		tile_roofdecor_2,

		//dirt tiles

		tile_dirt_1 = 32,
		tile_dirt_2,
		tile_dirt_3,
		tile_dirt_4,
		tile_dirt_5,
		tile_dirt_6,
		tile_dirt_7,
		tile_dirt_8,
		tile_dirt_grass,
		tile_dirtdecor_floor_1,
		tile_dirtdecor_floor_2,
		tile_dirtdecor_roof_1,
		tile_dirtdecor_roof_2,
		tile_dirtdecor_corner_bottom,
		tile_dirtdecor_corner_top,
		tile_dirtdecor_wall,

		//bush tiles

		tile_bush = 48,
		tile_bush_corner,
		tile_bush_light_1,
		tile_bush_light_2,
		tile_bush_single,
		tile_bgbushdecor_leaves,
		tile_bgbushdecor_trunk,
		tile_bgbushdecor_branch,
		tile_bgbushdecor_branch_left,
		tile_bgbushdecor_branch_right,
		tile_bgbushdecor_branch_up,
		tile_bgbushdecor_trunk_top,


		//bunker tiles

		tile_bunker = 64,
		tile_bunker_up,
		tile_bunker_left,
		tile_bunker_right,
		tile_bunker_down,
		tile_bunker_wood_up,
		tile_bunker_wood_left,
		tile_bunker_wood_right,
		tile_bunker_wood_down,
		tile_rubble,

		tile_dark_solid,

		tile_ladder,
		tile_ladder_top,

		tile_roof_top,
		tile_roof_body,
		tile_roof_half,

		tile_rubble_background = 126,

		//water sand
		tile_swamp_bed_1 = 110,
		tile_swamp_bed_2,

		//sand tiles

		tile_sand_1 = 96,
		tile_sand_2,
		tile_sand_3,
		tile_sand_4,
		tile_sand_5,
		tile_sand_6,
		tile_sand_7,
		tile_sand_8,
		tile_sand_grass,
		tile_sand_decor_1,
		tile_sand_decor_2,
		tile_sand_dark_floor,
		tile_sand_dark_roof,
		tile_sand_dark_wall,

		tile_sand_decor_curve = tile_sand_decor_2 + 16,
		tile_sand_decor_curve_dark,

		tile_cactus_1 = 112,
		tile_cactus_2,

		//grass decor

		tile_grass_tuft_1 = 114,
		tile_grass_tuft_2,

		//flowers

		tile_flower_1 = 118,
		tile_flower_2,
		tile_flower_dark_1,
		tile_flower_dark_2,

		//wood bridge/crates + dmg frames

		tile_woodbridge = 80,
		tile_woodbridge_vert,
		tile_woodbridge_top,
		tile_woodbridge_join,
		tile_woodbridge_bottom,
		tile_crate_1,
		tile_crate_2,
		tile_crate_3,
		tile_crate_4,

		tile_planks_moss_under,
		tile_planks_moss_over,
		tile_planks_broken,

		tile_reeds_1,
		tile_reeds_2,
		tile_reeds_3,
		tile_reeds_4,

		//mountain tiles

		tile_mountain_grass = 115,
		tile_grass_short_cave,
		tile_grass_cave,
		tile_grass_tuft_cave,

		tile_mountstone_1 = 130,
		tile_mountstone_2,
		tile_mountstone_3,
		tile_mountstone_4,
		tile_mountstone_5,
		tile_mountstone_6,
		tile_mountstone_7,
		tile_mountstone_8,
		tile_mountstone_under_bg_1,
		tile_mountstone_under_bg_2,
		tile_mountstone_over_bg_1 = tile_mountstone_under_bg_1 + 16,
		tile_mountstone_over_bg_2,
		tile_mountstone_side_bg,

		tile_rough_backedge = tile_mountstone_under_bg_2 + 1,
		tile_rough_corner,
		tile_rough_tight,
		tile_rough_blind,

		tile_snow_1 = 144,
		tile_snow_2,
		tile_snow_3,
		tile_snow_4,
		tile_snow_5,
		tile_snow_6,
		tile_snow_over_1 = 128,
		tile_snow_over_2,

		//coloured(black) sky
		tile_black_background = 127,

		//auto stuff
		tile_auto_cave = 200,
		tile_auto_cave_grassy,
		tile_auto_cave_sand,
	};

	void SetupMap(CMap@ map, int width, int height)
	{
		map.CreateTileMap(width, height, 8.0f, "Sprites/world.png");
		map.CreateSky(SColor(Colours::BLACK));
		map.bottomBorder = map.rightBorder = map.leftBorder = true;
		map.topBorder = false;
		map.legacyTileVariations = map.legacyTileEffects = map.legacyTileDestroy = false; // don't use KAG tile effects
	}

	/////////////////////////////////
	//tile checks

	//tile flag related
	bool isTileTypeBackground(TileType tile)
	{
		return tile == 0 ||
		       tile >= tile_bgdecor_door_horiz && tile <= tile_bgdecor_wire ||
		       tile == tile_roofdecor_1 || tile == tile_roofdecor_2 ||
		       tile == tile_bgbushdecor_leaves ||
		       tile == tile_bgbushdecor_trunk ||
		       tile == tile_bgbushdecor_branch ||
		       tile == tile_bgbushdecor_branch_left ||
		       tile == tile_bgbushdecor_branch_right ||
		       tile == tile_bgbushdecor_branch_up ||
		       tile == tile_bgbushdecor_trunk_top ||
		       tile == tile_reeds_1 ||
		       tile == tile_reeds_2 ||
		       tile == tile_reeds_3 ||
		       tile == tile_reeds_4 ||
		       tile >= tile_dirtdecor_floor_1 && tile <= tile_dirtdecor_wall ||
		       tile == tile_black_background ||
		       tile == tile_ladder ||
		       tile == tile_ladder_top ||
		       tile >= tile_mountstone_under_bg_1 && tile <= tile_rough_blind ||
		       tile == tile_snow_over_1 ||
		       tile == tile_snow_over_2 ||
		       tile >= tile_sand_decor_1 && tile <= tile_sand_decor_2 || tile == tile_sand_decor_curve ||
		       tile >= tile_flower_1 && tile <= tile_flower_dark_2 ||
		       tile == tile_rubble_background ||
		       tile >= tile_mountain_grass && tile <= tile_grass_tuft_cave ||
		       isTileFiddlyBackground(tile);
	}

	bool isTileTypeLadder(TileType tile)
	{
		return tile == tile_ladder ||
		       tile == tile_ladder_top;
	}

	bool isTileTypeSolid(TileType tile)
	{
		return isTileDirt(tile) ||
		       tile == tile_dirt_grass ||
		       tile >= tile_bunker && tile <= tile_bunker_wood_down ||
		       tile == tile_rubble ||
		       tile == tile_dark_solid ||
		       tile >= tile_woodbridge && tile <= tile_planks_broken ||
		       isTileSwamp(tile) ||
		       isTileRoof(tile) ||
		       tile >= tile_sand_1 && tile <= tile_sand_8 ||
		       tile >= tile_mountstone_1 && tile <= tile_mountstone_8 ||
		       tile >= tile_snow_1 && tile <= tile_snow_6;
	}

	//sound/effects/"type" related
	bool isTileWood(u8 tile)
	{
		return tile >= tile_woodbridge && tile <= tile_planks_broken ||
		       tile >= tile_bunker_wood_up && tile <= tile_bunker_wood_down ||
		       tile == tile_roof_body;
	}

	bool isTileGrass(u8 tile)
	{
		return tile == tile_dirt_grass ||
		       tile == tile_sand_grass;
	}

	bool isTileBush(u8 tile)
	{
		return tile >= tile_bush && tile <= tile_bush_single;
	}

	bool isTileCactus(u8 tile)
	{
		return tile == tile_cactus_1 || tile == tile_cactus_2;
	}

	bool isTileBunker(u8 tile)
	{
		return tile >= tile_bunker &&
		       tile <= tile_bunker_wood_down;
	}

	bool isTileRoof(u8 tile)
	{
		return tile == tile_roof_top ||
		       tile == tile_roof_body ||
		       tile == tile_roof_half;
	}

	bool isTileStone(u8 tile)
	{
		return isTileBunker(tile) ||
		       tile == tile_rubble ||
		       tile == tile_roof_top ||
		       isTileMountainStone(tile);
	}

	bool isTileMountainStone(u8 tile)
	{
		return tile >= tile_mountstone_1 && tile <= tile_mountstone_6;
	}

	bool isTileDirt(u8 tile)
	{
		return tile >= tile_dirt_1 && tile < tile_dirt_grass ||
		       tile == tile_dark_solid;
	}

	bool isTileSand(u8 tile)
	{
		return tile >= tile_sand_1 && tile < tile_sand_grass;
	}

	//destructible
	bool isTileDestructible(u8 tile)
	{
		//return true;
		//return !isTileTypeBackground(tile);
		return isTileWoodBridge(tile) ||
		       tile >= tile_planks_moss_under && tile <= tile_planks_broken ||
		       tile >= tile_crate_1 && tile <= tile_crate_4 ||
		       tile == tile_rubble ||
		       isTileBush(tile) && tile != tile_bgbushdecor_leaves &&
		       !(tile >= tile_mountain_grass && tile <= tile_grass_tuft_cave) ||
		       tile >= tile_flower_1 && tile <= tile_flower_dark_2 ||
		       isTileCactus(tile);
	}

	bool isTileSolidForAutoTile(u8 tile)
	{
		return isTileDirt(tile) ||
		       isTileSand(tile) ||
		       isTileStone(tile) && !isTileDestructible(tile) ||
		       isTileWoodBridge(tile) ||
		       isTileRoof(tile) ||
		       isTileBunker(tile) ||
		       tile >= tile_snow_1 && tile <= tile_snow_6 ||
		       tile == tile_swamp_bed_1 || tile == tile_swamp_bed_2 ||
		       tile >= tile_mountstone_1 && tile <= tile_mountstone_6;
	}

	bool isTileWoodBridge(u8 tile)
	{
		return tile >= tile_woodbridge && tile <= tile_woodbridge_bottom ||
		       tile >= tile_planks_moss_under && tile <= tile_planks_broken;
	}

	bool isTileMostLikelyCandidate(u8 tile)
	{
		return tile >= tile_bgdecor_door_horiz && tile <= tile_bgdecor_wire ||
		       tile == tile_black_background ||
		       tile == tile_ladder ||
		       tile == tile_ladder_top ||
		       tile == tile_bgbushdecor_trunk;
	}

	bool isTileForRough(u8 tile)
	{
		return isTileBush(tile) ||
		       isTileDirt(tile) ||
		       tile == tile_bgbushdecor_leaves ||
		       tile == tile_dirt_grass ||
		       tile >= tile_mountstone_1 && tile <= tile_mountstone_6 ||
		       tile == tile_black_background ||
		       tile == tile_rubble_background ||
		       isTileFiddlyBackground(tile);
	}

	//all the specific background edge crap
	bool isTileFiddlyBackground(u8 tile)
	{
		return tile >= tile_dirtdecor_floor_1 && tile <= tile_dirtdecor_wall ||
		       tile == tile_sand_decor_curve_dark ||
		       tile == tile_mountstone_under_bg_1 ||
		       tile == tile_mountstone_under_bg_2 ||
		       tile >= tile_mountstone_over_bg_1 && tile <= tile_mountstone_side_bg ||
		       tile >= tile_sand_dark_floor && tile <= tile_sand_dark_wall;
	}

	bool isTileAutoDecor(u8 tile)
	{
		return tile >= tile_bgdecor_door_horiz && tile <= tile_bgdecor_wire ||
		       isTileTypeLadder(tile); //hack
	}

	bool isTileForDepth(u8 tile)
	{
		return isTileDirt(tile) ||
		       isTileSand(tile) ||
		       isTileMountainStone(tile) ||
		       isTileSwamp(tile) ||
		       isTileSnow(tile);
	}

	bool isTileSwamp(u8 tile)
	{
		return tile == tile_swamp_bed_1 ||
		       tile == tile_swamp_bed_2;
	}

	bool isTileSnow(u8 tile)
	{
		return tile >= tile_snow_1 && tile <= tile_snow_6;
	}

	//falling
	bool canTileFall(u8 tile)
	{
		return tile >= tile_crate_1 && tile <= tile_crate_4;
	}

	bool givesSupport(u8 tile)
	{
		return isTileTypeSolid(tile);
	}

	bool canGroundVault(u8 tile)
	{
		return isTileTypeSolid(tile) && !canTileFall(tile);
	}

	//////////////////////////////
	// helpers

	TileType getTileBackgroundAt(CMap@ map, u32 index)
	{
		bool nothingabove = (index < map.tilemapwidth);
		if (!nothingabove)
		{
			u8 type = map.getTile(index - map.tilemapwidth).type;
			nothingabove = (type == tile_empty || type >= tile_rough_backedge && type <= tile_rough_blind);
		}
		return nothingabove ? tile_empty : tile_black_background;
	}

	u8 getTile(u32 x, u32 y)
	{
		CMap@ map = getMap();
		if (map is null) return 0;

		return map.getTile(offsetAt(map, x, y)).type;
	}

	void setTile(u32 x, u32 y, u8 type)
	{
		CMap@ map = getMap();
		if (map is null) return;

		map.server_SetTile(getTilePosition(map, x, y), type);
	}

	u32 offsetAt(CMap@ map, u32 x, u32 y)
	{
		return x + y * map.tilemapwidth;
	}

	u32 offsetAt(CMap@ map, Vec2f pos)
	{
		u32 x = pos.x / map.tilesize;
		u32 y = pos.y / map.tilesize;
		return offsetAt(map, x, y);
	}

	Vec2f getTilePosition(CMap@ map, u32 offset)
	{
		u32 x = offset % map.tilemapwidth;
		u32 y = offset / map.tilemapwidth;
		return Vec2f(x * map.tilesize, y * map.tilesize);
	}

	Vec2f getTilePosition(CMap@ map, u32 x, u32 y)
	{
		return Vec2f(x * map.tilesize, y * map.tilesize);
	}

	Vec2f getNearestTileCentrePos(CMap@ map, Vec2f pos)
	{
		Vec2f tpos;
		tpos.x = int(pos.x / map.tilesize) * map.tilesize + 0.5f * map.tilesize;
		tpos.y = int(pos.y / map.tilesize) * map.tilesize + 0.5f * map.tilesize;
		return tpos;
	}

}
