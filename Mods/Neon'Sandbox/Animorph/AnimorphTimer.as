//AnimorphTimer.as
//@author: Verrazano
//@description: Calls checkMorphTimer every 3rd tick to turn players back into their original blobs or kill them.
//@usage: add this file to gamemode.cfg.

#include "AnimorphCommon.as"

void onTick(CRules@ this)
{
	if(!getNet().isServer())
		return;

	if(getGameTime()%3 == 0)
		checkMorphTimer(this);

}