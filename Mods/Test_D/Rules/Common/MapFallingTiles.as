//////////////////////////////////////////
// falling tiles
//			iterate the map over several
//			frames, looking for tiles to
//			collapse into falling blocks

#include "MapCommon.as";

void createFallingBlock(Vec2f pos, u8 tile)
{
	CBlob @newBlob = server_CreateBlobNoInit("falling_tile");
	if (newBlob !is null)
	{
		newBlob.setPosition(pos);
		newBlob.set_u8("frame", tile);
		newBlob.Init();
	}
}

//gather stuff that can fall for some percentage of the map
bool gatherFallible(CMap@ this, int i, int steps, array<u32>@ offsets)
{
	u32 tilemapsize = this.tilemapwidth * this.tilemapheight;
	u32 stepsize = (tilemapsize + steps - 1) / steps;
	u32 start = i * stepsize;
	for (u32 tilestep = 0; tilestep < stepsize && start + tilestep < tilemapsize; tilestep++)
	{
		u32 offset = start + tilestep;
		if (TWMap::canTileFall(this.getTile(offset).type))
		{
			offsets.push_back(offset);
		}
	}
	return !offsets.empty();
}

//collapse tiles that do not have support
void collapseUnsupported(CMap@ this, array<u32>@ offsets)
{
	u32 tilemapsize = this.tilemapwidth * this.tilemapheight;
	while (!offsets.empty())
	{
		u32 offset = offsets[offsets.length - 1];
		offsets.pop_back();

		u32 belowoffset = offset + this.tilemapwidth;
		if (belowoffset < tilemapsize - 1)
		{
			if (!TWMap::givesSupport(this.getTile(belowoffset).type))
			{
				Vec2f tpos = TWMap::getTilePosition(this, offset);
				Vec2f tcentre = TWMap::getNearestTileCentrePos(this, tpos);

				createFallingBlock(tcentre, this.getTile(offset).type);
				this.server_SetTile(tcentre, TWMap::getTileBackgroundAt(this, offset));
			}
		}
	}
}

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	array<u32> offsets;
	//todo: would be much faster to have offsets precalculated
	//and just append changed tiles for processing
	int times_per_second = 4; //how many times to check over the map each second
	int steps = getTicksASecond() / times_per_second;
	if (gatherFallible(map, getGameTime() % steps, steps, offsets))
	{
		collapseUnsupported(map, offsets);
	}
}