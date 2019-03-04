//made by vamist :^
#define CLIENT_ONLY
#include "am_GlobalCom.as";
#include "am_UIHolder.as";

void onInit(CRules@ this)
{

}

void onTick(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if(p !is null)
	{
		if(p.get_bool("AM_open"))
		{
			p.set_bool("AM_open",false);
			loadMenu(p);
		}

	}
}


void loadMenu(CPlayer@ player)
{
	//aMenu@ menu = aMenu(); //works
	aMenu();
}