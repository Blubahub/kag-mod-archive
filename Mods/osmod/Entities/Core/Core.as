

void onInit(CBlob@ this)
{
	this.set_s32("amount", XORRandom(10));
	this.set_s32("interval", 40);
	this.set_s32("timer", 0);
	this.set_s32("interval2", 1);
	this.set_s32("timer2", 0);
	this.set_s32("timer3", 0);
	CMap@ map = this.getMap();
	if (map !is null)
	{
		s32 mapwidth = map.tilemapwidth * map.tilesize;
		s32 mapheight = map.tilemapheight * map.tilesize;
		s32 chestamount = 5+XORRandom(5);
		this.set_Vec2f("spawnpoint left", Vec2f(0, 10));
		this.set_Vec2f("spawnpoint right", Vec2f(mapwidth, 10));
		if(!getNet().isServer()) return;
		for(uint i = 0; i < chestamount; i++)
		{
			Vec2f chestpos = Vec2f(XORRandom(mapwidth), XORRandom(mapheight));
			CBlob@ chest = server_CreateBlob("chest", -1, chestpos);

		}

	}
}

void onTick(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;
	s32 interval = this.get_s32("interval");
	s32 timer = this.get_s32("timer");
	s32 interval2 = this.get_s32("interval2");
	s32 timer2 = this.get_s32("timer2");
	s32 timer3 = this.get_s32("timer3");
	s32 timer4 = this.get_s32("timer4");

	timer++;
	timer2++;
	timer3++;
	timer4++;

	if(timer >= interval)
	{
		timer = 0;
		spawnEnemies(this);

	}

	if(timer2 >= interval2)
	{
		timer2 = 0;
		spawnChests(this);

	}

	if(timer3 > 500 && timer4 >= 60 && XORRandom(32) >= 24)
	{
		timer4 = 0;
		Airstrike(this);

	}
	this.set_s32("timer", timer);
	this.set_s32("timer2", timer2);
	this.set_s32("timer3", timer3);
	this.set_s32("timer4", timer4);
}

void spawnEnemies(CBlob@ this)
{
	Vec2f leftpos = this.get_Vec2f("spawnpoint left");
	Vec2f rightpos = this.get_Vec2f("spawnpoint right");
	Vec2f midpos = this.get_Vec2f("spawnpoint right");
	s32 amount = this.get_s32("amount");
	s32 timer3 = this.get_s32("timer3");
	if(!getNet().isServer()) return;
	for(uint i = 0; i < amount; i++)
	{
		midpos.x = midpos.x/(1+XORRandom(8));
		string enemyname = "skeleton";// XORRandom(50) > 25 ? "skeleton" : "zombie";
		string enemyname2 = "zombie";// XORRandom(50) > 25 ? "skeleton" : "zombie";
		string enemyname3 = "zombieknight";
		string enemyname4 = XORRandom(50) > 25 ? "greg" : "wraith";

		CBlob@[] enemies;
		CBlob@[] enemies2;
		CBlob@[] enemies3;
		CBlob@[] enemies4;
		if(getBlobsByName(enemyname, @enemies))
		{
			if (timer3 > 180 && enemies.length < 40 || enemies.length < 20)
			{
				CBlob@ enemy = server_CreateBlob(enemyname, -1, leftpos);
				CBlob@ enemy2 = server_CreateBlob(enemyname, -1, rightpos);
				CBlob@ enemy3 = server_CreateBlob(enemyname, -1, midpos);
			}

		}		

		if(!getBlobsByName(enemyname, @enemies))
		{
			CBlob@ enemy = server_CreateBlob(enemyname, -1, leftpos);
			CBlob@ enemy2 = server_CreateBlob(enemyname, -1, rightpos);
		}	

		if(getBlobsByName(enemyname2, @enemies2) && timer3 > 200)
		{
			if (enemies2.length < 40)
			{
				CBlob@ enemy = server_CreateBlob(enemyname2, -1, rightpos);
				CBlob@ enemy2 = server_CreateBlob(enemyname2, -1, leftpos);
				CBlob@ enemy3 = server_CreateBlob(enemyname2, -1, midpos);
			}

		}		

		if(!getBlobsByName(enemyname2, @enemies2) && timer3 > 200)
		{
			CBlob@ enemy = server_CreateBlob(enemyname2, -1, rightpos);
			CBlob@ enemy2 = server_CreateBlob(enemyname2, -1, leftpos);
		}		

		if(getBlobsByName(enemyname3, @enemies3) && timer3 > 320)
		{
			if (enemies2.length < 20)
			{
				CBlob@ enemy = server_CreateBlob(enemyname3, -1, rightpos);
				CBlob@ enemy2 = server_CreateBlob(enemyname3, -1, leftpos);
			}
		}		

		if(!getBlobsByName(enemyname3, @enemies3) && timer3 > 320)
		{
			CBlob@ enemy = server_CreateBlob(enemyname3, -1, rightpos);
			CBlob@ enemy2 = server_CreateBlob(enemyname3, -1, leftpos);
		}

		if(getBlobsByName(enemyname4, @enemies4))
		{
			if (enemies2.length < 10 && XORRandom(100) > 80 && timer3 > 400)
			{
				CBlob@ enemy = server_CreateBlob(enemyname4, -1, rightpos);
				CBlob@ enemy2 = server_CreateBlob(enemyname4, -1, leftpos);
			}
		}		

		if(!getBlobsByName(enemyname4, @enemies4) && XORRandom(100) > 80 && timer3 > 400)
		{
			CBlob@ enemy = server_CreateBlob(enemyname4, -1, rightpos);
			CBlob@ enemy2 = server_CreateBlob(enemyname4, -1, leftpos);
		}

		midpos = this.get_Vec2f("spawnpoint right");
	}

	this.set_s32("amount", XORRandom(25));
}


void spawnChests(CBlob@ this)
{
	//print("players: "+getPlayersCount());
	s32 relativeamount = (getPlayersCount()* 5) -getPlayersCount();
	s32 amount = XORRandom(10);
	//print("relative amount of chests: "+relativeamount);
	if(!getNet().isServer()) return;
	for(uint i = 0; i < amount; i++)
	{
		CMap@ map = this.getMap();
		if (map is null) return;
		s32 rightpos = map.tilemapwidth * map.tilesize;
		Vec2f midpos = this.get_Vec2f("spawnpoint right");
		midpos.x = XORRandom(rightpos);
		string chestname = "chest";// XORRandom(50) > 25 ? "skeleton" : "zombie";

		CBlob@[] chests;
		if(getBlobsByName(chestname, @chests))
		{
			if (chests.length < relativeamount)
			{
				CBlob@ chest = server_CreateBlob(chestname, -1, midpos);
			}

		}		

		if(!getBlobsByName(chestname, @chests))
		{
			CBlob@ chest = server_CreateBlob(chestname, -1, midpos);
		}	

		this.set_s32("interval2", 40+XORRandom(60));
	}

}


void Airstrike(CBlob@ this)
{/*
	s32 amount = XORRandom(10);
	for(uint i = 0; i < amount; i++)
	{
		CMap@ map = this.getMap();
		if (map is null) return;
		s32 rightpos = map.tilemapwidth * map.tilesize;
		Vec2f midpos = this.get_Vec2f("spawnpoint right");
		midpos.y = 50;
		midpos.x = XORRandom(rightpos);
		if(!getNet().isServer()) return;
		CBlob@ rocket = server_CreateBlob("rocket", -1, midpos);
		if(rocket is null) return;
		rocket.server_SetQuantity(1);
		rocket.server_setTeamNum(-1);
		rocket.AddForce(Vec2f(-3+XORRandom(6), 5+XORRandom(5)));
		rocket.setPosition(midpos);
	

	}
*/

	const uint8 INTERVAL = 18;
	int16 amount = 1;
	s32 teamNum = -1;
	string blobName = XORRandom(32) > 16 ? "rocket" : "bomb";

	CMap@ map = getMap();
	if(map !is null) {
		uint16 tileSize = map.tilesize;
		uint16 tileMapWidth = map.tilemapwidth;
		uint16 mapWidth = tileMapWidth * tileSize;

		const uint8 ECCENTRICITY = 3;

		int16 posX = 0;
		int16 posY = 0;
		Vec2f pos;

		float velX;
		float velY;
		Vec2f velocity;
		
		float torque = -200 + XORRandom(400);

		bool activatedKeg = false;
		if(blobName == "lkeg") {
			blobName = "keg";
			activatedKeg = true;
		}

		for(uint16 i = 0; i < tileMapWidth; i += INTERVAL) {
			pos = Vec2f(posX, posY);
			if(posX < mapWidth) {
							
				CBlob@ blob = server_CreateBlob(blobName, teamNum, pos);
				blob.server_SetQuantity(amount);
				if(activatedKeg == true) {
					blob.SendCommand(blob.getCommandID("activate"));
				} 

				velX = XORRandom(2);
				velY = XORRandom(ECCENTRICITY);
				torque = XORRandom(ECCENTRICITY);

				if(XORRandom(2) == 1) {
					velX = 0 - velX;
				}
				if(XORRandom(2) == 1) {
					torque = 0 - torque;
				}

				velocity = Vec2f(velX, velY);
				blob.setVelocity(velocity + blob.getOldVelocity());
				blob.AddTorque(torque);
				if(blob.getShape() !is null)
				{
					blob.getShape().SetGravityScale(0.2f);
				}
				posX = tileSize * i + XORRandom(INTERVAL);
				posY = tileSize * XORRandom(INTERVAL);
			}
		}
	}

}
