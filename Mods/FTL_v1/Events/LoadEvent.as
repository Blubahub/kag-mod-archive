
#include "LoaderColors.as";

const SColor color_airlock(0xffFF643C);

const SColor color_room1x1(0xff838383);
const SColor color_room2x1(0xff848484);
const SColor color_room1x2(0xff858585);
const SColor color_room2x2(0xff868686);

const SColor color_reactor(0xffff3737);
const SColor color_pilot_seat(0xffff6414);
const SColor color_oxygen(0xff3264FF);


bool loadEvent(CMap@ map, const string& in filename, int team)
{

	print("Loading new event!");

	CFileImage@ image = CFileImage( filename );

	//TODO: Swap planet background
	
	if(image.isLoaded())
	{
	
		while(image.nextPixel())
		{
			//print("processing: "+image.getPixelPosition().x+","+image.getPixelPosition().y);
			
			SColor pixel = image.readPixel();
			Vec2f offset = image.getPixelPosition()+Vec2f(getMap().tilemapwidth/2,0);
			
			offset = Vec2f(offset.x*8,offset.y*8);
			
			handlePixel(pixel, offset, team);

			getNet().server_KeepConnectionsAlive();
		}
		return true;
	}
	return false;
}

void handlePixel(SColor pixel, Vec2f offset, int team)
{
	u8 alpha = pixel.getAlpha();

	CMap @map = getMap();
	
	if(alpha < 255)
	{
		alpha &= ~0x80;
		SColor rgb = SColor(0xFF, pixel.getRed(), pixel.getGreen(), pixel.getBlue());
		const Vec2f position = offset;

		//print(" ARGB = "+alpha+", "+rgb.getRed()+", "+rgb.getGreen()+", "+rgb.getBlue());

		// BLOCKS
		if(rgb == ladder)
		{
			spawnBlob(map, "ladder", team, position, 0, true);
			
		}
		else if(rgb == spikes)
		{
			spawnBlob(map, "spikes", team, position, true);
			
		}
		else if(rgb == stone_door)
		{
			spawnBlob(map, "stone_door", team, position, 0, true);
			
		}
		else if(rgb == trap_block)
		{
			spawnBlob(map, "trap_block", team, position, true);
			
		}
		else if(rgb == wooden_door)
		{
			spawnBlob(map, "wooden_door", team, position, 0, true);
			
		}
		else if(rgb == wooden_platform)
		{
			spawnBlob(map, "wooden_platform", team, position, 0, true);
			
		}
		// NATURAL
		else if(rgb == stalagmite)
		{
			CBlob@ blob = spawnBlob(map, "stalagmite", 255, position, 0, true);
			blob.set_u8("state", 1); // Spike::stabbing
			
		}
	}
	else if(pixel == color_tile_ground)
	{
		map.server_SetTile(offset, CMap::tile_ground);
	}
	else if(pixel == color_tile_ground_back)
	{
		map.server_SetTile(offset, CMap::tile_ground_back);
	}
	else if(pixel == color_tile_stone)
	{
		map.server_SetTile(offset, CMap::tile_stone);
	}
	else if(pixel == color_tile_thickstone)
	{
		map.server_SetTile(offset, CMap::tile_thickstone);
	}
	else if(pixel == color_tile_bedrock)
	{
		map.server_SetTile(offset, CMap::tile_bedrock);
	}
	else if(pixel == color_tile_gold)
	{
		map.server_SetTile(offset, CMap::tile_gold);
	}
	else if(pixel == color_tile_castle)
	{
		map.server_SetTile(offset, CMap::tile_castle);
	}
	else if(pixel == color_tile_castle_back)
	{
		map.server_SetTile(offset, CMap::tile_castle_back);
	}
	else if(pixel == color_tile_castle_moss)
	{
		map.server_SetTile(offset, CMap::tile_castle_moss);
	}
	else if(pixel == color_tile_castle_back_moss)
	{
		map.server_SetTile(offset, CMap::tile_castle_back_moss);
	}
	else if(pixel == color_tile_wood)
	{
		map.server_SetTile(offset, CMap::tile_wood);
	}
	else if(pixel == color_tile_wood_back)
	{
		map.server_SetTile(offset, CMap::tile_wood_back );
	}
	else if(pixel == color_tile_grass)
	{
		map.server_SetTile(offset, CMap::tile_grass+XORRandom(3));
	}
	else if(pixel == color_water_air)
	{
		map.server_setFloodWaterWorldspace(offset, true);
	}
	else if(pixel == color_water_backdirt)
	{
		map.server_setFloodWaterWorldspace(offset, true);
		map.server_SetTile(offset, CMap::tile_ground_back);
	}
	else if(pixel == color_princess)
	{
		spawnBlob(map, "princess", offset, team, false);
		
	}
	else if(pixel == color_necromancer)
	{
		spawnBlob( map, "necromancer", offset, team, false);
		
	}
	else if (pixel == color_knight_shop)
	{
		spawnBlob( map, "knightshop", offset, 255);
	}
	else if (pixel == color_builder_shop)
	{
		spawnBlob( map, "buildershop", offset, 255);
		
	}
	else if (pixel == color_archer_shop)
	{
		spawnBlob( map, "archershop", offset, 255);
		
	}
	else if (pixel == color_boat_shop)
	{
		spawnBlob( map, "boatshop", offset, 255);
		
	}
	else if(pixel == color_vehicle_shop)
	{
		spawnBlob(map, "vehicleshop", offset, 255);
		
	}
	else if(pixel == color_quarters)
	{
		spawnBlob(map, "quarters", offset, 255);
		
	}
	else if(pixel == color_storage_noteam)
	{
		spawnBlob(map, "storage", offset, 255);
		
	}
	else if(pixel == color_barracks_noteam)
	{
		spawnBlob(map, "barracks", offset, 255);
		
	}
	else if(pixel == color_factory_noteam)
	{
		spawnBlob(map, "factory", offset, 255);
		
	}
	else if(pixel == color_tunnel_blue)
	{
		spawnBlob(map, "tunnel", offset, 0);
		
	}
	else if(pixel == color_tunnel_red)
	{
		spawnBlob(map, "tunnel", offset, 1);
		
	}
	else if(pixel == color_tunnel_noteam)
	{
		spawnBlob(map, "tunnel", offset, 255);
		
	}
	else if(pixel == color_kitchen)
	{
		spawnBlob(map, "kitchen", offset, 255);
		
	}
	else if(pixel == color_nursery)
	{
		spawnBlob(map, "nursery", offset, 255);
		
	}
	else if(pixel == color_research)
	{
		spawnBlob(map, "research", offset, 255);
		
	}
	else if(pixel == color_workbench)
	{
		spawnBlob(map, "workbench", offset, -1, true);
		
	}
	else if(pixel == color_campfire)
	{
		spawnBlob(map, "fireplace", offset, -1, true, Vec2f(0.0f, -4.0f));
		
	}
	else if(pixel == color_saw)
	{
		spawnBlob( map, "saw", offset, -1, false);
		
	}
	else if (pixel == color_flowers)
	{
		spawnBlob( map, "flowers", offset, -1);
		
	}
	else if (pixel == color_log)
	{
		spawnBlob( map, "log", offset, -1);
		
	}
	else if (pixel == color_shark)
	{
		spawnBlob( map, "shark", offset, -1);
		
	}
	else if (pixel == color_fish)
	{
		CBlob@ fishy = spawnBlob( map, "fishy", offset, -1);
		if (fishy !is null)
		{
			fishy.set_u8("age", (offset.x * 997) % 4 );
		}
		
	}
	else if (pixel == color_bison)
	{
		spawnBlob( map, "bison", offset, -1, false);
		
	}
	else if (pixel == color_chicken)
	{
		spawnBlob( map, "chicken", offset, -1, false);
		
	}
	else if (pixel == color_platform_up)
	{
		spawnBlob( map, "wooden_platform", offset, 255, true );
		
	}
	else if (pixel == color_platform_right)
	{
		CBlob@ blob = spawnBlob(map, "wooden_platform", offset, 255, false);
		
		blob.setAngleDegrees(90.0f);
		blob.getShape().SetStatic(true);
	}
	else if (pixel == color_platform_down)
	{
		CBlob@ blob = spawnBlob( map, "wooden_platform", offset, 255, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 180.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_platform_left)
	{
		CBlob@ blob = spawnBlob( map, "wooden_platform", offset, 255, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( -90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_wooden_door_h_blue)
	{
		spawnBlob( map, "wooden_door", offset, 0, true );
		
	}
	else if (pixel == color_wooden_door_v_blue)
	{
		CBlob@ blob = spawnBlob( map, "wooden_door", offset, 0, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_wooden_door_h_red)
	{
		spawnBlob( map, "wooden_door", offset, 1, true );
		
	}
	else if (pixel == color_wooden_door_v_red)
	{
		CBlob@ blob = spawnBlob( map, "wooden_door", offset, 1, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_wooden_door_h_noteam)
	{
		spawnBlob( map, "wooden_door", offset, 255, true );
		
	}
	else if (pixel == color_wooden_door_v_noteam)
	{
		CBlob@ blob = spawnBlob( map, "wooden_door", offset, 255, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_stone_door_h_blue)
	{
		spawnBlob( map, "stone_door", offset, 0, true );
		
	}
	else if (pixel == color_stone_door_v_blue)
	{
		CBlob@ blob = spawnBlob( map, "stone_door", offset, 0, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_stone_door_h_red)
	{
		spawnBlob( map, "stone_door", offset, 1, true );
		
	}
	else if (pixel == color_stone_door_v_red)
	{
		CBlob@ blob = spawnBlob( map, "stone_door", offset, 1, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_stone_door_h_noteam)
	{
		spawnBlob( map, "stone_door", offset, 255, true );
		
	}
	else if (pixel == color_stone_door_v_noteam)
	{
		CBlob@ blob = spawnBlob( map, "stone_door", offset, 255, false );
		
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
	}
	else if (pixel == color_trapblock_blue)
	{
		spawnBlob( map, "trap_block", offset, 0, true);
		
	}
	else if (pixel == color_trapblock_red)
	{
		spawnBlob( map, "trap_block", offset, 1, true);
		
	}
	else if (pixel == color_trapblock_noteam)
	{
		spawnBlob( map, "trap_block", offset, 255, true );
		
	}
	else if(pixel == chest)
	{
		spawnBlob(map, "chest", 255, offset);
		
	}
	else if (pixel == color_drill)
	{
		spawnBlob( map, "drill", offset, -1);
		
	}
	else if (pixel == color_trampoline)
	{
		CBlob@ trampoline = server_CreateBlobNoInit("trampoline");
		if (trampoline !is null)
		{
			trampoline.setPosition(offset);
			trampoline.Init();
		}
		
	}
	else if (pixel == color_lantern)
	{
		spawnBlob( map, "lantern", offset, -1, true);
		
	}
	else if (pixel == color_crate)
	{
		spawnBlob( map, "crate", offset, -1);
		
	}
	else if (pixel == color_bucket)
	{
		spawnBlob( map, "bucket", offset, -1);
		
	}
	else if (pixel == color_sponge)
	{
		spawnBlob( map, "sponge", offset, -1);
		
	}
	else if (pixel == color_steak)
	{
		spawnBlob( map, "steak", offset, -1);
		
	}
	else if (pixel == color_burger)
	{
		spawnBlob( map, "food", offset, -1);
		
	}
	else if (pixel == color_heart)
	{
		spawnBlob( map, "heart", offset, -1);
		
	}
	else if (pixel == color_mountedbow)
	{
		spawnBlob( map, "mounted_bow", offset, -1, true, Vec2f(0.0f, 4.0f));
		
	}
	else if (pixel == color_waterbombs)
	{
		spawnBlob( map, "mat_waterbombs", offset, -1);
		
	}
	else if (pixel == color_arrows)
	{
		spawnBlob( map, "mat_arrows", offset, -1);
		
	}
	else if (pixel == color_bombarrows)
	{
		spawnBlob( map, "mat_bombarrows", offset, -1);
		
	}
	else if (pixel == color_waterarrows)
	{
		spawnBlob( map, "mat_waterarrows", offset, -1);
		
	}
	else if (pixel == color_firearrows)
	{
		spawnBlob( map, "mat_firearrows", offset, -1);
		
	}
	else if (pixel == color_bolts)
	{
		spawnBlob( map, "mat_bolts", offset, -1);
		
	}
	else if (pixel == color_blue_mine)
	{
		spawnBlob( map, "mine", offset, 0);
		
	}
	else if (pixel == color_red_mine)
	{
		spawnBlob( map, "mine", offset, 1);
		
	}
	else if (pixel == color_mine_noteam)
	{
		spawnBlob( map, "mine", offset, -1);
		
	}
	else if (pixel == color_boulder)
	{
		spawnBlob( map, "boulder", offset, -1, false, Vec2f(8.0f, -8.0f));
		
	}
	else if (pixel == color_satchel)
	{
		spawnBlob( map, "satchel", offset, -1);
		
	}
	else if (pixel == color_keg)
	{
		spawnBlob( map, "keg", offset, -1);
		
	}
	else if (pixel == color_gold)
	{
		spawnBlob( map, "mat_gold", offset, -1);
		
	}
	else if (pixel == color_stone)
	{
		spawnBlob( map, "mat_stone", offset, -1);
		
	}
	else if (pixel == color_wood)
	{
		spawnBlob( map, "mat_wood", offset, -1);
		
	}
	else if(pixel == color_dummy)
	{
		spawnBlob(map, "dummy", offset, 1, true);
		
	}
	else if (pixel == color_airlock)
	{
		spawnBlob(map, "airlock", offset+Vec2f(4,4), team, true);
	}
	else if (pixel == color_room1x1)
	{
		spawnBlob(map, "onebyoneroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_room2x1)
	{
		spawnBlob(map, "twobyoneroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_room1x2)
	{
		spawnBlob(map, "onebytworoom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_room2x2)
	{
		spawnBlob(map, "twobytworoom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_reactor)
	{
		spawnBlob(map, "reactorroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_pilot_seat)
	{
		spawnBlob(map, "pilots_seat", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_oxygen)
	{
		spawnBlob(map, "oxygen_generator", offset+Vec2f(4,4), team);
	}
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position)
{
	CBlob@ blob = server_CreateBlob(name, team, position);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, const bool fixed)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, u16 angle)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, u16 angle, const bool fixed)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, Vec2f offset, int team, bool attached_to_map, Vec2f posOffset)
{
	CBlob@ blob = server_CreateBlob(name, team, offset + posOffset);
	if(blob !is null && attached_to_map)
	{
		blob.getShape().SetStatic( true );
	}
	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, Vec2f offset, int team, bool attached_to_map = false)
{
	return spawnBlob(map, name, offset, team, attached_to_map, Vec2f_zero);
}