
void onInit(CBlob@ this)
{
	this.set_u32("time", 0);
	
	SColor color_red(0xffff0000);
	
	client_AddToChat("Meteors have started to rain from the sky, find cover!", color_red);
	
	if(getNet().isServer())this.server_SetTimeToDie(35);
}

void onTick(CBlob @ this){
	if(getNet().isServer()){

		this.set_u32("time", this.get_u32("time")+1);
		
		bool dropMeteor = false;
		bool dropMiniMeteor = false;
		
		if(Maths::FMod(this.get_u32("time"),30*10) == 0)dropMeteor = true;
		if(Maths::FMod(this.get_u32("time"),30) == 0)dropMiniMeteor = true;
		
		if(dropMeteor){
			CMap @ map = getMap();
			{
				CBlob @meteor = server_CreateBlob("meteor",-1,Vec2f(XORRandom(map.tilemapwidth*map.tilesize/2),0));
				meteor.SendCommand(meteor.getCommandID("activate"));
			}
			{
				CBlob @meteor = server_CreateBlob("meteor",-1,Vec2f(XORRandom(map.tilemapwidth*map.tilesize/2)+(map.tilemapwidth*map.tilesize/2),0));
				meteor.SendCommand(meteor.getCommandID("activate"));
			}
		}
		
		if(dropMiniMeteor){
			CMap @ map = getMap();
			{
				CBlob @meteor = server_CreateBlob("minimeteor",-1,Vec2f(XORRandom(map.tilemapwidth*map.tilesize/2),0));
			}
			{
				CBlob @meteor = server_CreateBlob("minimeteor",-1,Vec2f(XORRandom(map.tilemapwidth*map.tilesize/2)+(map.tilemapwidth*map.tilesize/2),0));
			}
		}
		
		
	}
}