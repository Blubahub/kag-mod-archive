#include "AddTilesBySector.as";

#define SERVER_ONLY

// set this.set_TileType("background tile", CMap::tile_castle_back);

//use back flag to indicate no background

const string counter = "nobuild counter";
const string back = "background tile";
const string nobuild_extend = "nobuild extend";
const int CHECK_FREQ = 35;

void onInit(CBlob@ this)
{
	this.set_u8(counter, 1);
	this.getCurrentScript().tickFrequency = 5;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency != CHECK_FREQ)
	{
		u8 c = this.get_u8(counter);
		if (c > 0)
		{
			c--;
			this.set_u8(counter, c);
			return;
		}

		Vec2f ul, lr;
		Vec2f extend;
		if (this.exists(nobuild_extend))
		{
			extend = this.get_Vec2f(nobuild_extend);
		}

		this.getShape().getBoundingRect(ul, lr);
		ul.x += 1.0f;
		ul.y += 1.0f;

		lr += extend;
		this.getMap().server_AddSector(ul, lr, "no build", "", this.getNetworkID());
		lr -= extend;

		this.getCurrentScript().tickFrequency = CHECK_FREQ;
	}
	else // check for collapse
		if (getNet().isServer())
		{
			CMap@ map = getMap();
			f32 tilesize = map.tilesize;
			Vec2f bpos = this.getPosition()-Vec2f(tilesize/2,0);
			Vec2f[] floor = {
								bpos + Vec2f(-tilesize*2, tilesize*2),
								bpos + Vec2f(-tilesize, tilesize*2),
								bpos + Vec2f(0, tilesize*2),
								bpos + Vec2f(tilesize, tilesize*2),
								bpos + Vec2f(tilesize*2, tilesize*2)
							};
			int count = 0;
			for (uint f = 0; f < 5; f++)
			{
				Vec2f temp = floor[f];
				Tile tile = map.getTile(temp);
				if (map.isTileSolid(tile)) count++;
			}

			// die because there is no back

			if(count != 5)
				this.server_Hit(this, this.getPosition(), Vec2f_zero, 5.0f, 0, true);
		}
}

