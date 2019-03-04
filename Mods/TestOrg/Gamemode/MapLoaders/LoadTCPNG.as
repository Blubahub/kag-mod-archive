// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "CustomBlocks.as";

namespace tc_colors
{
	enum color
	{
		color_mechhall = 0xffffbe0a,
		color_blackmarket = 0xff130d1d,
		color_ruin = 0xff808000,

		color_ivy = 0xff49ac00,
		color_crystal = 0xff1dffb7,
		color_lamppost = 0xffffdd26,

		color_fort_red = 0xffff2a2a,
		color_fort_blue = 0xff2a2aff,
		color_fort_green = 0xff2aff2a,
		color_fort_yellow = 0xffffff2a,
		color_fort_neutral = 0xff8e8e8e,

		color_tunnel_neutral = 0xff464678,
		color_coalmine_neutral = 0xff373750,
		color_merchant_neutral = 0xff7878ff,
		color_bitch_neutral = 0xff7832e1,
		color_pumpjack_neutral = 0xff14507d,

		color_badgerden = 0xff46412d,
		color_chickencoop = 0xff964619,
		color_scoutchicken = 0xffb96437,
		color_lootchest = 0xffffd200,
		color_bannerchicken = 0xffbe3838,
		color_irondoor_chicken = 0xffcfbaba,
		color_chickenmarket = 0xffdccb7b,
		color_civillianchicken = 0xffb98c75,
		color_zapper_chicken = 0xff75b9ab,
		color_ceiling_lamp = 0xffd7f5f8,
		color_car = 0xff523535,
		color_sam = 0xff6f848c,
		color_lws = 0xffd77474,
		color_merchantchicken = 0xffbec728,

		color_badger = 0xff5a5546,
		color_barbedwire = 0xff5f6473,

		color_glass = 0xff6d95a1,
		color_glass_bg = 0xff5a7a83,
		color_iron = 0xff5f5f5f,
		color_iron_bg = 0xff454545,
		color_concrete = 0xffadaa96,
	};
}

class TCPNGLoader : PNGLoader
{
	TCPNGLoader()
	{
		super();
	}

	void handlePixel(const SColor &in pixel, int offset) override
	{
		PNGLoader::handlePixel(pixel, offset);

		switch (pixel.color)
		{
			case tc_colors::color_tunnel_neutral:
			{
				spawnBlob(map, "tunnel", offset, -1);
				break;
			}
			
			case tc_colors::color_coalmine_neutral:
			{
				spawnBlob(map, "coalmine", offset, -1);
				break;
			}
			
			case tc_colors::color_merchant_neutral:
			{
				spawnBlob(map, "merchant", offset, -1);
				break;
			}

			case tc_colors::color_bitch_neutral:
			{
				spawnBlob(map, "witchshack", offset, -1);
				break;
			}
			case tc_colors::color_pumpjack_neutral:
			{
				spawnBlob(map, "pumpjack", offset, -1);
				break;
			}
			
			case tc_colors::color_badgerden:
			{
				spawnBlob(map, "badger", offset, -1);
				break;
			}
			case tc_colors::color_chickencoop:
			{
				spawnBlob(map, "chickencoop", offset, -1);
				break;
			}
			case tc_colors::color_scoutchicken:
			{
				f32 rand = XORRandom(100);
			
				if (rand < 15)
				{
					CBlob@ blob = spawnBlob(map, "heavychicken", offset, -1);
					blob.set_bool("raider", false);
				}
				else if (rand < 50)
				{
					CBlob@ blob = spawnBlob(map, "soldierchicken", offset, -1);
					blob.set_bool("raider", false);
				}
				else
				{
					CBlob@ blob = spawnBlob(map, "scoutchicken", offset, -1);
					blob.set_bool("raider", false);
				}
			
				break;
			}
			case tc_colors::color_lootchest:
			{
				spawnBlob(map, "lootchest", offset, -1);
				break;
			}
			
			case tc_colors::color_ruin:
			{
				spawnBlob(map, "ruins", offset, -1);
				break;
			}
			case tc_colors::color_ivy:
			{
				CBlob@ blob = spawnBlob(map, "ivy", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, 16));
				break;
			}
			case tc_colors::color_bannerchicken:
			{
				CBlob@ blob = spawnBlob(map, "bannerchicken", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, 16));
				break;
			}
			case tc_colors::color_crystal:
			{
				spawnBlob(map, "crystal", offset, -1);
				break;
			}
			case tc_colors::color_lamppost:
			{
				CBlob@ blob = spawnBlob(map, "lamppost", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_badger:
			{
				spawnBlob(map, "badger", offset, -1);
				break;
			}
			case tc_colors::color_glass:
			{
				map.SetTile(offset, CMap::tile_glass);
				break;
			}
			case tc_colors::color_glass_bg:
			{
				map.SetTile(offset, CMap::tile_bglass);
				break;
			}
			case tc_colors::color_iron:
			{
				map.SetTile(offset, CMap::tile_iron);
				break;
			}
			case tc_colors::color_iron_bg:
			{
				map.SetTile(offset, CMap::tile_biron);
				break;
			}
			case tc_colors::color_concrete:
			{
				map.SetTile(offset, CMap::tile_concrete);
				break;
			}
			case tc_colors::color_irondoor_chicken:
			{
				spawnBlob(map, "iron_door", offset, 250);
				break;
			}
			case tc_colors::color_chickenmarket:
			{
				CBlob@ blob = spawnBlob(map, "chickenmarket", offset, 250);	
				blob.setPosition(blob.getPosition() + Vec2f(0, -16));
				break;
			}
			case tc_colors::color_civillianchicken:
			{
				spawnBlob(map, "civillianchicken", offset, 250);
				break;
			}
			case tc_colors::color_barbedwire:
			{
				spawnBlob(map, "barbedwire", offset, -1);
				break;
			}
			case tc_colors::color_zapper_chicken:
			{
				CBlob@ blob = spawnBlob(map, "zapper", offset, 250);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_ceiling_lamp:
			{
				CBlob@ blob = spawnBlob(map, "ceilinglamp", offset, 255);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_merchantchicken:
			{
				CBlob@ blob = spawnBlob(map, "merchantchicken", offset, 250);
				blob.setPosition(blob.getPosition() + Vec2f(0, 0));
				break;
			}
			case tc_colors::color_car:
			{
				spawnBlob(map, "car", offset, -1);
				break;
			}
			case tc_colors::color_sam:
			{
				spawnBlob(map, "sam", offset, 250);
				break;
			}
			case tc_colors::color_lws:
			{
				spawnBlob(map, "lws", offset, 250);
				break;
			}
		};
	}
}

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING TC PNG MAP " + fileName);

	TCPNGLoader loader();

	return loader.loadMap(map , fileName);
}