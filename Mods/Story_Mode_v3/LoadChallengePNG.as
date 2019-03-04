// TDM PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";

const SColor color_tradingpost_1(0xff8888ff);
const SColor color_tradingpost_2(0xffff8888);
const SColor color_tent(0xff00ffff);
const SColor color_archer(0xff19ffb6);
const SColor color_knight(0xffff5f19);
const SColor color_levelend(0xff808000);
const SColor color_levelendalt(0xff808040);

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
		
		else {
			if(pixel.getGreen() == 201 && pixel.getRed() == 201){
				CBlob@ npc = spawnBlob(map, getNpc(pixel.getBlue()), offset, getNpcTeam(pixel.getBlue()));
				npc.getBrain().server_SetActive(true);
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
	
	}
	return "migrant";
}

int getNpcTeam(int num){

	switch(num){
	
		case 0: return 1;
	
	}
	return -1;
}