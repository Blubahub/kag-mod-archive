// TDM PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";

const SColor color_tradingpost_1(0xff8888ff);
const SColor color_tradingpost_2(0xffff8888);
const SColor color_tent(0xff00ffff);
const SColor color_archer(0xff8080ff);
const SColor color_knight(0xff8000ff);
const SColor color_levelend(0xffffc800);
const SColor color_levelendalt(0xffff9600);

const SColor color_zombo(0xff96af32);

const SColor color_windboss(0xff0affff);

//the loader

class TDMPNGLoader : PNGLoader
{

	TDMPNGLoader()
	{
		super();
	}

	//override this to extend functionality per-pixel.
	void handlePixel(SColor pixel, int offset)
	{
		PNGLoader::handlePixel(pixel, offset);

		// TRADING POST
		if (pixel == color_tradingpost_1)
		{
			spawnBlob(map, "tradingpost", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_tradingpost_2)
		{
			spawnBlob(map, "tradingpost", offset, 1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_tent)
		{
			spawnBlob(map, "tent", offset, 0);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_archer)
		{
			SpawnMook(map.getTileWorldPosition(offset),"archer");
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_knight)
		{
			SpawnMook(map.getTileWorldPosition(offset),"knight");
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_levelend)
		{
			CBlob@ ruins = spawnBlob(map, "levelend", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_levelendalt)
		{
			CBlob@ ruins = spawnBlob(map, "levelendalt", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_windboss)
		{
			CBlob@ ruins = spawnBlob(map, "windlord", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_zombo)
		{
			CBlob@ ruins = spawnBlob(map, "zombie", offset, -1);
			offsets[autotile_offset].push_back(offset);
		}
		
		else {
			if(pixel.getGreen() == 201 && pixel.getRed() == 201){
				CBlob@ npc = spawnBlob(map, getNpc(pixel.getBlue()), offset, getNpcTeam(pixel.getBlue()));
				setupNpc(npc,pixel.getBlue());
				
				offsets[autotile_offset].push_back(offset);
			}
		}
	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		PNGLoader::handleOffset(type, offset, position, count);
	}
};

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING TDM PNG MAP " + fileName);

	TDMPNGLoader loader();

	return loader.loadMap(map , fileName);
}


CBlob@ SpawnMook(Vec2f pos, const string &in classname)
{
	CBlob@ blob = server_CreateBlobNoInit(classname);
	if (blob !is null)
	{
		//setup ready for init
		blob.setSexNum(XORRandom(2));
		blob.server_setTeamNum(3);
		blob.setPosition(pos + Vec2f(4.0f, 0.0f));
		blob.set_s32("difficulty", 15);
		SetMookHead(blob, classname);
		blob.Init();
		blob.SetFacingLeft(XORRandom(2) == 0);
		blob.getBrain().server_SetActive(true);
		blob.server_SetHealth(blob.getInitialHealth()/2);
		GiveAmmo(blob);
	}
	return blob;
}

void GiveAmmo(CBlob@ blob)
{
	if (blob.getName() == "archer")
	{
		CBlob@ mat = server_CreateBlob("mat_arrows");
		if (mat !is null)
		{
			blob.server_PutInInventory(mat);
		}
	}
}

void SetMookHead(CBlob@ blob, const string &in classname)
{
	const bool isKnight = classname == "knight";

	int head = 71;
	
	if (isKnight)
	{
		head = 71+XORRandom(2);
	}
	else
	{
		head = 74;
	}
	blob.setHeadNum(head);
}

string getNpc(int num){

	switch(num){
	
		case 0: return "kevinknight";
		
		case 1: return "villager"; //Man
		case 2: return "villager"; //Woman
		case 3: return "villager"; //Granny
		case 4: return "villager"; //Grampa
		case 5: return "villager"; //Kid
	
	}
	return "villager";
}

int getNpcTeam(int num){

	switch(num){
	
		case 0: return 1;
		
		case 1: return 0; //Man
		case 2: return 0; //Woman
		case 3: return 0; //Granny
		case 4: return 0; //Grampa
		case 5: return 0; //Kid
	
	}
	return -1;
}

void setupNpc(CBlob@ npc, int num){
	if(npc is null)return;
	npc.getBrain().server_SetActive(true);
	
	switch(num){
	
		case 1:{ 
			npc.set_u8("type",0);
			npc.setHeadNum(33+XORRandom(4));
			npc.setSexNum(0);
			npc.SetFacingLeft(XORRandom(2) == 0);
		break;}
		
		case 2:{ 
			npc.set_u8("type",1);
			npc.setHeadNum(33+XORRandom(3));
			npc.setSexNum(1);
			npc.SetFacingLeft(XORRandom(2) == 0);
		break;}
		
		case 3:{ 
			npc.set_u8("type",2);
			npc.setHeadNum(70);
			npc.setSexNum(0);
			npc.SetFacingLeft(XORRandom(2) == 0);
		break;}
		
		case 4:{ 
			npc.set_u8("type",3);
			npc.setHeadNum(70);
			npc.setSexNum(1);
			npc.SetFacingLeft(XORRandom(2) == 0);
		break;}
		
		case 5:{ 
			npc.set_u8("type",4);
			npc.setHeadNum(95+XORRandom(4));
			npc.setSexNum(XORRandom(2));
			npc.SetFacingLeft(XORRandom(2) == 0);
		break;}
	
	}
}