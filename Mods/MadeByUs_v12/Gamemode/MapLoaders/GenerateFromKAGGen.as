// generates from a KAGGen config
// fileName is "" on client!

#include "LoaderUtilities.as";

bool loadMap(CMap@ _map, const string& in filename)
{
	CMap@ map = _map;

	if (!getNet().isServer() || filename == "")
	{
		SetupMap(map, 0, 0);
		SetupBackgrounds(map);
		return true;
	}

	Random@ map_random = Random(map.getMapSeed());

	Noise@ map_noise = Noise(map_random.Next());

	Noise@ material_noise = Noise(map_random.Next());

	//read in our config stuff -----------------------------

	ConfigFile cfg = ConfigFile(filename);

	//boring vars
	s32 width = cfg.read_s32("m_width", m_width);
	s32 height = cfg.read_s32("m_height", m_height);

	s32 baseline = cfg.read_s32("baseline", 50);
	s32 baseline_tiles = height * (1.0f - (baseline / 100.0f));

	s32 deviation = cfg.read_s32("deviation", 20);

	//margin for teams
	s32 map_margin = cfg.read_s32("map_margin", 30);
	s32 lerp_distance = cfg.read_s32("lerp_distance", 30);

	//erosion
	s32 erode_cycles = cfg.read_s32("erode_cycles", 10);

	//purturbation vars
	f32 purturb = cfg.read_f32("purturb", 5.0f);
	f32 purt_scale = cfg.read_f32("purt_scale", 0.0075);
	f32 purt_width = cfg.read_f32("purt_width", deviation);
	if (purt_width <= 0)
		purt_width = deviation;

	//cave vars
	Random@ cave_random = Random(map.getMapSeed() ^ 0xff00);
	Noise@ cave_noise = Noise(cave_random.Next());

	f32 cave_amount = cfg.read_f32("cave_amount", 0.2f);
	f32 cave_amount_var = cfg.read_f32("cave_amount_var", 0.1f);
	if (cave_amount > 0)
		cave_amount = Maths::Min(1.0f, Maths::Max(0.0f, cave_amount + cave_amount_var * (cave_random.NextFloat() - 0.5f)));

	f32 cave_scale = cfg.read_f32("cave_scale", 5.0f);
	cave_scale = 1.0f / Maths::Max(cave_scale, 0.001);

	f32 cave_detail_amp = cfg.read_f32("cave_detail_amp", 0.5f);
	f32 cave_distort = cfg.read_f32("cave_distort", 2.0f);
	f32 cave_width = cfg.read_f32("cave_width", 0.5f);
	f32 cave_lerp = cfg.read_f32("cave_lerp", 10.0f);
	if (cave_width <= 0)
		cave_width = 0;

	f32 cave_depth = cfg.read_f32("cave_depth", 20.0f);
	f32 cave_depth_var = cfg.read_f32("cave_depth_var", 10.0f);
	cave_depth += cave_depth_var * (cave_random.NextFloat() - 0.5f);

	cave_width *= width; //convert from ratio to tiles

	//ruins vars

	Random@ ruins_random = Random(map.getMapSeed() ^ 0x8ff000);

	s32 ruins_count = cfg.read_f32("ruins_count", 3);
	s32 ruins_count_var = cfg.read_f32("ruins_count_var", 2);
	s32 ruins_size = cfg.read_f32("ruins_size", 10);
	f32 ruins_width = cfg.read_f32("ruins_width", 0.5f);

	if (ruins_count > 0)
	{
		// do variation
		ruins_count += ruins_random.NextRanged(ruins_count_var + 1) - ruins_count_var / 2;
		//convert from ratio to tiles
		ruins_width *= width;
	}

	int SeaLevel = height/4*3;
	
	//done with vars! --------------------------------

	SetupMap(map, width, height);

	//gen heightmap
	array<int> heightmap(width);
	
	array<int> biome(width);
	//0 - forest/normal (grass/trees/bushes/ect)
	//1 - desert (grain/more gold)
	//2 - meadow (grass/flowers)
	//3 - Caves (Big overhead cave/cliff)

	for(int dbl = 0; dbl < 2; dbl += 1){ getNet().server_KeepConnectionsAlive();
		int LastHeight = height/3*2;
		
		int Straight = 4;
		int Crazy = 0;
		int Uphill = 0;
		int Downhill = 0;
		int CliffUp = 0;
		int CliffDown = 0;
		
		int CliffChange = 0;
		
		int LastType = 0;
		
		int CurrentBiome = 2; //Always start with meadow
		int CaveLengthBuffer = 0; //This is to force caves to be above 50 wide
		
		int start = width/2;
		int add = 1;
		if(dbl > 0)add = -1;
		for (int x = start; 1 != 0; x += add){ getNet().server_KeepConnectionsAlive();
			if(x >= width || x < 0)break;
			
			CaveLengthBuffer += 1;
			
			if(Straight == 0 && Crazy == 0 && Uphill == 0 && Downhill == 0 && CliffUp == 0 && CliffDown == 0){
				
				if(LastType == 0)
					if(XORRandom(10) == 0){
						CurrentBiome = 3;
						CaveLengthBuffer = 0;
					}
					
				if(CaveLengthBuffer > 50+XORRandom(50) && CurrentBiome == 3){
					CurrentBiome = XORRandom(3);
					CaveLengthBuffer = 0;
				}
				
				if(LastType == 0)LastType = XORRandom(4); //If last was stright, anything but cliff
				else if(LastType == 4)LastType = 1+XORRandom(3); //If last was cliff, anything but cliffs and straights
				else if(CurrentBiome == 3)LastType = XORRandom(4); //If cave biome, anything but cliff
				else LastType = XORRandom(5); // RANDOM!!!!1!
				
				switch(LastType){
					case 0:{
						Straight = 1+XORRandom(9);
					break;}
					case 1:{
						Crazy = XORRandom(20);
					break;}
					case 2:{
						Uphill = 5+XORRandom(15);
					break;}
					case 3:{
						Downhill = 5+XORRandom(15);
					break;}
					case 4:{
						if(CliffChange == 0){
							if(XORRandom(2) == 0)CliffUp = 5+XORRandom(10);
							else CliffDown = 5+XORRandom(10);
						}
						if(CliffChange > 0){
							CliffDown = 5+XORRandom(10);
						}
						if(CliffChange < 0){
							CliffUp = 5+XORRandom(10);
						}
						
						CliffChange += CliffUp-CliffDown;
						
						
						CurrentBiome = XORRandom(3); //Cliffs are a good time to do biome changes ;)
						
					break;}
				}
			}
			
			if(Straight > 0){
				heightmap[x] = LastHeight;
				if(Straight > 4)if(XORRandom(3) == 0)heightmap[x] += XORRandom(3)-1;
				Straight--;
			} else
			if(Uphill > 0){
				heightmap[x] = LastHeight;
				if(XORRandom(3) == 0)heightmap[x] -= XORRandom(2);
				Uphill--;
			} else
			if(Downhill > 0){
				heightmap[x] = LastHeight;
				if(XORRandom(3) == 0)heightmap[x] += XORRandom(2);
				Downhill--;
			} else
			if(CliffDown > 0){
				heightmap[x] = LastHeight+(XORRandom(4)+1);
				CliffDown--;
			} else
			if(CliffUp > 0){
				heightmap[x] = LastHeight-(XORRandom(4)+1);
				CliffUp--;
			} else {
				heightmap[x] = LastHeight;
				if(XORRandom(2) == 0)heightmap[x] += XORRandom(3)-1;
				if(Crazy > 0)Crazy--;
			}
			
			LastHeight = heightmap[x];
			biome[x] = CurrentBiome;
		}
	}
	
	//server_CreateBlob("ruins", -1, Vec2f(width/2*8,heightmap[width/2]*8-32));
	
	u8[][] World;
	
	for(int i = 0; i < width; i += 1){ //Init world grid
		u8[] temp;
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			temp.push_back(0);
		}
		World.push_back(temp);
	}
	
	for(int i = 0; i < width; i += 1) //Dirty stones!
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			if(biome[i] == 3){ //Caves need special code~
				//On second note, this code is evil beyond all belief, don't touch it.
				
				f32 Divide = 1;
				
				if(i > 3)if(biome[i-4] != 3)Divide = 0.8;
				if(i > 2)if(biome[i-3] != 3)Divide = 0.6;
				if(i > 1)if(biome[i-2] != 3)Divide = 0.4;
				if(i > 0)if(biome[i-1] != 3)Divide = 0.2;

				if(i < width-4)if(biome[i+4] != 3)Divide = 0.8;
				if(i < width-3)if(biome[i+3] != 3)Divide = 0.6;
				if(i < width-2)if(biome[i+2] != 3)Divide = 0.4;
				if(i < width-1)if(biome[i+1] != 3)Divide = 0.2;
				
				int Change = 5+XORRandom(2);
				Change += Maths::Abs(12-(i % 24));
				Change = Change/4;
				
				
				if(j > (heightmap[i]-20)-(Change*Divide)-5*Divide && j < (heightmap[i]-20)+((Change*2+XORRandom(4))*Divide)-5*Divide)
					World[i][j] = CMap::tile_ground;
				else
					if(j >= (heightmap[i]-20)+((Change*2)*Divide)-5*Divide){
						int Top = (heightmap[i]-20)+((Change*2)*Divide)-5*Divide;
						int Bottom = heightmap[i];
						int Length = Bottom-Top;
						if(j <= Top+((Divide)*(Length/2+1)) || j >= Bottom-((Divide)*(Length/2+1)))
						World[i][j] = CMap::tile_ground_back;
					}
						
			}
			
			if(heightmap[i] <= j){
				World[i][j] = CMap::tile_ground;
				int Depth = j-heightmap[i];
				if(Depth > 3){
					if(XORRandom(2) == 0){
						switch(XORRandom(3)){
							case 0: {
								World[i][j] = CMap::tile_stone;
							break;}
							case 1: {
								World[i][j] = CMap::tile_stone_d1;
							break;}
							case 2: {
								World[i][j] = CMap::tile_stone_d0;
							break;}
						}
					}
				}
				
				if(Depth > 6){
					if(XORRandom(3) == 0){
						switch(XORRandom(3)){
							case 0: {
								World[i][j] = CMap::tile_thickstone;
							break;}
							case 1: {
								World[i][j] = CMap::tile_thickstone_d1;
							break;}
							case 2: {
								World[i][j] = CMap::tile_thickstone_d0;
							break;}
						}
					}
				}
				
				if(j > SeaLevel){
					if(XORRandom(10) == 0){
						World[i][j] = CMap::tile_gold;
					} else if(biome[i] == 1)
					if(XORRandom(3) == 0){
						World[i][j] = CMap::tile_gold;
					}
				}
				
				if(j == height-1){
					World[i][j] = CMap::tile_ground_back;
				}
				if(j == height-2){
					World[i][j] = CMap::tile_ground_back;
				}
				if(j == height-3){
					World[i][j] = CMap::tile_gold;
				}
				if(j == height-4){
					if(XORRandom(3) > 0)World[i][j] = CMap::tile_bedrock;
					else World[i][j] = CMap::tile_gold;
				}
				if(j == height-5){
					if(XORRandom(2) == 0)World[i][j] = CMap::tile_bedrock;
					else World[i][j] = CMap::tile_gold;
				}
				if(j == height-6){
					if(XORRandom(3) == 0)World[i][j] = CMap::tile_bedrock;
				}
			}
	}

	
	
	///////////////////////////////////////////Nature/////////////////////////////////////////////////
	
	for(int i = 0; i < width; i += 1) //Plants \o/
		for(int j = 0; j < height-1; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == 0 && World[i][j+1] == CMap::tile_ground)if(j < SeaLevel){
				if(biome[i] == 0 || biome[i] == 3){ //Grass
					if(XORRandom(2) == 0){
						World[i][j] = CMap::tile_grass + XORRandom(4);
					}
				}
				if(biome[i] == 2){ //Grass
					World[i][j] = CMap::tile_grass + XORRandom(4);
				}
				
				if(biome[i] == 0 || biome[i] == 3) //Trees
				if(XORRandom(4) == 0){
					CBlob@ tree = server_CreateBlobNoInit((j < height/3) ? "tree_pine" : "tree_bushy");
					if (tree !is null)
					{
						tree.Tag("startbig");
						tree.setPosition(Vec2f(i*8,j*8));
						tree.Init();
					}
				}
				
				if(biome[i] == 2) //Rare chance for trees in meadows. This is incase world gen screws up and decides only meadows.
				if(XORRandom(40) == 0){
					CBlob@ tree = server_CreateBlobNoInit((j < height/3) ? "tree_pine" : "tree_bushy");
					if (tree !is null)
					{
						tree.Tag("startbig");
						tree.setPosition(Vec2f(i*8,j*8));
						tree.Init();
					}
				}
				
				if(biome[i] == 0 || biome[i] == 3)if(XORRandom(20) == 0){ //Flowers
					CBlob@ plant = server_CreateBlobNoInit("flowers");
					if (plant !is null)
					{
						plant.Tag("instant_grow");
						plant.setPosition(Vec2f(i*8,j*8));
						plant.Init();
					}
				}
				
				if(biome[i] == 0 || biome[i] == 3)if(XORRandom(2) == 0){ //Bushes
					CBlob@ plant = server_CreateBlobNoInit("bush");
					if (plant !is null)
					{
						plant.Tag("instant_grow");
						plant.setPosition(Vec2f(i*8,j*8));
						plant.Init();
					}
				}
				
				if(biome[i] == 1)if(XORRandom(10) == 0){ //Grain grows in the desert cause it's hipster like that.
					CBlob@ plant = server_CreateBlobNoInit("grain_plant");
					if (plant !is null)
					{
						plant.Tag("instant_grow");
						plant.setPosition(Vec2f(i*8,j*8));
						plant.Init();
					}
				}
				
				if(biome[i] == 2)if(XORRandom(3) == 0){ //LOTSA FLOWERS!! @.@
					CBlob@ plant = server_CreateBlobNoInit("flowers");
					if (plant !is null)
					{
						plant.Tag("instant_grow");
						plant.setPosition(Vec2f(i*8,j*8));
						plant.Init();
					}
					
					if(XORRandom(2) == 0){
						CBlob@ plant = server_CreateBlobNoInit("bush");
						if (plant !is null)
						{
							plant.Tag("instant_grow");
							plant.setPosition(Vec2f(i*8,j*8));
							plant.Init();
						}
					}
				}
				
				break;
			}
		}
	
	for(int i = 0; i < width; i += 1) //Start water dirt
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == 0 && j >= SeaLevel){
				if(i > 0)if(World[i-1][j] != 0 && World[i-1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)World[i][j] = CMap::tile_ground_back;
				if(j < height-2)if(World[i][j+1] != 0 && World[i][j+1] != CMap::tile_ground_back)if(XORRandom(2) == 0)World[i][j] = CMap::tile_ground_back;
				if(i < width-2)if(World[i+1][j] != 0 && World[i+1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)World[i][j] = CMap::tile_ground_back;
			}
	}
	
	for(int k = 0; k < 8; k += 1)
	for(int i = 1; i < width-1; i += 1) //Grow dirt in water
		for(int j = SeaLevel+1; j < height-1; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == CMap::tile_ground_back)if(XORRandom(4) == 0){
				if(World[i-1][j] == 0)if(XORRandom(2) == 0)World[i-1][j] = CMap::tile_ground_back;
				if(World[i][j+1] == 0)if(XORRandom(2) == 0)World[i][j+1] = CMap::tile_ground_back;
				if(World[i+1][j] == 0)if(XORRandom(2) == 0)World[i+1][j] = CMap::tile_ground_back;
				if(World[i][j-1] == 0)if(XORRandom(2) == 0)World[i][j-1] = CMap::tile_ground_back;
				if(World[i][j+1] != 0 && World[i][j+1] != CMap::tile_ground_back)
				if(World[i][j-1] == 0 || World[i][j-2] == 0 || World[i][j-3] == 0 || World[i][j-4] == 0 || World[i][j-5] == 0)
				if(XORRandom(7) == 0){ //Small chance for bushes "seaweed"
					CBlob@ plant = server_CreateBlobNoInit("bush");
					if (plant !is null)
					{
						plant.Tag("instant_grow");
						plant.setPosition(Vec2f(i*8,j*8));
						plant.Init();
					}
					if(XORRandom(20) == 0){ //Small chance for shark, otherwise, fishies!
						server_CreateBlob("shark",-1,Vec2f(i*8,j*8));
					} else {
						server_CreateBlob("fishy",-1,Vec2f(i*8,j*8));
					}
				}
			}
	}
	
	
	
	
	
	
	
	
	
	for(int i = 0; i < width; i += 1) //Set world
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			map.server_SetTile(Vec2f(i*8,j*8), World[i][j]);
			if(World[i][j] == 0 && j >= SeaLevel){
				map.server_setFloodWaterWorldspace(Vec2f(i*8,j*8),true);
				if(i > 0)if(World[i-1][j] != 0 && World[i-1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)map.server_SetTile(Vec2f(i*8,j*8), CMap::tile_ground_back);
				if(j < height-2)if(World[i][j+1] != 0 && World[i][j+1] != CMap::tile_ground_back)if(XORRandom(2) == 0)map.server_SetTile(Vec2f(i*8,j*8), CMap::tile_ground_back);
				if(i < width-2)if(World[i+1][j] != 0 && World[i+1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)map.server_SetTile(Vec2f(i*8,j*8), CMap::tile_ground_back);
			}
	}
	
	
	
	SetupBackgrounds(map);
	return true;
}

int GetRandomTunnelBackground(){

	switch(XORRandom(4)){
	
	case 0: return CMap::tile_ground_back;
	case 1: return CMap::tile_ground_back;
	case 2: return CMap::tile_castle_back;
	case 3: return CMap::tile_castle_back_moss;
	
	}
	return CMap::tile_ground_back;
}

int GetRandomCastleTile(){

	switch(XORRandom(2)){
	
	case 0: return CMap::tile_castle;
	case 1: return CMap::tile_castle_moss;
	
	}
	return CMap::tile_castle;
}


void SetupMap(CMap@ map, int width, int height)
{
	map.CreateTileMap(width, height, 8.0f, "Sprites/world.png");
}

void SetupBackgrounds(CMap@ map)
{
	// sky

	map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
	map.CreateSkyGradient("Sprites/skygradient.png");   // override sky color with gradient

	// plains

	map.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, 0.0f), Vec2f(0.3f, 0.3f), color_white);
	map.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  19.0f), Vec2f(0.4f, 0.4f), color_white);
	//map.AddBackground( "Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, 50.0f), Vec2f(0.5f, 0.5f), color_white );
	map.AddBackground("Sprites/Back/BackgroundCastle.png", Vec2f(0.0f, 50.0f), Vec2f(0.6f, 0.6f), color_white);

	// fade in
	SetScreenFlash(255, 0, 0, 0);

	SetupBlocks(map);
}

void SetupBlocks(CMap@ map)
{

}

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("GENERATING KAGGen MAP " + fileName);

	return loadMap(map, fileName);
}
