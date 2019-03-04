
//CTF gamemode logic script

#define SERVER_ONLY

//pass stuff to the core from each of the hooks

void Reset(CRules@ this)
{
	this.set_u16("gregspawn", 0);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	this.set_u16("gregspawn", this.get_u16("gregspawn")+1);
	
	if(this.get_u16("gregspawn") > 300){
		CBlob@ greg = server_CreateBlob("greg", -1, Vec2f(0,0));
		CMap@ map = greg.getMap();
		int width = map.tilemapwidth*8;
		greg.setPosition(Vec2f(width/2,0));
		this.set_u16("gregspawn", 0);
	}
	
	const string[] CLASSES = {"builder","archer","knight"};
	
	for(int j = 0; j < CLASSES.length; j += 1){
		CBlob@[] bodies;
		getBlobsByName(CLASSES[j], @bodies);
		for(uint i = 0; i < bodies.length; i++)
		{
			if(bodies[i].hasTag("dead"))
			{
				server_CreateBlob("zombie", -1, bodies[i].getPosition()); 
				bodies[i].server_Die();
			}
		}
	}
}