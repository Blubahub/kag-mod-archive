// generates from a TWGen config
// fileName is "" on client!
#include "MapCommon.as";
#include "LoadMapUtils.as";
 
bool loadMap( CMap@ _map, const string& in filename)
{
	CMap@ map = _map;

	if (!getNet().isServer() || filename == "")
	{
        TWMap::SetupMap(map,0,0);
        return true;
	}

	Random@ map_random = Random(map.getMapSeed());
	Noise@ map_noise = Noise(map_random.Next());
	//Noise@ material_noise = Noise(map_random.Next());

	ConfigFile cfg = ConfigFile(filename);

	//Load vars from the config file
	s32 width = cfg.read_s32("m_width",m_width);
	s32 height = cfg.read_s32("m_height",m_height);

	s32 baseline = cfg.read_s32("baseline",50);
	s32 baseline_tiles = height * (1.0f - (baseline/100.0f));

	s32 deviation = cfg.read_s32("deviation",20);

	

	TWMap::SetupMap(map, width, height);

	//Generate the heightmap based on the deviation

	array<int> heightmap(width);
	for(int x = 0; x < width; ++x)
	{
		heightmap[x] = baseline_tiles - deviation/2 +
						(map_noise.Fractal((x + 100)*0.05, 0) * deviation);
	}

	int blue_spawn_x = width * 0.1;
	int red_spawn_x = width * 0.9;
	int blue_spawn = blue_spawn_x + (heightmap[blue_spawn_x] - 2) * width;
	int red_spawn = red_spawn_x + (heightmap[red_spawn_x] - 2) * width;

	//fill the map with tiles

	for(int x = 0; x < width; ++x)
	{
		for(int y = 0; y < height; y++)
		{
			u32 offset = x + y*width;
			int row = (offset / map.tilemapwidth) % 2;
			int row_off = (map.tilemapwidth + 1) % 2;
			bool dither = (((row * row_off) + (offset % 2))%2) == 0;
			if(y >= heightmap[x]) // all of this here is placed after the else part
			{
				if((y - heightmap[x]) == 0)
				{
					if(XORRandom(10) <= 4) 
					{
						map.SetTile(offset, TWMap::tile_dirt_grass);
						map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
						switch(XORRandom(12)) // Make it even less likely by putting higher values here
						{
							case 0:
								map.SetTile(offset - width, TWMap::tile_fgbushdecor_grass_up);
								map.AddTileFlag(offset - width, Tile::LADDER);
								map.RemoveTileFlag(offset - width, Tile::SOLID | Tile::COLLISION | Tile::BACKGROUND); // that's why we have to remove these flags set by the boxes/rocks in the else part
								break;
							case 1:
								map.SetTile(offset - width, TWMap::tile_fgbushdecor_tuft_up);
								map.AddTileFlag(offset - width, Tile::LADDER);
								map.RemoveTileFlag(offset - width, Tile::SOLID | Tile::COLLISION | Tile::BACKGROUND);
								break;
							case 2:
								map.SetTile(offset - width, TWMap::tile_bgbushdecor_leaves);
								map.AddTileFlag(offset - width, Tile::LADDER | Tile::BACKGROUND);
								map.RemoveTileFlag(offset - width, Tile::SOLID | Tile::COLLISION);
								break;
							default:
							    // Do nothing
						}
					}
					else
					{
						map.SetTile(offset, dither ? TWMap::tile_dirtedge_1 : TWMap::tile_dirtedge_2 );
						map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
					}

				}
				else if((y - heightmap[x]) > 0 && (y - heightmap[x]) <= 3)
				{
					map.SetTile(offset, dither ? TWMap::tile_dirt_1 : TWMap::tile_dirt_2);
					map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
				}
				else if((y - heightmap[x]) > 3 && (y - heightmap[x]) <= 5)
				{
					map.SetTile(offset, dither ? TWMap::tile_dirt_3 : TWMap::tile_dirt_4);
					map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
				}
				else if((y - heightmap[x]) > 5 && (y - heightmap[x]) <= 7)
				{
					map.SetTile(offset, dither ? TWMap::tile_dirt_5 : TWMap::tile_dirt_6);
					map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
				}
				else if((y - heightmap[x]) > 7)
				{
					map.SetTile(offset, TWMap::tile_dark_solid);
					map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
				}
				
			}
			else // all the stuff above/on the ground level
			{
				if((y - heightmap[x]) == -1)
				{
					if((XORRandom(20)%2)==1)
					{
						switch(XORRandom(9)) // Make it even less likely by putting higher values here
						{
							case 0:
								map.SetTile(offset, TWMap::tile_crate_1);
								map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
								break;
							case 1:
								map.SetTile(offset, TWMap::tile_crate_2);
								map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
								break;
							case 2:
								map.SetTile(offset, TWMap::tile_dirtdecor_1);
								map.AddTileFlag(offset, Tile::BACKGROUND);
								break;
							case 3:
								map.SetTile(offset, TWMap::tile_dirtdecor_2);
								map.AddTileFlag(offset, Tile::BACKGROUND);
								break;
							case 4:
								map.SetTile(offset, TWMap::tile_dirtdecor_3);
								map.AddTileFlag(offset, Tile::BACKGROUND);
								break;
							default:
							    // Do nothing
						}
					}
				}
			}
		}
	}

	AddSpawnMarkers(map, blue_spawn, red_spawn);

	return true;
}

bool LoadMap(CMap@ map, const string& in fileName)
{
    print("GENERATING TWGen MAP " + fileName);
    client_AddToChat(RandomMapName());
    return loadMap(map, fileName);
}

string RandomMapName()
{
	ConfigFile cfg;
	string str;
	if (cfg.loadFile( "Rules/Campaign/RandomMapName.cfg")) 
	{
		//vars
		string wars = cfg.read_string("wars");
		string battles = cfg.read_string("battles");
		string descriptions = cfg.read_string("descriptions");
		string[]@ warsArray = wars.split(";");
		string[]@ battlesArray = battles.split(";");
		string[]@ descriptionsArray = descriptions.split(";");

		//create the string
		str = "War: " + warsArray[XORRandom(warsArray.length)] + "\nBattle: " + battlesArray[XORRandom(battlesArray.length)] + "\nDescription: " + descriptionsArray[XORRandom(descriptionsArray.length)];
	}
	else 
		str = "NoName War";
	return str;
}

void AddSpawnMarkers(CMap@ _map, int _blue_spawn, int _red_spawn)
{
	AddMarker(_map, _blue_spawn, "blue spawn");
	AddMarker(_map, _red_spawn, "red spawn");
	//make sure that nothing is in the way
	// _map.SetTile(_blue_spawn + _map.tilemapwidth, TWMap::tile_empty);
	// _map.RemoveTileFlag(_blue_spawn + _map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::BACKGROUND | Tile::LADDER);
	// _map.SetTile(_blue_spawn + _map.tilemapwidth, TWMap::tile_empty);
	// _map.RemoveTileFlag(_blue_spawn + _map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::BACKGROUND | Tile::LADDER);
	// _map.SetTile(_red_spawn + _map.tilemapwidth, TWMap::tile_empty);
	// _map.RemoveTileFlag(_red_spawn + _map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::BACKGROUND  | Tile::LADDER);
}