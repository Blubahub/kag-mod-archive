#include "Hitters.as";

void onInit(CBlob@ this)
{
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer())
	{
		u32 g_time = getGameTime();
		if (g_time % 4 == 0 && getRules().get_u32("lastsnowtime")!=g_time )
		{
			int map_width = getMap().tilemapwidth * 8;
			int map_height = getMap().tilemapheight * 8;
			Noise@ snow_noise = Noise(0);
			int amount = snow_noise.Sample(g_time/1000.0,0)*15;
			for (int i = 0; i < amount*5; i++)
			{
				Vec2f pos = Vec2f(XORRandom(map_width),XORRandom(map_height/4) + (map_height)/4);
				if (getMap().getTile(pos).type == CMap::tile_empty)
					ParticleBlood(pos, Vec2f((XORRandom(32)-16)/16.0f,(XORRandom(32)-16)/16.0f), SColor(255,255,255,255));
			}
				//ParticleAnimated( CFileMatcher("snowpart1.png").getFirst(), Vec2f(XORRandom(map_width),XORRandom(map_height/4) + (map_height)/4), Vec2f((XORRandom(32)-16)/16.0f,(XORRandom(32)-16)/16.0f), 0.0f, 1.0f, 255, 0.01f, false );
			getRules().set_u32("lastsnowtime",g_time);
 		}
	}
	if (getNet().isServer())
	{
		CMap@ map = getMap();
		if (getGameTime() % 70 == 0 && map !is null)
		{
			int map_width = getMap().tilemapwidth;
			int map_height = getMap().tilemapheight;
			int rx,ry;
			int offset;
			bool not_found = true;
			int giveup=0;
			while (not_found)
			{
				rx=XORRandom(map_width);
				ry=XORRandom(map_height);
				offset = rx + ry*map_width;
				if (map.getTile(offset).type == CMap::tile_castle_moss && map.getTile(offset-map_width).type == CMap::tile_empty) 
				{
					map.server_SetTile(Vec2f(rx*8,ry*8-8), CMap::tile_grass );
					not_found=false;
				}
				if (map.getTile(offset).type == CMap::tile_wood && map.getTile(offset-map_width).type == CMap::tile_empty) 
				{
					map.server_SetTile(Vec2f(rx*8,ry*8-8), CMap::tile_grass );
					not_found=false;
				}
				
				if (map.getTile(offset).type == CMap::tile_castle)
				{
					map.server_SetTile(Vec2f(rx*8,ry*8), CMap::tile_castle_moss );
					not_found=false;
				}
				if (map.getTile(offset).type == CMap::tile_castle_back)
				{
					map.server_SetTile(Vec2f(rx*8,ry*8), CMap::tile_castle_back_moss );
					not_found=false;
				}
				if (map.isTileGroundStuff(map.getTile(offset).type) && map.getTile(offset).type != CMap::tile_ground_back && map.getTile(offset-map_width).type == CMap::tile_empty) 
				{
					map.server_SetTile(Vec2f(rx*8,ry*8-8), CMap::tile_grass );
					not_found=false;
				}
				
				giveup++;
				if (giveup>15) not_found=false; // don't tax server too much randomly checking
			}
		}
	}
}
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{

	if (!getNet().isServer())
	{
		for (int i=0; i<15; i++)
		{
////			ParticleAnimated( CFileMatcher("snowpart1.png").getFirst(), Vec2f(this.getPosition().x+16-XORRandom(32),this.getPosition().y-XORRandom(32)), Vec2f(0.0f,0.0f), 0.0f, 1.0f, 255, 0.01f, false );
			ParticleBlood(Vec2f(this.getPosition().x+16-XORRandom(32),this.getPosition().y-XORRandom(32)), Vec2f(0,0), SColor(255,255,255,255));
		}
	}

    if (damage > 0.05f) //sound for all damage
    {
        this.getSprite().PlaySound( CFileMatcher("/TreeChop").getRandom() );
        makeGibParticle( CFileMatcher("/GenericGibs").getRandom(), worldPoint, getRandomVelocity( (this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f )+Vec2f(0.0f,-2.0f),
                         0, 4+XORRandom(4), Vec2f(8,8), 2.0f, 0, "", 0 );
    }

    if (customData == Hitters::sword)
    {
        damage *= 0.5f;
    }

    return damage;
}


