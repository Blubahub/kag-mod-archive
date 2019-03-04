


void onInit(CBlob@ this)
{
	this.set_u32("deathTime",(getGameTime() + (30 * 1)));
}

void onInit(CSprite@ this)
{
	print("hello world!");
	//Will need once we have animations and what not
}


void onTick(CBlob@ this)
{
	if(getGameTime() >= this.get_u32("deathTime"))
	{
		print("time to die!");
		this.server_Die();
	}

	//do some weird particle shit, idk	

}



void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	//set blob to have oil proc
	if(getNet().isServer())
	{
		if(blob is null || this is null)
			return;

		//print(blob.getName() + " has been oilled");
		blob.set_bool("Oilled",true); 
		blob.Sync("Oilled", true);

	}

}
