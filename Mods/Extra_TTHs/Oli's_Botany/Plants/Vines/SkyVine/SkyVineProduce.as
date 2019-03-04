//create produce if you have grain!
#include "MakeSeed.as";
#include "Produce.as";
#include "Explosion.as";
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (XORRandom(18) == 1) Produce("builder", 7, "goldat", 0, this);
	}
}