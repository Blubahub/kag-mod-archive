






void onInit(CBlob@ this)
{

	CMap@ map = getMap();
	s32 width = map.tilemapwidth*8;
	s32 height = map.tilemapheight*8;
	this.setPosition(Vec2f(XORRandom(width), XORRandom(height)));
	if(XORRandom(2) == 1) this.set_Vec2f("target", Vec2f(this.getPosition().x, XORRandom(height)));
	else this.set_Vec2f("target", Vec2f(XORRandom(width), this.getPosition().y));
	this.server_SetTimeToDie(8);
	this.getShape().getConsts().collidable = false;
}

void onDie(CBlob@ this)
{
	if(XORRandom(4) == 3) server_CreateBlob("creator", 0, this.getPosition());
}

void onTick(CBlob@ this)
{	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	s32 width = map.tilemapwidth*8;
	s32 height = map.tilemapheight*8;/*
	if(this.getTickSinceCreated() > 60 && this.getTickSinceCreated() < 62) this.set_Vec2f("target", Vec2f(XORRandom(width), XORRandom(height)));
	if(this.getTickSinceCreated() > 100 && this.getTickSinceCreated() < 102)
	{
		if (XORRandom(10) > 4) this.set_Vec2f("target", Vec2f(pos.x, XORRandom(height)));
		else
		{
			this.set_Vec2f("target", Vec2f(XORRandom(width), pos.y));
		}
	}
	if(this.getTickSinceCreated() > 180 && this.getTickSinceCreated() < 182) this.set_Vec2f("target", Vec2f(XORRandom(width), XORRandom(height)));
*/

	if(XORRandom(60) == 1)
	{
		if(XORRandom(2) == 1) this.set_Vec2f("target", Vec2f(this.getPosition().x, XORRandom(height)));
		else this.set_Vec2f("target", Vec2f(XORRandom(width), this.getPosition().y));
	}
	Vec2f target = this.get_Vec2f("target");
	Vec2f diff = target - pos;
	diff.Normalize();
	this.setPosition(pos + diff*20);
	//this.AddForce(diff*100);
	if(XORRandom(400) == 1)
	{
		server_CreateBlob("rat", -1, this.getPosition());
		server_CreateBlob("rat", -1, this.getPosition());
		server_CreateBlob("rat", -1, this.getPosition());
	} 
	Vec2f drawPos = pos;

	drawPos.x-=16;
	drawPos.y-=16;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;

	drawPos = pos;

	drawPos.x-=16;
	drawPos.y-=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;

	drawPos = pos;

	drawPos.x-=16;
	drawPos.y-=0;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;

	drawPos = pos;

	drawPos.x-=16;
	drawPos.y+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;

	drawPos = pos;

	drawPos.x-=16;
	drawPos.y+=16;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
	getMap().server_SetTile(drawPos, CMap::tile_ground_back);
	drawPos.x+=8;
/*
	s8 size = 5;
	for(uint i = 0; i < size*size; i++)
	{
		s16 xPoint = i;
		s16 yPoint = 0;
		if(xPoint >= size)
		yPoint+=8;
		xPoint-=(yPoint*size);
		Vec2f drawPos = Vec2f(xPoint, yPoint);
		drawPos += pos;
		getMap().server_SetTile(drawPos, CMap::tile_ground_back);


	}*/

}
