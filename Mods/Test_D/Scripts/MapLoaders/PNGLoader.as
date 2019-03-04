 // loads a.PNG map
// PNG loader base class - extend this to add your own PNG loading functionality!

#include "CustomMap.as";
#include "LoadMapUtils.as";
#include "ExplosionParticles.as";
#include "Sparks.as";
#include "GameColours.as";

bool LoadMap(CMap@ map, const string& in fileName)
{
	PNGLoader loader();
	return loader.loadMap(map , fileName);
}

// --------------------------------------

class PNGLoader
{
	PNGLoader()
	{
	}

	CFileImage@ image;
	CMap@ map;

	bool loadMap(CMap@ _map, const string& in filename)
	{
		@map = _map;

		if (!getNet().isServer())
		{
			TWMap::SetupMap(map, 0, 0);
			return true;
		}

		@image = CFileImage(filename);
		if (image.isLoaded())
		{
			TWMap::SetupMap(map, image.getWidth(), image.getHeight());

			while (image.nextPixel())
			{
				SColor pixel = image.readPixel();
				int offset = image.getPixelOffset();
				TWMap::HandlePixel(map, pixel, offset);
				getNet().server_KeepConnectionsAlive();
			}

			TWMap::PostLoad(map);

			return true;
		}
		return false;
	}

};

//TODO: make an include for this?

TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	if (TWMap::isTileDestructible(oldTileType))
	{
		bool nothingabove = true;
		u8 above = 0;
		if (index >= this.tilemapwidth)
		{
			above = this.getTile(index - this.tilemapwidth).type;
			nothingabove = (above == TWMap::tile_empty);
		}

		//some this is gross as a switch so we just rip out any problem cases ahead of time

		if (TWMap::isTileBush(oldTileType))
		{
			return TWMap::tile_bgbushdecor_leaves;
		}

		if (TWMap::isTileCactus(oldTileType))
		{
			if (TWMap::isTileCactus(above) || TWMap::isTileBush(above))
			{
				Vec2f tpos = Vec2f(index % this.tilemapwidth, index / this.tilemapwidth - 1) * this.tilesize;
				this.server_DestroyTile(tpos, 10.0f, null);
			}
			return TWMap::tile_empty;
		}

		switch (oldTileType)
		{
			case TWMap::tile_woodbridge:
			case TWMap::tile_planks_moss_under:
			case TWMap::tile_planks_moss_over:
			case TWMap::tile_planks_broken:
				return TWMap::tile_bgdecor_girder_horiz;

			case TWMap::tile_woodbridge_top:
			case TWMap::tile_woodbridge_join:
			case TWMap::tile_woodbridge_bottom:
			case TWMap::tile_woodbridge_vert:
				return TWMap::tile_bgdecor_girder_vert;

			default:
				while (index >= this.tilemapwidth && TWMap::canTileFall(this.getTile(index - this.tilemapwidth).type))
				{
					index -= this.tilemapwidth;
				}
				return TWMap::getTileBackgroundAt(this, index);
		}
	}

	return oldTileType;
}

void onSetTile(CMap@ map, u32 index, TileType newtile, TileType oldtile)
{
	//all tiles like this to prevent shading
	map.AddTileFlag(index, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);

	bool isSomething = false;
	if (TWMap::isTileTypeBackground(newtile))
	{
		isSomething = true;
		map.AddTileFlag(index, Tile::BACKGROUND);
	}
	if (TWMap::isTileTypeLadder(newtile))
	{
		isSomething = true;
		map.AddTileFlag(index, Tile::LADDER);
	}
	if (TWMap::isTileTypeSolid(newtile))
	{
		isSomething = true;
		map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	}

	if (!isSomething) //empty
	{
		map.AddTileFlag(index, Tile::WATER_PASSES);
	}

	//
	if (newtile == TWMap::tile_bush_corner)
	{
		u32 x = index % map.tilemapwidth;
		u32 y = index / map.tilemapwidth;
		bool up    = !TWMap::isTileTypeBackground(TWMap::getTile(x, y - 1));
		bool down  = !TWMap::isTileTypeBackground(TWMap::getTile(x, y + 1));
		bool left  = !TWMap::isTileTypeBackground(TWMap::getTile(x - 1, y));
		bool right = !TWMap::isTileTypeBackground(TWMap::getTile(x + 1, y));

		//dr / \ dl
		//ur \ / ul

		if (down && right)
		{
			map.AddTileFlag(index, Tile::MIRROR);
		}
		if (up && right)
		{
			map.AddTileFlag(index, Tile::MIRROR);
			map.AddTileFlag(index, Tile::FLIP);
		}
		if (up && left)
		{
			map.AddTileFlag(index, Tile::FLIP);
		}
	}

	if (newtile == TWMap::tile_bush_single)
	{
		u32 x = index % map.tilemapwidth;
		u32 y = index / map.tilemapwidth;
		bool up    = !TWMap::isTileTypeBackground(TWMap::getTile(x, y - 1));
		bool down  = !TWMap::isTileTypeBackground(TWMap::getTile(x, y + 1));
		bool left  = !TWMap::isTileTypeBackground(TWMap::getTile(x - 1, y));
		bool right = !TWMap::isTileTypeBackground(TWMap::getTile(x + 1, y));

		if (right)
		{
			map.AddTileFlag(index, Tile::MIRROR);
		}
		if (down)
		{
			map.AddTileFlag(index, Tile::FLIP);
			map.AddTileFlag(index, Tile::ROTATE);
		}
		if (up)
		{
			map.AddTileFlag(index, Tile::ROTATE);
		}
	}

	//vertical shaft stuff
	if (newtile == TWMap::tile_mountstone_side_bg ||
	        newtile == TWMap::tile_dirtdecor_wall ||
	        newtile == TWMap::tile_sand_dark_wall)
	{
		if (!TWMap::isTileTypeSolid(map.getTile(index - 1).type))
		{
			map.AddTileFlag(index, Tile::MIRROR);
		}
	}

	//corner tile stuff
	if(newtile == TWMap::tile_dirtdecor_corner_bottom ||
	        newtile == TWMap::tile_dirtdecor_corner_top)
	{
		if (!TWMap::isTileSolidForAutoTile(map.getTile(index - 1).type))
		{
			map.AddTileFlag(index, Tile::MIRROR);
		}
	}

	//shaft corner stuff
	if (newtile == TWMap::tile_sand_decor_curve ||
	        newtile == TWMap::tile_sand_decor_curve_dark)
	{
		if (!TWMap::isTileSolidForAutoTile(map.getTile(index - 1).type))
		{
			map.AddTileFlag(index, Tile::MIRROR);
		}
		if (!TWMap::isTileSolidForAutoTile(map.getTile(index + map.tilemapwidth).type))
		{
			map.AddTileFlag(index, Tile::FLIP);
		}
	}

	//rough edge alignment
	if (newtile == TWMap::tile_rough_backedge ||
	        newtile == TWMap::tile_rough_corner ||
	        newtile == TWMap::tile_rough_tight ||
	        newtile == TWMap::tile_rough_blind)
	{
		u32 x = index % map.tilemapwidth;
		u32 y = index / map.tilemapwidth;
		bool up    = TWMap::isTileForRough(TWMap::getTile(x, y - 1));
		bool down  = TWMap::isTileForRough(TWMap::getTile(x, y + 1));
		bool left  = TWMap::isTileForRough(TWMap::getTile(x - 1, y));
		bool right = TWMap::isTileForRough(TWMap::getTile(x + 1, y));

		if (newtile == TWMap::tile_rough_backedge)
		{
			if (down)
			{
				//do nothing
			}
			else if (up)
			{
				map.AddTileFlag(index, Tile::MIRROR);
				map.AddTileFlag(index, Tile::FLIP);
			}
			else if (left)
			{
				map.AddTileFlag(index, Tile::ROTATE);
			}
			else
			{
				map.AddTileFlag(index, Tile::ROTATE);
				map.AddTileFlag(index, Tile::MIRROR);
				map.AddTileFlag(index, Tile::FLIP);
			}
		}
		else if (newtile == TWMap::tile_rough_tight)
		{
			if (up && down)
			{
				map.AddTileFlag(index, Tile::ROTATE);
			}
		}
		else if (newtile == TWMap::tile_rough_corner)
		{
			if (down)
			{
				if (left)
				{
					//do nothing
				}
				else if (right)
				{
					map.AddTileFlag(index, Tile::MIRROR);
				}
			}
			else if (up)
			{
				if (left)
				{
					map.AddTileFlag(index, Tile::ROTATE);
				}
				else if (right)
				{
					map.AddTileFlag(index, Tile::MIRROR);
					map.AddTileFlag(index, Tile::FLIP);
				}
			}

		}
		else if (newtile == TWMap::tile_rough_blind)
		{
			if (!down)
			{
				map.AddTileFlag(index, Tile::ROTATE);
			}
			else if (!up)
			{
				map.AddTileFlag(index, Tile::FLIP);
				map.AddTileFlag(index, Tile::ROTATE);
			}
			else if (!left)
			{
				map.AddTileFlag(index, Tile::MIRROR);
			}
		}

		return;
	}

	//effects
	if (newtile != oldtile)
	{
		Vec2f tpos = Vec2f(index % map.tilemapwidth, index / map.tilemapwidth);
		tpos *= map.tilesize;

		if (oldtile == TWMap::tile_empty && TWMap::isTileDestructible(newtile)) //tile created
		{
			Sound::Play("CrateHit", tpos);
		}
		if (TWMap::isTileDestructible(oldtile) && !TWMap::isTileDestructible(newtile)) //tile destroyed
		{
			bool isPlant = TWMap::isTileBush(oldtile) || TWMap::isTileCactus(oldtile);
			bool isWood = TWMap::isTileWood(oldtile);

			string soundfile = isPlant ? "CrateExplode" :
			                   isWood ? "CrateExplode" : "CrateExplode";
			Sound::Play(soundfile, tpos);

			//gibs
			Particles::TileGibs(tpos, 5, 15.0f, isPlant ? 0 : isWood ? 1 : 2);
			//smoke
			Particles::SmokeStreamers(tpos, 1, Vec2f(), 15.0f, 10, 5);
			Particles::Sparks(tpos, 10, 20.0f, SColor(Colours::RED), 100);
			Particles::Sparks(tpos, 10, 20.0f, SColor(Colours::GREY), 100);
			Particles::Sparks(tpos, 10, 20.0f, SColor(Colours::YELLOW), 100);
		}
	}
}
