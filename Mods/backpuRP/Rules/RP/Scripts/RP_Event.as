//Event system
//Spawns bosses, random enemies and so on, some can get triggered and some will be map based.

#define SERVER_ONLY

void onInit(CRules@ this)
{

}


void onTick(CRules@ this)
{
	//print(""+(getGameTime()) );
	if(getGameTime() == 900)
	{
		//spawn pos Vec2f 3858 , 2988
		CMap@ map = getMap();
		if(map.getMapName() == "Maps/Vamist/map1.png")
		{
			server_CreateBlob("Mecha_Robot_Boss",-1,Vec2f(3858,2988));
		}
	}
}