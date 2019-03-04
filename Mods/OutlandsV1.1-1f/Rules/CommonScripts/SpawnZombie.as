#define SERVER_ONLY

const int min_zombies = 5;
u32 lastBoss = 0;
int spawned = 0;

void onTick(CRules@ this)
{
	if (getGameTime() % 119 != 0) return;
	if (XORRandom(512) < 256) return; //50% chance of actually doing anything
	string zombie_name = "Zombie";
	int typ = XORRandom(9);
	
	if (typ == 0)
	zombie_name = "ZombieKnight";
	if (typ == 1)
	zombie_name = "Wraith";
	if (typ == 2)
	zombie_name = "Greg";
	if (typ == 3 || typ == 4 || typ == 5)
	zombie_name = "Skeleton";
	if (typ >= 6)
	zombie_name = "Zombie";
	
	int gamestart = getRules().get_s32("gamestart");			
	int day_cycle = getRules().daycycle_speed*60;			
	int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
	
	
	
	CMap@ map = getMap();
	if (map is null || map.tilemapwidth < 2) return; //failed to load map?

	CBlob@[] zombie;
	getBlobsByName(zombie_name, @zombie);

	if (zombie.length < min_zombies)
	{
		if (zombie.length > 2 && XORRandom(4) < 1) //breed zombie (25% chance)
		{
			uint first = XORRandom(zombie.length);
			uint second = XORRandom(zombie.length);

			CBlob@ first_zombie = zombie[first];
			CBlob@ second_zombie = zombie[second];

			if (first != second && //not the same zombie
			        first_zombie.getDistanceTo(second_zombie) < 32 && //close
			        !first_zombie.hasTag("dead") && //both parents alive
			        !second_zombie.hasTag("dead"))
			{
				CBlob@ babby_zombie = server_CreateBlobNoInit(zombie_name);
				if (babby_zombie !is null)
				{
					babby_zombie.server_setTeamNum(-1);
					babby_zombie.setPosition((first_zombie.getPosition() + second_zombie.getPosition()) * 0.5f);

					//otherwise mutated, will be set in init

					babby_zombie.Init();
				}
			}
		}
		else //spawn from nowhere
		{
			f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;

			f32 y = 0;
			int posy = 0;
			while(y == 0 || posy == map.tilemapheight)
				if (map.isTileSolid(Vec2f(x, posy)))
					y = posy;
				else
					posy = posy + 1;

			//if (map.rayCastSolid(top, bottom, end))
			//{
				//f32 y = end.y;
				//int i = 0;
				//while (i ++ < 3)
				//{
					Vec2f pos = Vec2f(x, y -32);
					//if (map.isInWater(pos))
					//{
						server_CreateBlob(zombie_name, -1, pos);
						//print("     zombie spawned!!");
						//break;
					//}
				//}
			//}
		}
	}
	if ((dayNumber % 4) == 0 && spawned == 0)
		{
			f32 x = XORRandom(2) == 0 ? 32.0f : map.tilemapwidth * map.tilesize - 32.0f;
			server_CreateBlob( "BossZombieKnight", -1, Vec2f(x, map.getLandYAtX(s32(x / map.tilesize)) * map.tilesize - 16.0f));
			spawned = 1;
		}
	if ((dayNumber+1 % 4) == 0)
		{
			spawned = 0;
		}
}
