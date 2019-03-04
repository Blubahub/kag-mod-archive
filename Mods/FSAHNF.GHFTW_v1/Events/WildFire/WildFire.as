
void onInit(CBlob@ this)
{
	if(getNet().isServer())this.server_SetTimeToDie(10);
	
	SColor color_red(0xffff0000);
	
	client_AddToChat("The sun's quite hot, a wild fire has started!", color_red);
}

void onTick(CBlob @ this){

	CMap @ map = getMap();
	
	map.server_setFireTilespace(XORRandom(map.tilemapwidth), XORRandom(map.tilemapheight), true);

}