// BasePNGLoader.as
// NSFL if you don't unzoom it out in your editor

// Note for modders upgrading their mod, handlePixel's signature has changed recently!

#include "LoaderColors.as";
#include "LoaderUtilities.as";
#include "CustomBlocks.as";

enum ZeldaOffset
{
	autotile_offset = 0,
  tangrass_offset,
  post_offset,
  bar_offset,
  wall_offset,
  housewall_offset,
  houseentrance_offset,
  grass_offset,
  chimney_offset,
  greenroof_offset,
  redroof_offset,
  blueroof_offset,
  tree_offset,
  bush_offset,
  sign_offset,
  tallgrass_offset,
  solidrock_offset,
  palmtree_offset,
	
	offsets_count
};

enum zeldacolors
{
  
  color_post = 0xFFC09000,
  color_water = 0xFF0000ec,
  color_bar = 0xFF0090e0,
  color_wall = 0xFFf0c828,
  color_housewall = 0xFFc09034,
  color_houseentrance = 0xFF201420,
  color_tangrass = 0xFFf8f838,
  color_grass = 0xFFc0f838,
  color_pathway = 0xFFf0c028,
  color_stairs = 0xFFf82840,
  color_blueroof = 0xFF50e0f8,
  color_redroof = 0xFFa82858,
  color_greenroof = 0xFF60c800,
  color_chimney = 0xFFc0905c,
  color_tree = 0xFF7dab33,
  color_point = 0xFF00FF00,
  color_bush = 0xFF646400,
  color_sign = 0xFFb12900,
  color_tallgrass = 0xFF257f15,
  color_solidrock = 0xFF999999,
  color_palmtree = 0xFF275e33,
  color_plantera = 0xFFf8f88f,
  color_healthpack_1 = 0xFFFE0000,
  color_healthpack_0 = 0xFF0000FE,
}

//global
Random@ map_random = Random();

class PNGLoader
{
	PNGLoader()
	{
		offsets = int[][](offsets_count, int[](0));
	}

	CFileImage@ image;
	CMap@ map;

	int[][] offsets;

	int current_offset_count;

	bool loadMap(CMap@ _map, const string& in filename)
	{
		@map = _map;
		@map_random = Random();

		if(!getNet().isServer())
		{
			SetupMap(0, 0, map.getMapName().replace("Maps","Sprites").replace(".png", "World.png"));
			SetupBackgrounds();

			return true;
		}
    print("##################" + map.getMapName().replace("Maps","Sprites").replace(".png", "World.png"));
		@image = CFileImage( filename );

		if(image.isLoaded())
		{
			SetupMap(image.getWidth(), image.getHeight(),map.getMapName().replace("Maps","Sprites").replace(".png", "World.png"));
			SetupBackgrounds();

			while(image.nextPixel())
			{
				const SColor pixel = image.readPixel();
				const int offset = image.getPixelOffset();

				// Optimization: check if the pixel color is the sky color
				// We do this before calling handlePixel because it is overriden, and to avoid a SColor copy
				if (pixel.color != map_colors::sky)
				{
					handlePixel(pixel, offset);
				}

				getNet().server_KeepConnectionsAlive();
			}

			// late load - after placing tiles
			for(uint i = 0; i < offsets.length; ++i)
			{
				int[]@ offset_set = offsets[i];
				current_offset_count = offset_set.length;
				for(uint step = 0; step < current_offset_count; ++step)
				{
					handleOffset(i, offset_set[step], step, current_offset_count);
					getNet().server_KeepConnectionsAlive();
				}
			}
			return true;
		}
		return false;
	}
	
	// Queue an offset to be autotiled
	void autotile(int offset)
	{
		offsets[autotile_offset].push_back(offset);
	}

	void handlePixel(const SColor &in pixel, int offset)
	{	
		u8 alpha = pixel.getAlpha();
		
		
    switch (pixel.color)
		{
			case zeldacolors::color_post:          offsets[post_offset].push_back(offset);         break;
			case zeldacolors::color_bar:          offsets[bar_offset].push_back(offset);         break;
			case zeldacolors::color_wall:          offsets[wall_offset].push_back(offset);         break;
			case zeldacolors::color_housewall:          offsets[housewall_offset].push_back(offset);         break;
			case zeldacolors::color_chimney:          offsets[chimney_offset].push_back(offset);         break;
			case zeldacolors::color_redroof:          offsets[redroof_offset].push_back(offset);         break;
			case zeldacolors::color_greenroof:          offsets[greenroof_offset].push_back(offset);         break;
			case zeldacolors::color_blueroof:          offsets[blueroof_offset].push_back(offset);         break;
			case zeldacolors::color_houseentrance:          offsets[houseentrance_offset].push_back(offset);         break;
			case zeldacolors::color_grass:          offsets[grass_offset].push_back(offset);         break;
			case zeldacolors::color_bush:          offsets[bush_offset].push_back(offset);         break;
			case zeldacolors::color_solidrock:          offsets[solidrock_offset].push_back(offset);         break;
			case zeldacolors::color_tallgrass:          offsets[tallgrass_offset].push_back(offset);         break;
			case zeldacolors::color_sign:          offsets[sign_offset].push_back(offset);         break;
			case zeldacolors::color_palmtree:          offsets[palmtree_offset].push_back(offset);         break;
			case zeldacolors::color_point:   
        spawnBlob(map,"point",offset);       
        map.SetTile(offset, map.getTile(offset - 1 ).type );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );  
      break;
      case zeldacolors::color_plantera:   
        spawnBlob(map,"plantera",offset);       
        map.SetTile(offset, map.getTile(offset - 1 ).type );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );  
      break;
      case zeldacolors::color_healthpack_0:   
        spawnBlob(map,"healthpack",offset,0);       
        map.SetTile(offset, map.getTile(offset - 1 ).type );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );  
      break;
      case zeldacolors::color_healthpack_1:   
        spawnBlob(map,"healthpack",offset,1);       
        map.SetTile(offset, map.getTile(offset - 1 ).type );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );  
      break;
			case zeldacolors::color_tree:          
        offsets[tree_offset].push_back(offset); 
      break;
			case zeldacolors::color_tangrass:   offsets[tangrass_offset].push_back(offset);  break;
      case zeldacolors::color_stairs:          
        map.SetTile(offset, CMap::zelda_stairs );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );      
      break;
      case zeldacolors::color_pathway:          
        map.SetTile(offset, CMap::zelda_pathway );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );      
      break;
      case zeldacolors::color_water:          
        map.SetTile(offset, CMap::zelda_water );
        map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
        map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );      
      break;
			
			case map_colors::blue_main_spawn:   autotile(offset); AddMarker(map, offset, "blue main spawn"); break;
			case map_colors::red_main_spawn:    autotile(offset); AddMarker(map, offset, "red main spawn");  break;
			// Normal spawns
			case map_colors::blue_spawn:     autotile(offset); AddMarker(map, offset, "blue spawn");   break;
			case map_colors::red_spawn:      autotile(offset); AddMarker(map, offset, "red spawn");    break;
			
		}
	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		switch (type)
		{
    case post_offset:
			PlacePost(map, offset);
		break;
    case tangrass_offset:
			PlaceTanGrass(map, offset);
		break;
    case bush_offset:
			PlaceBush(map, offset);
		break;
    case palmtree_offset:
			PlacePalmTree(map, offset);
		break;
    case sign_offset:
			PlaceSign(map, offset);
		break;
    case solidrock_offset:
			PlaceSolidRock(map, offset);
		break;
    case tallgrass_offset:
			PlaceTallGrass(map, offset);
		break;
    case tree_offset:
			BuildTree(map, offset);
		break;
    case grass_offset:
			HandleGrass(map, offset);
		break;
    case bar_offset:
			PlaceBar(map, offset);
		break;
    case wall_offset:
			PlaceWall(map, offset);
		break;
    case housewall_offset:
			PlaceHouseWall(map, offset);
		break;
    case houseentrance_offset:
			PlaceHouseEntrance(map, offset);
		break;
    case chimney_offset:
			PlaceChimney(map, offset);
		break;
    case redroof_offset:
			PlaceRoofRed(map, offset);
		break;
    case blueroof_offset:
			PlaceRoofBlue(map, offset);
		break;
    case greenroof_offset:
			PlaceRoofGreen(map, offset);
		break;
		
		};
	}

	void SetupMap(int width, int height, string mapName)
	{
		map.CreateTileMap(width, height, 8.0f, mapName);
	}

	void SetupBackgrounds()
	{
		// sky
		map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("Sprites/skygradient.png"); // override sky color with gradient

		// background
		map.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		map.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
		map.AddBackground("Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);

		// fade in
		SetScreenFlash(255,   0,   0,   0);
	}
  
  bool isThere( int offset, int offsettype) {
    if(offsettype == grass_offset)
    {
      const TileType thistile = map.getTile(offset ).type;
      if(isThere(offset, tallgrass_offset) || isThere(offset, houseentrance_offset) || isThere(offset, bar_offset) || isThere(offset, housewall_offset) || isThere(offset, redroof_offset) || isThere(offset, greenroof_offset) || isThere(offset, blueroof_offset))
        return true;
      else
      {
        const TileType thistile = map.getTile(offset ).type;
        if(thistile == CMap::zelda_stairs)
         return true;
        else if(thistile == CMap::zelda_pathway)
         return true;
      }
    }
    return (offsets[offsettype].find(offset) != -1);
  }
  
  void PlaceWall(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool left = isThere(offset -1, wall_offset), up = isThere(offset - map.tilemapwidth, wall_offset), right = isThere(offset +1, wall_offset), down = isThere(offset + map.tilemapwidth, wall_offset);
      amount += left ? 1 : 0;
      amount += up ? 1 : 0;
      amount += down ? 1 : 0;
      amount += right ? 1 : 0;
      if(amount == 4) 
      {
        const TileType lefttile = map.getTile(offset - 1).type;
        if( lefttile ==  CMap::zelda_wallcornerrise || lefttile ==  CMap::zelda_wallcorner || lefttile ==  CMap::tile_empty ||  lefttile == CMap::zelda_wallinnercorner || lefttile == CMap::zelda_wallflipped)
        {
          map.SetTile(offset, CMap::zelda_wall);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (lefttile ==  CMap::zelda_wall)
        {
          map.SetTile(offset, CMap::zelda_wallflipped);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else
        {
          map.SetTile(offset, CMap::zelda_wall);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
      }
      else if( amount == 3)
      {
        if(!left) 
        {
          if( isThere(offset - 1,bar_offset)) {
            map.SetTile(offset, CMap::zelda_sidewall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
          }
          else
          {
            map.SetTile(offset, CMap::zelda_wallcornerrise);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
        }
        else if(!right) 
        {
          if( isThere(offset + 1,bar_offset)) {
            map.SetTile(offset, CMap::zelda_sidewall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
          else
          {
            map.SetTile(offset, CMap::zelda_wallcornerrise);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
          }
        }
        else if(!up) 
        {
          const TileType lefttile = map.getTile(offset - 1).type;
          if( lefttile ==  CMap::zelda_wallcornerrise || lefttile ==  CMap::tile_empty  || lefttile ==  CMap::zelda_wallcorner||  lefttile == CMap::zelda_wallinnercorner || lefttile == CMap::zelda_wallflipped)
          {
            map.SetTile(offset, CMap::zelda_wall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
          else if (lefttile ==  CMap::zelda_wall)
          {
            map.SetTile(offset, CMap::zelda_wallflipped);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
          else
          {
            map.SetTile(offset, CMap::zelda_wall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
        }
        else if(!down) 
        {
          const TileType uptile = map.getTile(offset - map.tilemapwidth).type;
          if(uptile == CMap::zelda_wallflipped)
          {
            map.SetTile(offset, CMap::zelda_wall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
          else if (uptile ==  CMap::zelda_wall)
          {
            map.SetTile(offset, CMap::zelda_wallflipped);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
          else
          {
            map.SetTile(offset, CMap::zelda_wall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
        }
        
      }
      else if (amount == 2)
      {
        if(up && down)
        {
          if( isThere(offset - 1,bar_offset)) {
            map.SetTile(offset, CMap::zelda_sidewall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
          }
          else
          {
            map.SetTile(offset, CMap::zelda_sidewall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
        }
        else if (left && right) 
        {
          if(isThere(offset + map.tilemapwidth,redroof_offset) || isThere(offset - map.tilemapwidth,bar_offset) ||  isThere(offset + map.tilemapwidth,chimney_offset) ||  isThere(offset + map.tilemapwidth,greenroof_offset) ||  isThere(offset + map.tilemapwidth,blueroof_offset) )
          {
            const TileType lefttile = map.getTile(offset - 1).type;
            if( lefttile ==  CMap::zelda_wallcornerrise || lefttile ==  CMap::zelda_wallcorner || lefttile ==  CMap::tile_empty ||  lefttile == CMap::zelda_wallinnercorner || lefttile == CMap::zelda_wallflipped)
            {
              map.SetTile(offset, CMap::zelda_wall);
              map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
            }
            else if (lefttile ==  CMap::zelda_wall)
            {
              map.SetTile(offset, CMap::zelda_wallflipped);
              map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
            }
            else
            {
              map.SetTile(offset, CMap::zelda_wall);
              map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
            }
          }
          else
          {
            map.SetTile(offset, CMap::zelda_sidewall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::ROTATE);
          }
        }
        else if (isThere(offset - 1, bar_offset) ||  isThere(offset + 1, bar_offset))
        {
          if(up && left) 
          {
            map.SetTile(offset, CMap::zelda_wallinnercorner);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::ROTATE);
          }
          else if(up && right) 
          {
            map.SetTile(offset, CMap::zelda_wallinnercorner);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::ROTATE | Tile::MIRROR);
          }
          else if(down && right) 
          {
            map.SetTile(offset, CMap::zelda_wallinnercorner);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
          }
          else if(down && left) 
          {
            map.SetTile(offset, CMap::zelda_wallinnercorner);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
        }
        else if(up && left) 
        {
          map.SetTile(offset, CMap::zelda_wallcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if(up && right) 
        {
          map.SetTile(offset, CMap::zelda_wallcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if(down && right) 
        {
          if(isThere(offset - map.tilemapwidth, bar_offset))
          {
            map.SetTile(offset, CMap::zelda_wallcornerrise);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }
          else
          {
            map.SetTile(offset, CMap::zelda_cornerupwall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
          }  
        }
        else if(down && left) 
        {
          if(isThere(offset - map.tilemapwidth, bar_offset))
          {
            map.SetTile(offset, CMap::zelda_wallcornerrise);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
          }
          else
          {
            map.SetTile(offset, CMap::zelda_cornerupwall);
            map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
          }  
        }
      }  
      
    }
  }
  
  void PlaceBar(CMap@ map, int offset)
  {
    const TileType up = map.getTile(offset - map.tilemapwidth).type;
    const TileType left = map.getTile(offset - 1).type;
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool left = false, up = false, right = false, down = false, br = false;
      int[]@ bars = offsets[bar_offset];
      for (uint step = 0; step < bars.length; ++step)
      {
        const int bof = bars[step];
          if (bof == offset+map.tilemapwidth) {
            down = true;
            amount += 1;
          }
          if (bof == offset+map.tilemapwidth + 1) {
            br = true;
          }
          if (bof == offset+1) {
            right = true;
            amount += 1;
          }
          if (bof == offset-1) {
            left = true;
            amount += 1;
          }
          if (bof == offset-map.tilemapwidth) {
            up = true;
            amount += 1;
          }
      }
      if(right && down && br)
      {
        map.SetTile(offset, CMap::zelda_barend);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::ROTATE);
        map.SetTile(offset + 1, CMap::zelda_barend);
        map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION | Tile::ROTATE);
        map.SetTile(offset + map.tilemapwidth , CMap::zelda_barendraised);
        map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::ROTATE | Tile::FLIP);
        map.SetTile(offset + map.tilemapwidth + 1, CMap::zelda_barendraised);
        map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION | Tile::ROTATE | Tile::FLIP);
      }
      else if (amount == 1)
      {
        if(up)
        {
          map.SetTile(offset , CMap::zelda_barendraised);
          map.AddTileFlag( offset , Tile::SOLID | Tile::COLLISION | Tile::ROTATE | Tile::FLIP);
        }
        else if(right)
        {
          map.SetTile(offset, CMap::zelda_barend);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if(left)
        {
          map.SetTile(offset , CMap::zelda_barend);
          map.AddTileFlag( offset , Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if(down)
        {
          map.SetTile(offset, CMap::zelda_barend);
          map.AddTileFlag( offset , Tile::SOLID | Tile::COLLISION | Tile::ROTATE);
        }
      }
      else if (amount == 2)
      {
        if(up && down) 
        {
          map.SetTile(offset, CMap::zelda_bar);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::ROTATE);
        }
        else if (right && left) 
        {
          map.SetTile(offset, CMap::zelda_bar);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (up && left) 
        {
          map.SetTile(offset, CMap::zelda_barcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if (up && right) 
        {
          map.SetTile(offset, CMap::zelda_barcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION);
        }
        else if (down && right) 
        {
          map.SetTile(offset, CMap::zelda_barcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::FLIP);
        }
        else if (down && left) 
        {
          map.SetTile(offset, CMap::zelda_barcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::FLIP | Tile::MIRROR);
        }
      }
    }
  }
  
  void HandleGrass(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool left = isThere(offset -1, grass_offset), up = isThere(offset - map.tilemapwidth, grass_offset), right = isThere(offset +1, grass_offset), down = isThere(offset + map.tilemapwidth, grass_offset);
      amount += left ? 1 : 0;
      amount += up ? 1 : 0;
      amount += down ? 1 : 0;
      amount += right ? 1 : 0;
      
      if (amount == 4)
      {
        if(offset % 4 == 0 && XORRandom(2) >= 1)
        {
          map.SetTile(offset, CMap::zelda_grasstuff );
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );   
        }
        else if(offset % 2 == 0 && XORRandom(2) >= 1)
        {
          map.SetTile(offset, CMap::zelda_grasstuff );
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR );   
        }
        else
        {
          map.SetTile(offset, CMap::zelda_grass );
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );    
        }
        
      }
      else if (amount == 3)
      {
        if(!up) 
        {
          map.SetTile(offset, CMap::zelda_tanside);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::ROTATE);
        }
        else if (!right) 
        {
          map.SetTile(offset, CMap::zelda_tanside);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR);
        }
        else if (!left) 
        {
          map.SetTile(offset, CMap::zelda_tanside);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
        }
        else if (!down) 
        {
          map.SetTile(offset, CMap::zelda_tanside);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::ROTATE | Tile::FLIP);
        }
      }
      else if (amount == 2) 
      {
        if( up && left)
        {
          map.SetTile(offset, CMap::zelda_tancorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR);
        }
        else if( up && right)
        {
          map.SetTile(offset, CMap::zelda_tancorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
        }
        else if( down && right)
        {
          map.SetTile(offset, CMap::zelda_tancorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::FLIP);
        }
        else if( down && left)
        {
          map.SetTile(offset, CMap::zelda_tancorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::FLIP |  Tile::MIRROR);
        }
      }
    }
  }
  
  void PlaceTanGrass(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type; 
    const bool right = map.getTile(offset + 1).type == CMap::zelda_water;
    const bool left = map.getTile(offset - 1).type == CMap::zelda_water;
    const bool down = map.getTile(offset + map.tilemapwidth ).type == CMap::zelda_water;
    const bool up = map.getTile(offset - map.tilemapwidth ).type == CMap::zelda_water;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      amount += left ? 1 : 0;
      amount += up ? 1 : 0;
      amount += down ? 1 : 0;
      amount += right? 1 : 0;
      
      if (amount == 0)
      {
        bool ul = map.getTile(offset - 1 - map.tilemapwidth).type == CMap::zelda_water;
        bool ur = map.getTile(offset + 1 - map.tilemapwidth).type == CMap::zelda_water;
        bool br = map.getTile(offset + 1 + map.tilemapwidth).type == CMap::zelda_water;
        bool bl = map.getTile(offset - 1 + map.tilemapwidth).type == CMap::zelda_water;
        if(ul)
        {
          map.SetTile(offset, CMap::zelda_edge_topinner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  ); 
        }
        else if(ur)
        {
          map.SetTile(offset, CMap::zelda_edge_topinner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR ); 
        }
        else if(br)
        {
          map.SetTile(offset, CMap::zelda_edge_lowinner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES ); 
        }
        else if(bl)
        {
          map.SetTile(offset, CMap::zelda_edge_lowinner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR ); 
        }
        else if(offset % 4 == 0)
        {
          map.SetTile(offset, CMap::zelda_tangrasstuff );
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );   
        }
        else if(offset % 2 == 0)
        {
          map.SetTile(offset, CMap::zelda_tangrasstuff );
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR );   
        }
        else
        {
          map.SetTile(offset, CMap::zelda_tangrass );
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );   
        }
        
      }
      else if (amount == 1)
      {
        if(up) 
        {
          map.SetTile(offset, CMap::zelda_edge_topedge);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES);
        }
        else if (right) 
        {
          map.SetTile(offset, CMap::zelda_edge_sideedge);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
        }
        else if (left) 
        {
          map.SetTile(offset, CMap::zelda_edge_sideedge);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR);
        }
        else if (down) 
        {
          map.SetTile(offset, CMap::zelda_edge_lowedge);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES);
        }
      }
      else if (amount == 2) 
      {
        if( up && left)
        {
          map.SetTile(offset, CMap::zelda_edge_topcorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
        }
        else if( up && right)
        {
          map.SetTile(offset, CMap::zelda_edge_topcorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::MIRROR);
        }
        else if( down && right)
        {
          map.SetTile(offset, CMap::zelda_edge_lowcorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES );
        }
        else if( down && left)
        {
          map.SetTile(offset, CMap::zelda_edge_lowcorner);
          map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
          map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES |  Tile::MIRROR);
        }
      }
    }
  }
  
  void PlaceRoofRed(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool left = (isThere(offset -1, redroof_offset) || isThere(offset -1, chimney_offset)), up = (isThere(offset - map.tilemapwidth, redroof_offset) || isThere(offset - map.tilemapwidth, chimney_offset)), right = (isThere(offset +1, redroof_offset) || isThere(offset +1, chimney_offset)), down = (isThere(offset + map.tilemapwidth, redroof_offset)|| isThere(offset + map.tilemapwidth, chimney_offset));
      amount += left ? 1 : 0;
      amount += up ? 1 : 0;
      amount += down ? 1 : 0;
      amount += right ? 1 : 0;
      
      if (amount == 4)
      {
        map.SetTile(offset, CMap::zelda_redroof);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      }
      else if (amount == 3)
      {
        if(!up) 
        {
          map.SetTile(offset, CMap::zelda_redroofback);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (!right) 
        {
          map.SetTile(offset, CMap::zelda_redroofside);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if (!left) 
        {
          map.SetTile(offset, CMap::zelda_redroofside);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (!down) 
        {
          map.SetTile(offset, CMap::zelda_redrooffront);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
      }
      else if (amount == 2) 
      {
        if( up && left)
        {
          map.SetTile(offset, CMap::zelda_redrooffrontcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if( up && right)
        {
          map.SetTile(offset, CMap::zelda_redrooffrontcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if( down && right)
        {
          map.SetTile(offset, CMap::zelda_redroofbackcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if( down && left)
        {
          map.SetTile(offset, CMap::zelda_redroofbackcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
      }
    }
  }
  
  void PlaceRoofGreen(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool left = (isThere(offset -1, greenroof_offset) || isThere(offset -1, chimney_offset)), up = (isThere(offset - map.tilemapwidth, greenroof_offset) || isThere(offset - map.tilemapwidth, chimney_offset)), right = (isThere(offset +1, greenroof_offset) || isThere(offset +1, chimney_offset)), down = (isThere(offset + map.tilemapwidth, greenroof_offset)|| isThere(offset + map.tilemapwidth, chimney_offset));
      amount += left ? 1 : 0;
      amount += up ? 1 : 0;
      amount += down ? 1 : 0;
      amount += right ? 1 : 0;
      
      if (amount == 4)
      {
        map.SetTile(offset, CMap::zelda_greenroof);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      }
      else if (amount == 3)
      {
        if(!up) 
        {
          map.SetTile(offset, CMap::zelda_greenroofback);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (!right) 
        {
          map.SetTile(offset, CMap::zelda_greenroofside);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if (!left) 
        {
          map.SetTile(offset, CMap::zelda_greenroofside);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (!down) 
        {
          map.SetTile(offset, CMap::zelda_greenrooffront);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
      }
      else if (amount == 2) 
      {
        if( up && left)
        {
          map.SetTile(offset, CMap::zelda_greenrooffrontcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if( up && right)
        {
          map.SetTile(offset, CMap::zelda_greenrooffrontcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if( down && right)
        {
          map.SetTile(offset, CMap::zelda_greenroofbackcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if( down && left)
        {
          map.SetTile(offset, CMap::zelda_greenroofbackcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
      }
    }
  }
  
  void PlaceRoofBlue(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool left = (isThere(offset -1, blueroof_offset) || isThere(offset -1, chimney_offset)), up = (isThere(offset - map.tilemapwidth, blueroof_offset) || isThere(offset - map.tilemapwidth, chimney_offset)), right = (isThere(offset +1, blueroof_offset) || isThere(offset +1, chimney_offset)), down = (isThere(offset + map.tilemapwidth, blueroof_offset)|| isThere(offset + map.tilemapwidth, chimney_offset));
      amount += left ? 1 : 0;
      amount += up ? 1 : 0;
      amount += down ? 1 : 0;
      amount += right ? 1 : 0;
      
      if (amount == 4)
      {
        map.SetTile(offset, CMap::zelda_blueroof);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      }
      else if (amount == 3)
      {
        if(!up) 
        {
          map.SetTile(offset, CMap::zelda_blueroofback);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (!right) 
        {
          map.SetTile(offset, CMap::zelda_blueroofside);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if (!left) 
        {
          map.SetTile(offset, CMap::zelda_blueroofside);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if (!down) 
        {
          map.SetTile(offset, CMap::zelda_bluerooffront);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
      }
      else if (amount == 2) 
      {
        if( up && left)
        {
          map.SetTile(offset, CMap::zelda_bluerooffrontcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
        else if( up && right)
        {
          map.SetTile(offset, CMap::zelda_bluerooffrontcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if( down && right)
        {
          map.SetTile(offset, CMap::zelda_blueroofbackcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        }
        else if( down && left)
        {
          map.SetTile(offset, CMap::zelda_blueroofbackcorner);
          map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        }
      }
    }
  }
  
  void PlaceHouseWall(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool  right = false, down = false, br = false;
      int[]@ housewalls = offsets[housewall_offset];
      for (uint step = 0; step < housewalls.length; ++step)
      {
        const int hwof = housewalls[step];
          if (hwof == offset+map.tilemapwidth) {
            down = true;
          }
          if (hwof == offset+map.tilemapwidth + 1) {
            br = true;
          }
          if (hwof == offset+1) {
            right = true;
          }
      }
      if(right && down && br)
      {
        map.SetTile(offset, CMap::zelda_housewalltop);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        map.SetTile(offset + 1, CMap::zelda_housewalltop);
        map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        map.SetTile(offset + map.tilemapwidth , CMap::zelda_housewallbottom);
        map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
        map.SetTile(offset + map.tilemapwidth + 1, CMap::zelda_housewallbottom);
        map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      }
    }
  }
  void PlaceHouseEntrance(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool  right = false, down = false, br = false;
      int[]@ houseentrances = offsets[houseentrance_offset];
      for (uint step = 0; step < houseentrances.length; ++step)
      {
        const int heof = houseentrances[step];
          if (heof == offset+map.tilemapwidth) {
            down = true;
          }
          if (heof == offset+map.tilemapwidth + 1) {
            br = true;
          }
          if (heof == offset+1) {
            right = true;
          }
      }
      if(right && down && br)
      {
        map.SetTile(offset, CMap::zelda_houseentrancetop);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        map.SetTile(offset + 1, CMap::zelda_houseentrancetop);
        map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        map.SetTile(offset + map.tilemapwidth , CMap::zelda_houseentrancebottom);
        map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
        map.SetTile(offset + map.tilemapwidth + 1, CMap::zelda_houseentrancebottom);
        map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      }
    }
  }
  
  void PlaceChimney(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    int amount = 0;

    if (thistile == CMap::tile_empty)
    {
      bool  right = false, down = false, br = false;
      int[]@ chimneys = offsets[chimney_offset];
      for (uint step = 0; step < chimneys.length; ++step)
      {
        const int chof = chimneys[step];
          if (chof == offset+map.tilemapwidth) {
            down = true;
          }
          if (chof == offset+map.tilemapwidth + 1) {
            br = true;
          }
          if (chof == offset+1) {
            right = true;
          }
      }
      if(right && down && br)
      {
        map.SetTile(offset, CMap::zelda_chimneytop);
        map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
        map.SetTile(offset + 1, CMap::zelda_chimneytop);
        map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
        map.SetTile(offset + map.tilemapwidth , CMap::zelda_chimneybottom);
        map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
        map.SetTile(offset + map.tilemapwidth + 1, CMap::zelda_chimneybottom);
        map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      }
    }
  }
  
  void BuildTree(CMap@ map, int offset)
  {
    TileType topfarleft = map.getTile(offset - map.tilemapwidth - map.tilemapwidth - 1).type;
    if (topfarleft == CMap::zelda_tree_bottomright)
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth - 1, CMap::zelda_tree_backfarleft);
    else
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth - 1, CMap::zelda_tree_topfarleft);
    
    TileType topleft = map.getTile(offset - map.tilemapwidth - map.tilemapwidth ).type;
    if (topleft == CMap::zelda_tree_bottomfarright)
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth , CMap::zelda_tree_backleft);
    else
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth , CMap::zelda_tree_topleft);
    
    TileType topright = map.getTile(offset - map.tilemapwidth - map.tilemapwidth + 1).type;
    if (topright == CMap::zelda_tree_bottomfarleft)
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth + 1, CMap::zelda_tree_backright);
    else
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth + 1, CMap::zelda_tree_topright);
    
    TileType topfarright = map.getTile(offset - map.tilemapwidth - map.tilemapwidth + 2).type;
    if (topfarright == CMap::zelda_tree_bottomleft)
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth + 2, CMap::zelda_tree_backfarright);
    else
      PlaceSolidTile(map,offset - map.tilemapwidth - map.tilemapwidth + 2, CMap::zelda_tree_topfarright);
    
    TileType middlefarleft = map.getTile(offset  - map.tilemapwidth - 1).type;
    if (middlefarleft == CMap::zelda_tree_baseright)
      PlaceSolidTile(map,offset - map.tilemapwidth - 1, CMap::zelda_tree_behindfarleft);
    else
      PlaceSolidTile(map,offset  - map.tilemapwidth - 1, CMap::zelda_tree_middlefarleft);
    
    TileType middleleft = map.getTile(offset - map.tilemapwidth ).type;
    if (middleleft == CMap::zelda_tree_basefarright)
      PlaceSolidTile(map,offset - map.tilemapwidth , CMap::zelda_tree_behindleft);
    else
      PlaceSolidTile(map,offset  - map.tilemapwidth , CMap::zelda_tree_middleleft);
    
    TileType middleright = map.getTile(offset  - map.tilemapwidth + 1).type;
    if (middleright == CMap::zelda_tree_basefarleft)
      PlaceSolidTile(map,offset  - map.tilemapwidth + 1, CMap::zelda_tree_behindright);
    else
      PlaceSolidTile(map,offset  - map.tilemapwidth + 1, CMap::zelda_tree_middleright);
    
    TileType middlefarright = map.getTile(offset - map.tilemapwidth + 2).type;
    if (middlefarright == CMap::zelda_tree_baseleft)
      PlaceSolidTile(map,offset - map.tilemapwidth + 2, CMap::zelda_tree_behindfarright);
    else
      PlaceSolidTile(map,offset - map.tilemapwidth + 2, CMap::zelda_tree_middlefarright);
    
    PlaceSolidTile(map,offset + 2, CMap::zelda_tree_bottomfarright);
    PlaceSolidTile(map,offset + 1, CMap::zelda_tree_bottomright);
    PlaceSolidTile(map,offset, CMap::zelda_tree_bottomleft);
    PlaceSolidTile(map,offset - 1, CMap::zelda_tree_bottomfarleft);
    
    PlaceSolidTile(map,offset + map.tilemapwidth + 2, CMap::zelda_tree_basefarright);
    PlaceSolidTile(map,offset + map.tilemapwidth + 1, CMap::zelda_tree_baseright);
    PlaceSolidTile(map,offset + map.tilemapwidth, CMap::zelda_tree_baseleft);
    PlaceSolidTile(map,offset + map.tilemapwidth - 1, CMap::zelda_tree_basefarleft);
    
    
  }
  
  void PlaceSolidTile(CMap@ map, int offset, int tiletype)
  {
    map.SetTile(offset, tiletype);
    map.RemoveTileFlag( offset, Tile::MIRROR );
    map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
  }
  
  void PlaceBush(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    bool br = isThere(offset +1 + map.tilemapwidth, bush_offset);
    bool tr = isThere(offset +1 , bush_offset);
    bool bl = isThere(offset  + map.tilemapwidth, bush_offset);
    if (thistile == CMap::tile_empty && br && tr && bl)
    {
      map.SetTile(offset, CMap::zelda_bush_topleft);
      map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + 1, CMap::zelda_bush_topright);
      map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth, CMap::zelda_bush_bottomleft);
      map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth +1, CMap::zelda_bush_bottomright);
      map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION );
      
    }
  }
  
  void PlacePalmTree(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    bool br = isThere(offset +1 + map.tilemapwidth + map.tilemapwidth + map.tilemapwidth, palmtree_offset);
    bool tr = isThere(offset +1 , palmtree_offset);
    bool bl = isThere(offset  + map.tilemapwidth + map.tilemapwidth + map.tilemapwidth, palmtree_offset);
    if (thistile == CMap::tile_empty && br && tr && bl)
    {
      map.SetTile(offset, CMap::zelda_palmtree_top);
      map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth, CMap::zelda_palmtree_middle);
      map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth + map.tilemapwidth, CMap::zelda_palmtree_bottom);
      map.AddTileFlag( offset + map.tilemapwidth + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth + map.tilemapwidth + map.tilemapwidth, CMap::zelda_palmtree_base);
      map.AddTileFlag( offset + map.tilemapwidth + map.tilemapwidth + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + 1 , CMap::zelda_palmtree_top);
      map.AddTileFlag( offset + 1 , Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      
      map.SetTile(offset + 1  + map.tilemapwidth, CMap::zelda_palmtree_middle);
      map.AddTileFlag( offset + 1  + map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      
      map.SetTile(offset + 1  + map.tilemapwidth + map.tilemapwidth, CMap::zelda_palmtree_bottom);
      map.AddTileFlag( offset + 1  + map.tilemapwidth + map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      
      map.SetTile(offset + 1  + map.tilemapwidth + map.tilemapwidth + map.tilemapwidth, CMap::zelda_palmtree_base);
      map.AddTileFlag( offset + 1  + map.tilemapwidth + map.tilemapwidth + map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      
    }
  }
  
  void PlaceSign(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    bool br = isThere(offset +1 + map.tilemapwidth, sign_offset);
    bool tr = isThere(offset +1 , sign_offset);
    bool bl = isThere(offset  + map.tilemapwidth, sign_offset);
    if (thistile == CMap::tile_empty && br && tr && bl)
    {
      map.SetTile(offset, CMap::zelda_sign_top);
      map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + 1, CMap::zelda_sign_top);
      map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION | Tile::MIRROR );
      
      map.SetTile(offset + map.tilemapwidth, CMap::zelda_sign_bottom);
      map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION | Tile::MIRROR);
      
      map.SetTile(offset + map.tilemapwidth +1, CMap::zelda_sign_bottom);
      map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION );
      
    }
  }
  
  void PlaceTallGrass(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    bool br = isThere(offset +1 + map.tilemapwidth, tallgrass_offset);
    bool tr = isThere(offset +1 , tallgrass_offset);
    bool bl = isThere(offset  + map.tilemapwidth, tallgrass_offset);
    if (thistile == CMap::tile_empty && br && tr && bl)
    {
      map.SetTile(offset, CMap::zelda_tallgrass_topleft);
      map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES  );
      
      map.SetTile(offset + 1, CMap::zelda_tallgrass_topright);
      map.AddTileFlag( offset + 1, Tile::BACKGROUND | Tile::LIGHT_PASSES  );
      
      map.SetTile(offset + map.tilemapwidth, CMap::zelda_tallgrass_bottomleft);
      map.AddTileFlag( offset + map.tilemapwidth, Tile::BACKGROUND | Tile::LIGHT_PASSES  );
      
      map.SetTile(offset + map.tilemapwidth +1, CMap::zelda_tallgrass_bottomright);
      map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::BACKGROUND | Tile::LIGHT_PASSES );
      
    }
  }
  
  void PlaceSolidRock(CMap@ map, int offset)
  {
    const TileType thistile = map.getTile(offset ).type;
    bool br = isThere(offset +1 + map.tilemapwidth, solidrock_offset);
    bool tr = isThere(offset +1 , solidrock_offset);
    bool bl = isThere(offset  + map.tilemapwidth, solidrock_offset);
    if (thistile == CMap::tile_empty && br && tr && bl)
    {
      map.SetTile(offset, CMap::zelda_solidrock_topleft);
      map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + 1, CMap::zelda_solidrock_topright);
      map.AddTileFlag( offset + 1, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth, CMap::zelda_solidrock_bottomleft);
      map.AddTileFlag( offset + map.tilemapwidth, Tile::SOLID | Tile::COLLISION );
      
      map.SetTile(offset + map.tilemapwidth +1, CMap::zelda_solidrock_bottomright);
      map.AddTileFlag( offset + map.tilemapwidth + 1, Tile::SOLID | Tile::COLLISION );
      
    }
  }
  
}


void PlacePost(CMap@ map, int offset)
{
	const TileType thistile = map.getTile(offset ).type;
	const TileType up = map.getTile(offset - map.tilemapwidth).type;
	
	if (thistile == CMap::tile_empty)
	{
		if (up == CMap::zelda_posttop)
		{
			map.SetTile(offset, CMap::zelda_postbottom);
      map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
		}
		else 
    {
      map.SetTile(offset, CMap::zelda_posttop);
      map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
    }  
    
	}
}

Vec2f getSpawnPosition(CMap@ map, int offset)
{
	Vec2f pos = map.getTileWorldPosition(offset);
	f32 tile_offset = map.tilesize * 0.5f;
	pos.x += tile_offset;
	pos.y += tile_offset;
	return pos;
}

CBlob@ spawnHall(CMap@ map, int offset, u8 team)
{
	CBlob@ hall = spawnBlob(map, "hall", offset, team);
	if (hall !is null) // add research to first hall
	{
		hall.AddScript("Researching.as");
		hall.Tag("script added");
	}
	return @hall;
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position)
{
	return server_CreateBlob(name, team, position);
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position, const bool fixed)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position, s16 angle)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position, s16 angle, const bool fixed)
{
	CBlob@ blob = spawnBlob(map, name, team, position, angle);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, int offset, u8 team = 255, bool attached_to_map = false, Vec2f posOffset = Vec2f_zero, s16 angle = 0)
{
	return spawnBlob(map, name, team, getSpawnPosition(map, offset) + posOffset, angle, attached_to_map);
}

CBlob@ spawnVehicle(CMap@ map, const string& in name, int offset, int team = -1)
{
	CBlob@ blob = server_CreateBlob(name, team, getSpawnPosition( map, offset));
	if(blob !is null)
	{
		blob.RemoveScript("DecayIfLeftAlone.as");
	}
	return blob;
}

void AddMarker(CMap@ map, int offset, const string& in name)
{
	map.AddMarker(map.getTileWorldPosition(offset), name);
}

void SaveMap(CMap@ map, const string &in fileName)
{
	
}

void getInfoFromBlob(CBlob@ this, SColor &out color, Vec2f &out offset)
{
	
}

SColor getColorFromTileType(TileType tile)
{
	if(tile >= TILE_LUT.length)
	{
		return map_colors::unused;
	}
	return TILE_LUT[tile];
}

const SColor[] TILE_LUT = {
map_colors::unused,                // |   0 |
map_colors::unused,                // |   1 |
map_colors::unused,                // |   2 |
map_colors::unused,                // |   3 |
map_colors::unused,                // |   4 |
map_colors::unused,                // |   5 |
map_colors::unused,                // |   6 |
map_colors::unused,                // |   7 |
map_colors::unused,                // |   8 |
map_colors::unused,                // |   9 |
map_colors::unused,                // |  10 |
map_colors::unused,                // |  11 |
map_colors::unused,                // |  12 |
map_colors::unused,                // |  13 |
map_colors::unused,                // |  14 |
map_colors::unused,                // |  15 |
map_colors::tile_ground,           // |  16 |
map_colors::tile_ground,           // |  17 |
map_colors::tile_ground,           // |  18 |
map_colors::tile_ground,           // |  19 |
map_colors::tile_ground,           // |  20 |
map_colors::tile_ground,           // |  21 |
map_colors::tile_ground,           // |  22 |
map_colors::tile_ground,           // |  23 |
map_colors::tile_ground,           // |  24 |
map_colors::tile_grass,            // |  25 |
map_colors::tile_grass,            // |  26 |
map_colors::tile_grass,            // |  27 |
map_colors::tile_grass,            // |  28 |
map_colors::tile_ground,           // |  29 | damaged
map_colors::tile_ground,           // |  30 | damaged
map_colors::tile_ground,           // |  31 | damaged
map_colors::tile_ground_back,      // |  32 |
map_colors::tile_ground_back,      // |  33 |
map_colors::tile_ground_back,      // |  34 |
map_colors::tile_ground_back,      // |  35 |
map_colors::tile_ground_back,      // |  36 |
map_colors::tile_ground_back,      // |  37 |
map_colors::tile_ground_back,      // |  38 |
map_colors::tile_ground_back,      // |  39 |
map_colors::tile_ground_back,      // |  40 |
map_colors::tile_ground_back,      // |  41 |
map_colors::unused,                // |  42 |
map_colors::unused,                // |  43 |
map_colors::unused,                // |  44 |
map_colors::unused,                // |  45 |
map_colors::unused,                // |  46 |
map_colors::unused,                // |  47 |
map_colors::tile_castle,           // |  48 |
map_colors::tile_castle,           // |  49 |
map_colors::tile_castle,           // |  50 |
map_colors::tile_castle,           // |  51 |
map_colors::tile_castle,           // |  52 |
map_colors::tile_castle,           // |  53 |
map_colors::tile_castle,           // |  54 |
map_colors::unused,                // |  55 |
map_colors::unused,                // |  56 |
map_colors::unused,                // |  57 |
map_colors::tile_castle,           // |  58 | damaged
map_colors::tile_castle,           // |  59 | damaged
map_colors::tile_castle,           // |  60 | damaged
map_colors::tile_castle,           // |  61 | damaged
map_colors::tile_castle,           // |  62 | damaged
map_colors::tile_castle,           // |  63 | damaged
map_colors::tile_castle_back,      // |  64 |
map_colors::tile_castle_back,      // |  65 |
map_colors::tile_castle_back,      // |  66 |
map_colors::tile_castle_back,      // |  67 |
map_colors::tile_castle_back,      // |  68 |
map_colors::tile_castle_back,      // |  69 |
map_colors::unused,                // |  70 |
map_colors::unused,                // |  71 |
map_colors::unused,                // |  72 |
map_colors::unused,                // |  73 |
map_colors::unused,                // |  74 |
map_colors::unused,                // |  75 |
map_colors::tile_castle_back,      // |  76 | damaged
map_colors::tile_castle_back,      // |  77 | damaged
map_colors::tile_castle_back,      // |  78 | damaged
map_colors::tile_castle_back,      // |  79 | damaged
map_colors::tile_gold,             // |  80 |
map_colors::tile_gold,             // |  81 |
map_colors::tile_gold,             // |  82 |
map_colors::tile_gold,             // |  83 |
map_colors::tile_gold,             // |  84 |
map_colors::tile_gold,             // |  85 |
map_colors::unused,                // |  86 |
map_colors::unused,                // |  87 |
map_colors::unused,                // |  88 |
map_colors::unused,                // |  89 |
map_colors::tile_gold,             // |  90 | damaged
map_colors::tile_gold,             // |  91 | damaged
map_colors::tile_gold,             // |  92 | damaged
map_colors::tile_gold,             // |  93 | damaged
map_colors::tile_gold,             // |  94 | damaged
map_colors::unused,                // |  95 |
map_colors::tile_stone,            // |  96 |
map_colors::tile_stone,            // |  97 |
map_colors::unused,                // |  98 |
map_colors::unused,                // |  99 |
map_colors::tile_stone,            // | 100 | damaged
map_colors::tile_stone,            // | 101 | damaged
map_colors::tile_stone,            // | 102 | damaged
map_colors::tile_stone,            // | 103 | damaged
map_colors::tile_stone,            // | 104 | damaged
map_colors::unused,                // | 105 |
map_colors::tile_bedrock,          // | 106 |
map_colors::tile_bedrock,          // | 107 |
map_colors::tile_bedrock,          // | 108 |
map_colors::tile_bedrock,          // | 109 |
map_colors::tile_bedrock,          // | 110 |
map_colors::tile_bedrock,          // | 111 |
map_colors::unused,                // | 112 |
map_colors::unused,                // | 113 |
map_colors::unused,                // | 114 |
map_colors::unused,                // | 115 |
map_colors::unused,                // | 116 |
map_colors::unused,                // | 117 |
map_colors::unused,                // | 118 |
map_colors::unused,                // | 119 |
map_colors::unused,                // | 120 |
map_colors::unused,                // | 121 |
map_colors::unused,                // | 122 |
map_colors::unused,                // | 123 |
map_colors::unused,                // | 124 |
map_colors::unused,                // | 125 |
map_colors::unused,                // | 126 |
map_colors::unused,                // | 127 |
map_colors::unused,                // | 128 |
map_colors::unused,                // | 129 |
map_colors::unused,                // | 130 |
map_colors::unused,                // | 131 |
map_colors::unused,                // | 132 |
map_colors::unused,                // | 133 |
map_colors::unused,                // | 134 |
map_colors::unused,                // | 135 |
map_colors::unused,                // | 136 |
map_colors::unused,                // | 137 |
map_colors::unused,                // | 138 |
map_colors::unused,                // | 139 |
map_colors::unused,                // | 140 |
map_colors::unused,                // | 141 |
map_colors::unused,                // | 142 |
map_colors::unused,                // | 143 |
map_colors::unused,                // | 144 |
map_colors::unused,                // | 145 |
map_colors::unused,                // | 146 |
map_colors::unused,                // | 147 |
map_colors::unused,                // | 148 |
map_colors::unused,                // | 149 |
map_colors::unused,                // | 150 |
map_colors::unused,                // | 151 |
map_colors::unused,                // | 152 |
map_colors::unused,                // | 153 |
map_colors::unused,                // | 154 |
map_colors::unused,                // | 155 |
map_colors::unused,                // | 156 |
map_colors::unused,                // | 157 |
map_colors::unused,                // | 158 |
map_colors::unused,                // | 159 |
map_colors::unused,                // | 160 |
map_colors::unused,                // | 161 |
map_colors::unused,                // | 162 |
map_colors::unused,                // | 163 |
map_colors::unused,                // | 164 |
map_colors::unused,                // | 165 |
map_colors::unused,                // | 166 |
map_colors::unused,                // | 167 |
map_colors::unused,                // | 168 |
map_colors::unused,                // | 169 |
map_colors::unused,                // | 170 |
map_colors::unused,                // | 171 |
map_colors::unused,                // | 172 |
map_colors::tile_wood_back,        // | 173 |
map_colors::unused,                // | 174 |
map_colors::unused,                // | 175 |
map_colors::unused,                // | 176 |
map_colors::unused,                // | 177 |
map_colors::unused,                // | 178 |
map_colors::unused,                // | 179 |
map_colors::unused,                // | 180 |
map_colors::unused,                // | 181 |
map_colors::unused,                // | 182 |
map_colors::unused,                // | 183 |
map_colors::unused,                // | 184 |
map_colors::unused,                // | 185 |
map_colors::unused,                // | 186 |
map_colors::unused,                // | 187 |
map_colors::unused,                // | 188 |
map_colors::unused,                // | 189 |
map_colors::unused,                // | 190 |
map_colors::unused,                // | 191 |
map_colors::unused,                // | 192 |
map_colors::unused,                // | 193 |
map_colors::unused,                // | 194 |
map_colors::unused,                // | 195 |
map_colors::tile_wood,             // | 196 |
map_colors::tile_wood,             // | 197 |
map_colors::tile_wood,             // | 198 |
map_colors::unused,                // | 199 |
map_colors::tile_wood,             // | 200 | damaged
map_colors::tile_wood,             // | 201 | damaged
map_colors::tile_wood,             // | 202 | damaged
map_colors::tile_wood,             // | 203 | damaged
map_colors::tile_wood,             // | 204 | damaged
map_colors::tile_wood_back,        // | 205 |
map_colors::tile_wood_back,        // | 206 |
map_colors::tile_wood_back,        // | 207 | damaged
map_colors::tile_thickstone,       // | 208 |
map_colors::tile_thickstone,       // | 209 |
map_colors::unused,                // | 210 |
map_colors::unused,                // | 211 |
map_colors::unused,                // | 212 |
map_colors::unused,                // | 213 |
map_colors::tile_thickstone,       // | 214 | damaged
map_colors::tile_thickstone,       // | 215 | damaged
map_colors::tile_thickstone,       // | 216 | damaged
map_colors::tile_thickstone,       // | 217 | damaged
map_colors::tile_thickstone,       // | 218 | damaged
map_colors::unused,                // | 219 |
map_colors::unused,                // | 220 |
map_colors::unused,                // | 221 |
map_colors::unused,                // | 222 |
map_colors::unused,                // | 223 |
map_colors::tile_castle_moss,      // | 224 |
map_colors::tile_castle_moss,      // | 225 |
map_colors::tile_castle_moss,      // | 226 |
map_colors::tile_castle_back_moss, // | 227 |
map_colors::tile_castle_back_moss, // | 228 |
map_colors::tile_castle_back_moss, // | 229 |
map_colors::tile_castle_back_moss, // | 230 |
map_colors::tile_castle_back_moss, // | 231 |
map_colors::unused,                // | 232 |
map_colors::unused,                // | 233 |
map_colors::unused,                // | 234 |
map_colors::unused,                // | 235 |
map_colors::unused,                // | 236 |
map_colors::unused,                // | 237 |
map_colors::unused,                // | 238 |
map_colors::unused,                // | 239 |
map_colors::unused,                // | 240 |
map_colors::unused,                // | 241 |
map_colors::unused,                // | 242 |
map_colors::unused,                // | 243 |
map_colors::unused,                // | 244 |
map_colors::unused,                // | 245 |
map_colors::unused,                // | 246 |
map_colors::unused,                // | 247 |
map_colors::unused,                // | 248 |
map_colors::unused,                // | 249 |
map_colors::unused,                // | 250 |
map_colors::unused,                // | 251 |
map_colors::unused,                // | 252 |
map_colors::unused,                // | 253 |
map_colors::unused,                // | 254 |
map_colors::unused};               // | 255 |
