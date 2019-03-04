#include "MapCommon.as";

namespace TWMap
{
	void PlaceAbove(CMap@ map, int offset, u32 tile)
	{
		int aboveoffset = offset - map.tilemapwidth;
		if (aboveoffset > 0 && map.getTile(aboveoffset).type == 0)
		{
			map.SetTile(aboveoffset, tile);
		}
	}

	void HandlePixel(CMap@ map, SColor pixel, int offset)
	{
		int row = (offset / map.tilemapwidth) % 2;
		int row_off = (map.tilemapwidth + 1) % 2;
		bool dither = (((row * row_off) + (offset % 2)) % 2) == 0;
		Random tilerandom(offset);

		if (pixel == color_bgdecor)
		{
			map.SetTile(offset, tile_bgdecor_panel);
		}
		else if (pixel == color_bgdecor_room)
		{
			map.SetTile(offset, tile_roofdecor_1);
		}
		else if (pixel == color_dirt)
		{
			map.SetTile(offset, tile_dirt_1);
		}
		else if (pixel == color_dirt_grass)
		{
			map.SetTile(offset, tile_dirt_grass);
		}
		else if (pixel == color_sand)
		{
			map.SetTile(offset, tile_sand_1);
		}
		else if (pixel == color_dark_solid)
		{
			map.SetTile(offset, tile_dark_solid);
		}
		else if (pixel == color_bush)
		{
			map.SetTile(offset, tile_bush);
		}
		else if (pixel == color_bgbushdecor_leaves)
		{
			map.SetTile(offset, tile_bgbushdecor_leaves);
		}
		else if (pixel == color_bgbushdecor_trunk)
		{
			map.SetTile(offset, tile_bgbushdecor_trunk);
		}
		else if (pixel == color_bgbushdecor_branch)
		{
			map.SetTile(offset, tile_bgbushdecor_branch);
		}
		else if (pixel == color_bunker)
		{
			map.SetTile(offset, tile_bunker);
		}
		else if (pixel == color_bunker_wall)
		{
			map.SetTile(offset, tile_bunker_up);
		}
		else if (pixel == color_bunker_wood)
		{
			map.SetTile(offset, tile_bunker_wood_up);
		}
		else if (pixel == color_rubble)
		{
			map.SetTile(offset, tile_rubble);
		}
		else if (pixel == color_rubble_background)
		{
			map.SetTile(offset, tile_rubble_background);
		}
		else if (pixel == color_woodbridge)
		{
			map.SetTile(offset, tile_woodbridge);
		}
		else if (pixel == color_crate)
		{
			map.SetTile(offset, tile_crate_1 + tilerandom.NextRanged(4));
		}
		else if (pixel == color_roof)
		{
			map.SetTile(offset, tile_roof_body);
		}
		else if (pixel == color_reeds)
		{
			map.SetTile(offset, tile_reeds_1 + tilerandom.NextRanged(4));
		}
		else if (pixel == color_cactus)
		{
			map.SetTile(offset, tile_cactus_1 + (dither ? 1 : 0));
		}
		else if (pixel == color_flower)
		{
			map.SetTile(offset, tile_flower_1);
		}
		else if (pixel == color_water)
		{
			map.SetTile(offset, tile_black_background);
			map.server_setFloodWaterOffset(offset, true);
		}
		else if (pixel == color_swamp_bed)
		{
			map.SetTile(offset, tile_swamp_bed_1);
		}
		else if (pixel == color_ladder)
		{
			map.SetTile(offset, tile_ladder);
		}
		else if (pixel == color_mountstone)
		{
			map.SetTile(offset, tile_mountstone_1);
		}
		else if (pixel == color_snow)
		{
			map.SetTile(offset, tile_snow_1);
		}
		else if (pixel == color_black_background)
		{
			map.SetTile(offset, tile_black_background);
		}
		//spawns
		else if (pixel == color_neutral_spawn)
		{
			AddMarker(map, offset, "neutral spawn");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_blue_spawn)
		{
			AddMarker(map, offset, "blue spawn");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_red_spawn)
		{
			AddMarker(map, offset, "red spawn");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_green_spawn)
		{
			AddMarker(map, offset, "green spawn");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_pink_spawn)
		{
			AddMarker(map, offset, "pink spawn");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_blue_sniperspot)
		{
			AddMarker(map, offset, "blue sniper spot");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_red_sniperspot)
		{
			AddMarker(map, offset, "red sniper spot");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_classchange)
		{
			AddMarker(map, offset, "class change");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_campaignview)
		{
			AddMarker(map, offset, "campaign view");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_bottle)
		{
			AddMarker(map, offset, "bottle");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_band)
		{
			AddMarker(map, offset, "band");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_dispenser)
		{
			AddMarker(map, offset, "dispenser");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_shop)
		{
			AddMarker(map, offset, "shop");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_billboard)
		{
			AddMarker(map, offset, "billboard");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_hoop)
		{
			AddMarker(map, offset, "hoop");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_skirmish_truck)
		{
			AddMarker(map, offset, "skirmish truck");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_blue_truck)
		{
			AddMarker(map, offset, "blue truck");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_red_truck)
		{
			AddMarker(map, offset, "red truck");
			map.SetTile(offset, tile_placemostlikely);
		}
		else if (pixel == color_croc)
		{
			AddMarker(map, offset, "croc");
			map.SetTile(offset, tile_placemostlikely);
		}
		//auto features
		else if (pixel == color_auto_cave)
		{
			map.SetTile(offset, tile_auto_cave);
		}
		else if (pixel == color_auto_cave_grassy)
		{
			map.SetTile(offset, tile_auto_cave_grassy);
		}
		else if (pixel == color_auto_cave_sand)
		{
			map.SetTile(offset, tile_auto_cave_sand);
		}
		else
		{
			// empty
		}
	}

	//flood fill an area and return the absolute bounds of the area
	void FloodFill(CMap@ map, u32 x, u32 y, u32 type_with, Vec2f &out tl, Vec2f &out size)
	{
		tl = Vec2f(x, y);
		size = Vec2f(1, 1);

		u32 offset = offsetAt(map, x, y);
		u32 match_type = map.getTile(offset).type;

		if (match_type == type_with)
		{
			//nothing to fill and not safe to continue
			return;
		}

		array<u32> remaining;
		remaining.push_back(offset);

		while (!remaining.empty())
		{
			offset = remaining[remaining.length - 1];
			remaining.removeAt(remaining.length - 1);

			if (map.getTile(offset).type != match_type)
			{
				continue;
			}

			x = offset % map.tilemapwidth;
			y = offset / map.tilemapwidth;

			setTile(x, y, type_with);

			//extend bounds
			//lower bound
			if (tl.x > x) { size.x += tl.x - x; tl.x = x; }
			if (tl.y > y) { size.y += tl.y - y; tl.y = y; }
			//upper bound
			if (tl.x + size.x < x) { size.x = x - tl.x; }
			if (tl.y + size.y < y) { size.y = y - tl.y; }

			//apply remaining
			if (x > 0)
			{
				u32 _x = x - 1, _y = y;
				u8 t = getTile(_x, _y);
				if (t == match_type)
					remaining.push_back(offsetAt(map, _x, _y));
			}
			if (x < map.tilemapwidth - 1)
			{
				u32 _x = x + 1, _y = y;
				u8 t = getTile(_x, _y);
				if (t == match_type)
					remaining.push_back(offsetAt(map, _x, _y));
			}
			if (y > 0)
			{
				u32 _x = x, _y = y - 1;
				u8 t = getTile(_x, _y);
				if (t == match_type)
					remaining.push_back(offsetAt(map, _x, _y));
			}
			if (y < map.tilemapheight - 1)
			{
				u32 _x = x, _y = y + 1;
				u8 t = getTile(_x, _y);
				if (t == match_type)
					remaining.push_back(offsetAt(map, _x, _y));
			}
		}
	}

	////////////////////////////////
	//helpers for generation

	void RasterLine(array<u8>@ into, u8 value, u32 width, Vec2f from, Vec2f to)
	{
		//print("raster line from " + from.x + "," + from.y + " to " + to.x + "," + to.y);
		u32 height = into.length / width;

		Vec2f dir = (to - from);
		f32 len = dir.Normalize();
		for (f32 i = 0; i < len; i++)
		{
			Vec2f p = from + dir * i;
			s32 x = Maths::Round(p.x);
			s32 y = Maths::Round(p.y);
			if (x >= 0 && y >= 0 &&
			        x < width && y < height)
			{
				u32 offset = x + y * width;
				into[offset] = value;
			}
		}
	}

	bool PointInPoly(array<Vec2f>@ points, Vec2f test)
	{
		//adaption of https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

		int i = 0;
		int j = points.length - 1;
		bool c = false;
		while (i < points.length)
		{
			if (((points[i].y > test.y) != (points[j].y > test.y)) &&
			        (test.x < (points[j].x - points[i].x) * (test.y - points[i].y) / (points[j].y - points[i].y) + points[i].x))
			{
				c = !c;
			}
			j = i++;
		}
		return c;
	}

	void RasterPoly(array<u8>@ tiles, u32 width, array<Vec2f>@ points, u8 value)
	{
		u32 height = tiles.length / width;
		for (u32 y = 0; y < height; y++)
		{
			for (u32 x = 0; x < width; x++)
			{
				if (PointInPoly(points, Vec2f(x - 1, y)) ||
				        PointInPoly(points, Vec2f(x + 1, y)) ||
				        PointInPoly(points, Vec2f(x, y - 1)) ||
				        PointInPoly(points, Vec2f(x, y + 1))
				   )
					tiles[x + y * width] = value;
			}
		}
	}

	void TranslatePoints(array<Vec2f>@ points, Vec2f by)
	{
		for (u32 i = 0; i < points.length; i++)
		{
			points[i] += by;
		}
	}

	f32 EdgeDistanceScaler(f32 x, f32 y, f32 width, f32 height)
	{
		f32 edge_dist = Maths::Min(Maths::Min(x, y), Maths::Min(width - x - 1, height - y - 1));
		return Maths::Min(1.0f, edge_dist / (Maths::Min(width, height) * 0.5f));
	}

	//find any non-solid points around the edge of an area
	//in a convex ordering
	array<Vec2f> FindGapsAround(CMap@ map, Vec2f tl, Vec2f size)
	{
		s32 width = size.x + 1;
		s32 height = size.y + 1;

		array<Vec2f> gaps;
		//left side upwards
		if (tl.x - 1 > 0)
			for (s32 i = height - 1; i >= 0; i--)
			{
				if (!isTileSolidForAutoTile(getTile(tl.x - 1, tl.y + i)))
					gaps.push_back(Vec2f(-1, i));
			}
		//top side rightwards
		if (tl.y - 1 > 0)
			for (s32 i = 0; i < width; i++)
			{
				if (!isTileSolidForAutoTile(getTile(tl.x + i, tl.y - 1)))
					gaps.push_back(Vec2f(i, -1));
			}
		//right side downwards
		if (tl.x + size.x + 1 < map.tilemapwidth)
			for (s32 i = 0; i < height; i++)
			{
				if (!isTileSolidForAutoTile(getTile(tl.x + size.x + 1, tl.y + i)))
					gaps.push_back(Vec2f(size.x + 1, i));
			}
		//bottom side leftwards
		if (tl.y + size.y + 1 < map.tilemapheight)
			for (s32 i = width - 1; i >= 0; i--)
			{
				if (!isTileSolidForAutoTile(getTile(tl.x + i, tl.y + size.y + 1)))
					gaps.push_back(Vec2f(i, size.y + 1));
			}
		TranslatePoints(gaps, tl);
		return gaps;
	}

	//find the distance from an edge at the current point
	u8 DepthAt(const array<u8>@ tiles, u32 width, u32 height, u8 value, s32 x, s32 y)
	{
		u32 offset = x + y * width;

		if (tiles[offset] != value)
			return 0;

		array<u32> done;
		array<u32> remaining;
		array<u8> span;
		done.push_back(offset);
		span.push_back(0);
		remaining.push_back(offset);

		while (!remaining.empty())
		{
			offset = remaining[0];
			remaining.removeAt(0);

			u8 curspan = span[0];
			span.removeAt(0);

			if (tiles[offset] != value)
			{
				return curspan;
			}

			x = offset % width;
			y = offset / width;

			//search
			s32[] _x =
			{
				x, x, x - 1, x + 1
			};
			s32[] _y =
			{
				y - 1, y + 1, y, y
			};

			for (u32 i = 0; i < _x.length; i++)
			{
				if (_x[i] < 0 || _x[i] > width - 1 ||
				        _y[i] < 0 || _y[i] > height - 1)
				{
					//filter
					continue;
				}

				offset = _x[i] + _y[i] * width;
				if (done.find(offset) == -1)
				{
					done.push_back(offset);
					remaining.push_back(offset);
					span.push_back(curspan + 1);
				}
			}
		}

		return 255;
	}

	array<u8> FindDepths(const array<u8>@ tiles, u32 width, u8 value)
	{
		array<u8> depths(tiles.length, 0);
		u32 height = tiles.length / width;
		for (u32 i = 0; i < tiles.length; i++)
		{
			s32 x = i % width;
			s32 y = i / width;

			depths[i] = DepthAt(tiles, width, height, value, x, y);
		}
		return depths;
	}

	//find the height to solid ground at each point
	u8 HeightAt(const array<u8>@ tiles, u32 width, u32 height, u8 value, s32 x, s32 y)
	{
		for (u32 i = 0; i + y < height; i++)
		{
			if (tiles[x + (y + i) * width] != value)
			{
				return i;
			}
		}
		return height;
	}

	array<u8> FindHeights(const array<u8>@ tiles, u32 width, u8 value)
	{
		array<u8> heights(tiles.length, 0);
		u32 height = tiles.length / width;
		for (u32 i = 0; i < tiles.length; i++)
		{
			s32 x = i % width;
			s32 y = i / width;

			heights[i] = HeightAt(tiles, width, height, value, x, y);
		}
		return heights;
	}

	//find the minimum spans at each point - ie how much leeway we have
	u8 SpanAt(const array<u8>@ tiles, u32 width, u32 height, u8 value, s32 x, s32 y)
	{
		if (tiles[x + y * width] != value)
			return 0;

		s32[] dir_x =
		{
			1, 0, 1, -1
		};
		s32[] dir_y =
		{
			0, 1, 1, -1
		};

		s32 span = 10;
		for (u32 i = 0; i < dir_x.length; i++)
		{
			u32 curspan = 1;
			//temps
			s32 _x, _y;
			//forward direction
			_x = x + dir_x[i];
			_y = y + dir_y[i];
			while (true)
			{
				if (!(_x >= 0 && _y >= 0 && _x < width && _y < height))
				{
					curspan = span;
					break;
				}

				if (tiles[_x + _y * width] == value)
					curspan++;
				else
					break;

				_x += dir_x[i];
				_y += dir_y[i];
			}
			//backward direction
			_x = x - dir_x[i];
			_y = y - dir_y[i];
			while (true)
			{
				if (!(_x >= 0 && _y >= 0 && _x < width && _y < height))
				{
					curspan = span;
					break;
				}

				if (tiles[_x + _y * width] == value)
					curspan++;
				else
					break;

				_x -= dir_x[i];
				_y -= dir_y[i];
			}

			span = Maths::Min(span, curspan);
		}

		return span;
	}

	array<u8> FindSpans(const array<u8>@ tiles, u32 width, u8 value)
	{
		array<u8> spans(tiles.length, 0);
		u32 height = tiles.length / width;
		for (u32 i = 0; i < tiles.length; i++)
		{
			s32 x = i % width;
			s32 y = i / width;

			spans[i] = SpanAt(tiles, width, height, value, x, y);
		}
		return spans;
	}

	void Erode(array<u8>@ tiles, u32 width, u32 height, u8 fg_tile, u32 erosion_passes)
	{
		for (u32 i = 0; i < erosion_passes; i++)
		{
			array<u8> old_tiles = tiles; //old version to cache
			for (uint y = 0; y < height; y++)
			{
				for (uint x = 0; x < width; x++)
				{
					u32 offset = x + y * width;
					bool left = (x == 0) ? true : (old_tiles[offset - 1] != tile_black_background);
					bool right = (x == width - 1) ? true : (old_tiles[offset + 1] != tile_black_background);
					bool up = (y == 0) ? true : (old_tiles[offset - width] != tile_black_background);
					bool down = (y == height - 1) ? true : (old_tiles[offset + width] != tile_black_background);

					if (old_tiles[offset] == fg_tile)
					{
						u32 count = 0;
						if (!left) count++;
						if (!right) count++;
						if (!up) count++;
						if (!down) count++;

						if (count > 2)
						{
							tiles[offset] = tile_black_background;
						}
					}
					else if (old_tiles[offset] == tile_black_background)
					{
						if (left && right || up && down)
						{
							tiles[offset] = fg_tile;
						}
					}
				}
			}
		}
	}

	void WarpEdge(array<u8>@ tiles, u32 width, u32 height, Noise@ _n, u8 fg_tile)
	{
		array<u8> old_tiles = tiles; //old version to cache
		array<u8> spans = FindSpans(tiles, width, tile_black_background);
		array<u8> depths = FindDepths(tiles, width, tile_black_background);
		for (uint y = 2; y < height - 2; y++)
		{
			for (uint x = 2; x < width - 2; x++)
			{
				u32 offset = x + y * width;

				f32 nscale = 0.07f;
				f32 nthresh = 1.1f - 0.7f * Maths::Clamp01(EdgeDistanceScaler(x, y, width, height) * 1.5f);
				f32 nval = _n.Fractal(120 + x * nscale, 30 + y * nscale);

				if (nval < nthresh)
				{
					if (old_tiles[offset] == tile_black_background)
					{
						if (spans[offset] >= 4 && depths[offset] == 1)
						{
							if (old_tiles[offset - width] == fg_tile ||
							        old_tiles[offset + width] == fg_tile)
							{
								tiles[offset] = fg_tile;
							}
						}
					}
				}
				else if (nval < 1.0f - nthresh)
				{
					if ((old_tiles[offset + width] == tile_black_background || //top or bottom erosion
					        old_tiles[offset - width] == tile_black_background))
					{
						tiles[offset] = tile_black_background;
					}
				}
			}
		}
	}

	void FillRect(array<u8>@ tiles, u32 width, u32 height, u8 value, Vec2f tl, Vec2f br)
	{
		for (f32 y = Maths::Max(tl.y, 0.0f); y <= Maths::Min(br.y, f32(height - 1)); y++)
			for (f32 x = Maths::Max(tl.x, 0.0f); x <= Maths::Min(br.x, f32(width - 1)); x++)
			{
				tiles[s32(x + y * width)] = value;
			}
	}

	void Passable_Pass(array<u8>@ tiles, u32 width, u32 height, u8 fg_tile)
	{
		array<u8> spans = FindSpans(tiles, width, tile_black_background);
		for (uint y = 0; y < height; y++)
		{
			for (uint x = 0; x < width; x++)
			{
				u32 index = x + y * width;
				if (tiles[index] == tile_black_background && spans[index] < 2)
				{
					FillRect(tiles, width, height, tile_black_background, Vec2f(x - 1, y - 1), Vec2f(x + 1, y));
					spans = FindSpans(tiles, width, tile_black_background);
					FillRect(spans, width, height, 3, Vec2f(x - 1, y - 1), Vec2f(x + 1, y));
				}
			}
		}
	}

	/////////////////////////////////
	//generation functions

	u32 _nseed = Time();

	//autogenerating cave areas
	void AutoArea_Cave(CMap@ map, Vec2f tl, Vec2f size, u8 fg_tile, bool add_rocks, bool add_grass = true)
	{
		print("cave feature at: " + tl.x + "," + tl.y + " size: " + size.x + "," + size.y);

		u32 width = size.x + 1;
		u32 height = size.y + 1;

		//random noise each time (not demo-safe, if we ever get them)
		Noise _n(_nseed++);

		//work tilemap
		array<u8> tiles(height * width, fg_tile);
		//mask from existing tiles
		array<bool> mask(height * width);
		for (uint y = 0; y < height; y++)
		{
			for (uint x = 0; x < width; x++)
			{
				u32 offset = x + y * width;
				u8 t = getTile(x + tl.x, y + tl.y);
				mask[offset] = (t == 0);
			}
		}

		//find edge gaps
		array<Vec2f> gaps = FindGapsAround(map, tl, size);
		//rasterise
		TranslatePoints(gaps, -tl);
		RasterPoly(tiles, width, gaps, tile_black_background);

		//warp edge
		WarpEdge(tiles, width, height, _n, fg_tile);

		//erode + fill 1 tile tunnels
		Erode(tiles, width, height, fg_tile, 2);

		//ensure passable
		Passable_Pass(tiles, width, height, fg_tile);

		//add decor
		//pre-decor values
		array<u8> old_tiles = tiles; //old version to cache
		array<u8> spans = FindSpans(tiles, width, tile_black_background);
		array<u8> depths = FindDepths(tiles, width, tile_black_background);
		array<u8> heights = FindHeights(tiles, width, tile_black_background);

		if (add_rocks)
		{
			for (uint y = 2; y < height - 2; y++)
			{
				for (uint x = 2; x < width - 2; x++)
				{
					if (_n.Fractal(x * 0.53f, y * 0.71f) > 0.5f) continue;

					u32 offset = x + y * width;
					if (old_tiles[offset] == tile_black_background)
					{
						if (depths[offset] > 1)
							tiles[offset] = tile_rubble_background;
						else if (spans[offset] >= 3 && old_tiles[offset + width] == fg_tile)
							tiles[offset] = tile_rubble;
					}
					else if (old_tiles[offset] == fg_tile)
					{
						if (depths[offset + 1] == 1 || depths[offset - 1] == 1)
							tiles[offset] = tile_rubble;
					}
				}
			}
		}
		if (add_grass)
		{
			//add bushes and grass
			for (uint y = 1; y < height - 1; y++)
			{
				for (uint x = 1; x < width - 1; x++)
				{
					u32 offset = x + y * width;

					f32 base_val = 0.25f;

					f32 n_val = _n.Fractal(x * 0.3f, 12.7f) + (heights[offset] * 0.3f) * (1.0f - base_val) + base_val;

					if (n_val > 1.0f) continue;

					if (old_tiles[offset] != tile_black_background)
					{
						if (old_tiles[offset] == fg_tile && old_tiles[offset - width] == tile_black_background)
						{
							tiles[offset] = tile_dirt_grass;
						}
					}
					else
					{
						tiles[offset] = tile_bush;
						if (old_tiles[offset + width] == fg_tile)
							tiles[offset + width] = tile_dirt_grass;
					}
				}
			}
			//filter + add edges
			for (uint y = 1; y < height - 1; y++)
			{
				for (uint x = 1; x < width - 1; x++)
				{
					u32 offset = x + y * width;

					f32 n_val = _n.Fractal(x * 0.3f, y * 0.3f);

					if (tiles[offset] == tile_black_background)
					{
						//should be bush - gap between this and higher depth
						if ( //next to bush
						    (tiles[offset + 1] == tile_bush ||
						     tiles[offset - 1] == tile_bush ||
						     tiles[offset + width] == tile_bush ||
						     tiles[offset - width] == tile_bush) &&
						    //not interupting fg
						    (tiles[offset + 1] != fg_tile &&
						     tiles[offset - 1] != fg_tile &&
						     tiles[offset + width] != fg_tile &&
						     tiles[offset - width] != fg_tile) && n_val > 0.5f)
						{
							tiles[offset] = tile_bgbushdecor_leaves;
							continue;
						}
					}
					if (tiles[offset] == tile_bush)
					{
						if (tiles[offset + 1] != tile_bush 	&& tiles[offset + 1] != fg_tile && tiles[offset + 1] != tile_dirt_grass &&
						        tiles[offset - 1] != tile_bush && tiles[offset - 1] != fg_tile && tiles[offset - 1] != tile_dirt_grass)
						{
							if (tiles[offset - 1 + width] == tile_bush)
							{
								tiles[offset - 1] = tile_bush;
							}
							else if (tiles[offset + 1 + width] == tile_bush)
							{
								tiles[offset + 1] = tile_bush;
							}
							else if (tiles[offset - width] != tile_bush &&
							         tiles[offset - 1] != fg_tile && tiles[offset + 1] != fg_tile)
							{
								tiles[offset] = tile_flower_1;
								if (tiles[offset - width] == tile_flower_1)
								{
									tiles[offset - width] = tile_bgbushdecor_leaves;
								}
							}
							else
							{
								tiles[offset] = tile_bgbushdecor_leaves;
							}
						}
					}
				}
			}
		}

		//generate actual tiles
		for (uint y = 0; y < height; y++)
		{
			for (uint x = 0; x < width; x++)
			{
				if (mask[x + y * width])
				{
					setTile(x + tl.x, y + tl.y, tiles[x + y * width]);
				}
			}
		}
	}

	void PostLoad(CMap@ map)
	{
		Vec2f mapdim = map.getMapDimensions();

		//random features (before auto/depth so they get autotiled too)
		{
			//collect feature areas
			array<u8> auto_type;
			array<Vec2f> auto_tl;
			array<Vec2f> auto_size;
			for (uint y = 0; y < map.tilemapheight; y++)
			{
				for (uint x = 0; x < map.tilemapwidth; x++)
				{
					u32 offset = offsetAt(map, x, y);

					bool write = false;
					u8 type = map.getTile(offset).type;
					Vec2f tl;
					Vec2f size;

					if (type == tile_auto_cave ||
					        type == tile_auto_cave_sand ||
					        type == tile_auto_cave_grassy)
					{
						FloodFill(map, x, y, 0, tl, size);
						write = true;
					}

					if (write)
					{
						auto_type.push_back(type);
						auto_tl.push_back(tl);
						auto_size.push_back(size);
					}
				}
			}

			//fill random features
			for (u32 i = 0; i < auto_type.length; i++)
			{
				u8 type = auto_type[i];
				Vec2f tl = auto_tl[i];
				Vec2f size = auto_size[i];

				if (type == tile_auto_cave)
					AutoArea_Cave(map, tl, size, tile_dirt_1, true, false);
				else if (type == tile_auto_cave_grassy)
					AutoArea_Cave(map, tl, size, tile_dirt_1, false, true);
				else if (type == tile_auto_cave_sand)
					AutoArea_Cave(map, tl, size, tile_sand_1, false, false);
			}
		}

		//build depth map
		array<u32> depthmap(map.tilemapwidth * map.tilemapheight, 0);
		array<u32> depth_todo;
		for (uint y = 0; y < map.tilemapheight; y++)
		{
			for (uint x = 0; x < map.tilemapwidth; x++)
			{
				u32 offset = offsetAt(map, x, y);
				u8 type = map.getTile(offset).type;
				depthmap[offset] = 0;
				if (isTileSolidForAutoTile(type))
				{
					if (isTileForDepth(type))
					{
						depthmap[offset] = 1;
						depth_todo.push_back(offset);
					}
					else //fake wall
					{
						depthmap[offset] = 10;
					}
				}
			}
		}
		while (!depth_todo.empty())
		{
			u32 offset = depth_todo[0];
			u32 x = offset % map.tilemapwidth;
			u32 y = offset / map.tilemapwidth;
			depth_todo.removeAt(0);

			u32 left = (x > 0 ? depthmap[offset - 1] : 10);
			u32 right = (x < map.tilemapwidth - 1 ? depthmap[offset + 1] : 10);
			u32 up = (y > 0 ? depthmap[offset - map.tilemapwidth] : 10);
			u32 down = (y < map.tilemapheight - 1 ? depthmap[offset + map.tilemapwidth] : 10) + 1;

			u32 depth = Maths::Min(Maths::Min(left, right), Maths::Min(up, down)) + 1;

			if (depth != depthmap[offset])
			{
				depthmap[offset] = depth;
				depth_todo.push_back(offset);
			}
		}

		// autotile
		Random tilerandom(0xf4ce);
		Noise tilenoise(tilerandom.Next());
		for (uint y = map.tilemapheight - 2; y > 0; y--) //loop from bottom to top for more sensible autotile
		{
			for (uint x = 1; x < map.tilemapwidth - 1; x++)
			{
				u32 offset = offsetAt(map, x, y);
				int row = (offset / map.tilemapwidth) % 2;
				int row_off = (map.tilemapwidth + 1) % 2;
				bool dither = (((row * row_off) + (offset % 2)) % 2) == 0;
				Random tilerandom(offset);
				u8 type = map.getTile(offset).type;

				if (type == tile_placemostlikely)
				{
					PlaceMostLikelyTile(map, offset, true);
					continue;
				}

				//autotiling into space
				if (type == 0)
				{
					u8 tile_up    = getTile(x, y - 1);
					u8 tile_down  = getTile(x, y + 1);
					u8 tile_left  = getTile(x - 1, y);
					u8 tile_right = getTile(x + 1, y);

					bool rough_up    = false;
					bool rough_down  = false;
					bool rough_left  = false;
					bool rough_right = false;

					//count rough edges
					u32 rough_edges = 0;
					if (x > 0 && isTileForRough(tile_left))
					{
						rough_edges++;
						rough_left = true;
					}
					if (x < map.tilemapwidth - 1 && isTileForRough(tile_right))
					{
						rough_edges++;
						rough_right = true;
					}
					if (y > 0 && isTileForRough(tile_up))
					{
						rough_edges++;
						rough_up   = true;
					}
					if (y < map.tilemapheight - 1 && isTileForRough(tile_down))
					{
						rough_edges++;
						rough_down = true;
					}

					//special tiling
					if (isTileGrass(tile_down) && tilerandom.NextRanged(4) != 0 && rough_edges == 1)
					{
						setTile(x, y, tile_grass_tuft_1 + tilerandom.NextRanged(2));
						continue;
					}

					if (rough_edges == 1)
					{
						setTile(x, y, tile_rough_backedge);
					}
					else if (rough_edges == 2)
					{
						if (rough_up && rough_down || rough_left && rough_right)
							setTile(x, y, tile_rough_tight);
						else
							setTile(x, y, tile_rough_corner);
					}
					else if (rough_edges == 3)
					{
						setTile(x, y, tile_rough_blind);
					}
					else if (isTileRoof(tile_down))
					{
						if (isTileRoof(tile_right))
						{
							setTile(x, y, tile_bgdecor_ramp_left);
						}
						if (isTileRoof(tile_left))
						{
							setTile(x, y, tile_bgdecor_ramp_right);
						}
					}
					else if (isTileSand(tile_down))
					{
						if (isTileSand(tile_left) || isTileSand(tile_right))
						{
							setTile(x, y, tile_sand_decor_curve);
						}
						else
						{
							setTile(x, y, tile_sand_decor_1 + (dither ? 1 : 0));
						}
					}
					else if (isTileSnow(tile_down))
					{
						setTile(x, y, tile_snow_over_1 + (dither ? 1 : 0));
					}
					else if (tile_down == tile_bgbushdecor_trunk)
					{
						setTile(x, y, tile_bgbushdecor_trunk_top);
					}
					continue;
				}

				if (type == tile_roofdecor_1)
				{
					u8 tile_up     = getTile(x, y - 1);
					u8 tile_down   = getTile(x, y + 1);
					u8 tile_left   = getTile(x - 1, y);
					u8 tile_right  = getTile(x + 1, y);

					u8 tile_two_up     = getTile(x, y - 2);
					u8 tile_two_down   = getTile(x, y + 2);
					u8 tile_two_left   = getTile(x - 2, y);
					u8 tile_two_right  = getTile(x + 2, y);

					if (isTileBunker(tile_up) || isTileWoodBridge(tile_up) ||
					        (isTileAutoDecor(tile_up) && (tile_two_up == 0 || tile_two_up == tile_black_background)))
					{
						type = tile_roofdecor_1 + tilerandom.NextRanged(2);
					}
					else if (tile_up == tile_roofdecor_1 && (isTileBunker(tile_two_up) || isTileWoodBridge(tile_two_up)))
					{
						type = (tilerandom.NextRanged(2) == 0) ? tile_bgdecor_handle_top : tile_black_background;
					}
					else if ((isTileBunker(tile_down) || isTileWoodBridge(tile_down)) && tilenoise.Sample(x, y) > 0.8f)
					{
						type = tile_bgdecor_crate;
					}
					else
					{
						type = tile_black_background;
					}

					setTile(x, y, type);

					continue;
				}

				if (type == tile_bgdecor_panel)
				{
					u8 tile_up     = getTile(x, y - 1);
					u8 tile_down   = getTile(x, y + 1);
					u8 tile_left   = getTile(x - 1, y);
					u8 tile_right  = getTile(x + 1, y);

					u8 tile_two_up     = getTile(x, y - 2);
					u8 tile_two_down   = getTile(x, y + 2);
					u8 tile_two_left   = getTile(x - 2, y);
					u8 tile_two_right  = getTile(x + 2, y);

					//figure out some way to do the roof decor

					bool door_vert = isTileSolidForAutoTile(tile_up) && isTileSolidForAutoTile(tile_two_down) ||
					                 isTileSolidForAutoTile(tile_down) && isTileSolidForAutoTile(tile_two_up);

					bool door_horiz = isTileSolidForAutoTile(tile_left) && isTileSolidForAutoTile(tile_two_right) ||
					                  isTileSolidForAutoTile(tile_right) && isTileSolidForAutoTile(tile_two_left);

					u32 count_up = 0;
					if (isTileAutoDecor(tile_up)) {count_up++;}
					if (isTileAutoDecor(tile_two_up)) {count_up++;}

					u32 count_down = 0;
					if (isTileAutoDecor(tile_down)) {count_down++;}
					if (isTileAutoDecor(tile_two_down)) {count_down++;}

					if (door_vert) {count_up++; count_down++;}

					u32 count_left = 0;
					if (isTileAutoDecor(tile_left)) {count_left++;}
					if (isTileAutoDecor(tile_two_left)) {count_left++;}

					u32 count_right = 0;
					if (isTileAutoDecor(tile_right)) {count_right++;}
					if (isTileAutoDecor(tile_two_right)) {count_right++;}

					if (door_horiz) {count_left++; count_right++;}

					if (count_left + count_right + count_up + count_down > 0)
					{
						if (count_left + count_right >= count_up + count_down)
						{
							type = door_horiz ? tile_bgdecor_door_horiz : tile_bgdecor_girder_horiz;
						}
						else
						{
							type = door_vert ? tile_bgdecor_door_vert : tile_bgdecor_girder_vert;
						}
					}

					setTile(x, y, type);
					continue;
				}

				//auto-border decor placement placement "indoors"
				if (type == tile_black_background)
				{
					if (y > 0 && x > 0 && y < map.tilemapheight - 1 && x < map.tilemapwidth - 1)
					{
						u8 above = getTile(x, y - 1);
						u8 below = getTile(x, y + 1);
						u8 left = getTile(x - 1, y);
						u8 right = getTile(x + 1, y);
						if (below == tile_dirt_grass)
						{
							setTile(x, y, tile_grass_short_cave);
						}

						//todo: corners
						if (isTileDirt(below))
						{
							if (isTileDirt(left) || isTileDirt(right))
								setTile(x, y, tile_dirtdecor_corner_bottom);
							else
								setTile(x, y, tile_dirtdecor_floor_1 + (dither ? 1 : 0));
						}
						else if (isTileDirt(above))
						{
							if (isTileDirt(left) || isTileDirt(right))
								setTile(x, y, tile_dirtdecor_corner_top);
							else
								setTile(x, y, tile_dirtdecor_roof_1 + (dither ? 1 : 0));
						}
						else if (isTileDirt(left) || isTileDirt(right))
						{
							setTile(x, y, tile_dirtdecor_wall);
						}

						if (isTileSand(left) || isTileSand(right))
						{
							if (isTileSand(above) || isTileSand(below))
								setTile(x, y, tile_sand_decor_curve_dark);
							else
								setTile(x, y, tile_sand_dark_wall);
						}
						else if (isTileSand(below))
						{
							setTile(x, y, tile_sand_dark_floor);
						}
						else if (isTileSand(above))
						{
							setTile(x, y, tile_sand_dark_roof);
						}

						if (isTileMountainStone(below))
						{
							setTile(x, y, tile_mountstone_over_bg_1 + (dither ? 1 : 0));
						}
						else if (isTileMountainStone(above))
						{
							setTile(x, y, tile_mountstone_under_bg_1 + (dither ? 0 : 1));
						}
						else if (isTileMountainStone(left) || isTileMountainStone(right))
						{
							setTile(x, y, tile_mountstone_side_bg);
						}
					}
				}

				//bush autotiling
				if (type == tile_bush)
				{
					bool up    = !isTileTypeBackground(getTile(x, y - 1));
					bool down  = !isTileTypeBackground(getTile(x, y + 1));
					bool left  = !isTileTypeBackground(getTile(x - 1, y));
					bool right = !isTileTypeBackground(getTile(x + 1, y));

					if (up && down && left && right)
					{
						type = tile_bush_light_1 + (dither ? 1 : 0);
					}
					else if (up != down && !left && !right ||
					         !up && !down && left != right)
					{
						type = tile_bush_single;
					}
					else if (up != down && left != right)
					{
						type = tile_bush_corner;
					}
					map.SetTile(offset, type);
				}

				//flower autotiling
				if (type == tile_flower_1)
				{
					if (getTileBackgroundAt(map, offset) != 0)
						type += 2;

					type += (dither ? 1 : 0);
					map.SetTile(offset, type);
					continue;
				}

				//building autotiling
				if (type == tile_roof_body)
				{
					//TODO MAP cleverer sloping here
					if (!isTileRoof(getTile(x, y - 1)))
					{
						type = tile_roof_top;
					}
					map.SetTile(offset, type);
					continue;
				}


				//terrain tiles
				if (isTileForDepth(type))
				{
					f32 depth = 0.5f;

					depth += depthmap[offset] - 1.0f;// calculateDepthAt(map, x, y, tilenoise);

					if (type == tile_dirt_1 || type == tile_mountstone_1)
					{
						depth = Maths::Max(0, depth - tilenoise.Sample(x, y));
						if (depth >= 3.5f)
							type = tile_dark_solid;
						else
							type += u32(depth) * 2 + (dither ? 1 : 0);
					}
					else if (type == tile_sand_1)
					{
						int[] offsets = {0, 1, 2, 2};
						if (depth >= offsets.length)
						{
							type = tile_dark_solid;
						}
						else
						{
							int off = offsets[u32(depth)];
							if (off != 0 || tilerandom.NextRanged(2) == 0)
								type += 2;
							type += off * 2 + (dither ? 1 : 0);
						}
					}
					else if (type == tile_snow_1)
					{
						depth = Maths::Max(0.0f, depth);
						if (depth >= 2.5f)
							type = tile_dark_solid;
						if (depth < 1.0f)
							type = (tilerandom.NextRanged(2) == 0 ? tile_snow_1 : tile_snow_3) + (dither ? 1 : 0);
						else
							type = tile_snow_5 + (dither ? 1 : 0);
					}

					map.SetTile(offset, type);
				}

				if (type == tile_woodbridge)
				{
					u8 tile_up    = getTile(x, y - 1);
					u8 tile_down  = getTile(x, y + 1);
					u8 tile_left  = getTile(x - 1, y);
					u8 tile_right = getTile(x + 1, y);

					bool up    = isTileWoodBridge(tile_up) || isTileBunker(tile_up);
					bool down  = isTileWoodBridge(tile_down) || isTileBunker(tile_down);
					bool left  = isTileWoodBridge(tile_left);
					bool right = isTileWoodBridge(tile_right);

					if (up || down)
					{
						if (!up)
						{
							type = tile_woodbridge_top;
						}
						else if (left || right)
						{
							type = (down ? tile_woodbridge_join : tile_woodbridge);
						}
						else if (!down)
						{
							type = tile_woodbridge_bottom;
						}
						else
						{
							type = tile_woodbridge_vert;
						}
					}
					map.SetTile(offset, type);
				}

				//final directional autotiles
				if (type != tile_bunker_up &&
				        type != tile_bunker_wood_up)
				{
					continue;
				}

				bool up    = isTileSolidForAutoTile(getTile(x, y - 1));
				bool left  = isTileSolidForAutoTile(getTile(x - 1, y));
				bool right = isTileSolidForAutoTile(getTile(x + 1, y));
				bool down  = isTileSolidForAutoTile(getTile(x, y + 1));

				switch (type)
				{
					//concrete bunker wall auto-tile
					case tile_bunker_up:
						if (!up)
							type = tile_bunker_up;
						else if (!down)
							type = tile_bunker_down;
						else if (!left)
							type = tile_bunker_left;
						else if (!right)
							type = tile_bunker_right;

						map.SetTile(offset, type);
						break;

					//concrete+wood bunker wall auto-tile
					case tile_bunker_wood_up:
						if (!up)
							type = tile_bunker_wood_up;
						else if (!down)
							type = tile_bunker_wood_down;
						else if (!left)
							type = tile_bunker_wood_left;
						else if (!right)
							type = tile_bunker_wood_right;
						map.SetTile(offset, type);
						break;
				}
			}
		}
	}

	f32 calculateDepthAt(CMap@ map, s32 x, s32 y, Noise@ noise)
	{
		f32 depth = 0.0f;
		bool blockedup    = false;
		bool blockedleft  = false;
		bool blockedright = false;
		bool blockeddown  = false;
		for (u32 i = 1; i <= 5; i++)
		{
			u8 tileup = getTile(x, y - i);
			u8 tileleft = getTile(x - i, y - i / 2);
			u8 tileright = getTile(x + i, y - i / 2);
			u8 tiledown = getTile(x, y + i / 2);

			if (isTileBunker(tileup)) blockedup = true;
			if (isTileBunker(tiledown)) blockeddown = true;
			if (isTileBunker(tileleft)) blockedleft = true;
			if (isTileBunker(tileright)) blockedright = true;

			bool up    = blockedup    || isTileSolidForAutoTile(tileup);
			bool left  = blockedleft  || (x - i > 0 ? isTileSolidForAutoTile(tileleft) : true);
			bool right = blockedright || (x + i < map.tilemapwidth - 1 ? isTileSolidForAutoTile(tileright) : true);
			bool down  = blockeddown  || (y + i < map.tilemapheight - 1 ? isTileSolidForAutoTile(tiledown) : true);
			if (!up || !left || !right || !down)
			{
				break;
			}
			depth++;
		}
		return depth;
	}

}
