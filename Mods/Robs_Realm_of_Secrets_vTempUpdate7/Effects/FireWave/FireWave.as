void onInit(CBlob @ this)
{
	this.set_s16("size", 1);
	this.set_s16("maxsize", 10);
}

void onTick(CBlob@ this)
{

	this.set_s16("size", this.get_s16("size")+1);
	if(getNet().isServer())if(this.get_s16("size") > this.get_s16("maxsize"))this.server_Die();

	for (int doFirey = -this.get_s16("size")*4; doFirey <= this.get_s16("size")*4; doFirey += 8)
	{
		for (int doFirex = -this.get_s16("size")*4; doFirex <= this.get_s16("size")*4; doFirex += 8)
		{
			Vec2f pos = Vec2f(this.getPosition().x + doFirex, this.getPosition().y + doFirey);
			if(Maths::Sqrt((Maths::Pow(pos.x-this.getPosition().x,2))+(Maths::Pow(pos.y-this.getPosition().y,2))) <= this.get_s16("size")*4)
			if(Maths::Sqrt((Maths::Pow(pos.x-this.getPosition().x,2))+(Maths::Pow(pos.y-this.getPosition().y,2))) >= this.get_s16("size")*4-4){
				getMap().server_setFireWorldspace(pos, true);
			}
		}
	}
	
	if(getNet().isServer()){
		this.Sync("size",true);
	}
}