#include "ChatInfo.as";

#define CLIENT_ONLY

bool rulesShown = false;

void onTick(CRules@ this)
{
	if(!rulesShown && (getGameTime() + 1) % getTicksASecond() == 0)
	{
		rulesShown = true;
        ShowRules();
	}
}
