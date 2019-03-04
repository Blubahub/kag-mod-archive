// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "WAR_Technology.as";

const SColor color_hall(255, 211, 249, 193);

const SColor color_tradingpost_1(0xff8888ff);
const SColor color_tradingpost_2(0xffff8888);

const SColor color_mechhall(0xffffbe0a);
const SColor color_blackmarket(0xff130d1d);
const SColor color_ruin(0xff808000);

const SColor color_ivy(0xff49ac00);

const SColor color_fort_red(0xffff2a2a);
const SColor color_fort_blue(0xff2a2aff);
const SColor color_fort_green(0xff2aff2a);
const SColor color_fort_yellow(0xffffff2a);
const SColor color_fort_neutral(0xff8e8e8e);

const SColor color_tunnel_neutral(0xff464678);
const SColor color_coalmine_neutral(0xff373750);
const SColor color_merchant_neutral(0xff7878ff);
const SColor color_bitch_neutral(0xff7832e1);
const SColor color_pumpjack_neutral(0xff14507d);

const SColor color_badgerden(0xff46412d);
const SColor color_chickencoop(0xff964619);
const SColor color_scoutchicken(0xffb96437);

const SColor color_badger(0xff5a5546);
const SColor color_barbedwire(0xff5f6473);

const SColor color_info_desert(0xffffc896);

//the loader

class WarPNGLoader : PNGLoader
{

	WarPNGLoader()
	{
		super();
	}

	//override this to extend functionality per-pixel.
	void handlePixel(SColor pixel, int offset)
	{
		PNGLoader::handlePixel(pixel, offset);
		
		// if (pixel == color_fort_blue)
		// {
			// spawnBlob(map, "fortress", offset, 0);
			// offsets[autotile_offset].push_back(offset);
		// }
		// else if (pixel == color_fort_red)
		// {
			// spawnBlob(map, "fortress", offset, 1);
			// offsets[autotile_offset].push_back(offset);
		// }
		// else if (pixel == color_fort_green)
		// {
			// spawnBlob(map, "fortress", offset, 2);
			// offsets[autotile_offset].push_back(offset);
		// }
		// else if (pixel == color_fort_yellow)
		// {
			// spawnBlob(map, "fortress", offset, 3);
			// offsets[autotile_offset].push_back(offset);
		// }
		// else if (pixel == color_fort_neutral)
		// {
			// spawnBlob(map, "fortress", offset, -1);
			// offsets[autotile_offset].push_back(offset);
		// }
		
		// Buildings
		if (pixel == color_tunnel_neutral)
		{
			spawnBlob(map, "tunnel", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_coalmine_neutral)
		{
			spawnBlob(map, "coalmine", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_merchant_neutral)
		{
			spawnBlob(map, "merchant", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_bitch_neutral)
		{
			spawnBlob(map, "witchshack", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_pumpjack_neutral)
		{
			spawnBlob(map, "pumpjack", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		
		// else if (pixel == color_badgerden)
		// {
			// spawnBlob(map, "badgerden", offset, -1);
			// offsets[autotile_offset].push_back(offset);
		// }
		else if (pixel == color_chickencoop)
		{
			spawnBlob(map, "chickencoop", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_scoutchicken)
		{
			spawnBlob(map, "scoutchicken", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		
		// Map Info
		else if (pixel == color_info_desert)
		{
			spawnBlob(map, "info_desert", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_ruin)
		{
			CBlob@ ruins = spawnBlob(map, "ruins", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_ivy)
		{
			CBlob@ blob = spawnBlob(map, "ivy", offset, -1);
			offsets[autotile_offset].push_back(offset);
			
			blob.setPosition(blob.getPosition() + Vec2f(0, 16));
		}
		// else if (pixel == color_badger)
		// {
			// CBlob@ badger = spawnBlob(map, "badger", offset, -1);
			// offsets[autotile_offset].push_back(offset);
		// }
		else if (pixel == color_barbedwire)
		{
			CBlob@ barbedwire = spawnBlob(map, "barbedwire", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		PNGLoader::handleOffset(type, offset, position, count);

		const Vec2f pos = getSpawnPosition(map, offset);
	}
}

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING WAR PNG MAP " + fileName);

	WarPNGLoader loader();

	return loader.loadMap(map , fileName);
}
