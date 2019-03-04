
void onInit(CBlob@ this)
{
	if(getNet().isServer())this.server_SetTimeToDie(30);
	
	SColor color_red(0xffff0000);
	
	client_AddToChat("Money is raining from the sky, go grab some!", color_red);
	
	getRules().Tag("money_rain");
}

void onTick(CBlob @ this){

	CMap @ map = getMap();
	
	server_DropCoins(Vec2f(XORRandom(map.tilemapwidth*map.tilesize),0), XORRandom(5));

}

void onDie(CBlob @ this){

	getRules().Untag("money_rain");

}