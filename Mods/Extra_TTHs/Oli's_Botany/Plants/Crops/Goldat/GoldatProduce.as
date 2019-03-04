//create produce if you have grain!
#include "MakeSeed.as";
#include "MakeMat.as";
#include "Produce.as";
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (this.hasTag("has grain"))
		{
			ProduceMat("mat_gold", 8, "skyvine", "mat_gold", 10, 4, this);
		}
	}
}

