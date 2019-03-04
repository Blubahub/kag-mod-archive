void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.getCurrentScript().tickFrequency = 600;
	
	if (getNet().isServer())
	{
		this.server_setTeamNum(-1);
	}
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (XORRandom(100) < 40)
		{
			CBlob@[] chickens;
			getBlobsByTag("combat chicken", @chickens);
			
			if (chickens.length < 8)
			{
				CBlob@ blob = server_CreateBlob("scoutchicken", -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_DropCoins(this.getPosition(), 1000 + XORRandom(1500));
	}
}