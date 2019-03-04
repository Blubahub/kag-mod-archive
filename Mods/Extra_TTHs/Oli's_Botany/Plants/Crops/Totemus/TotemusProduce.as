//create produce if you have grain!
#include "MakeSeed.as";
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
			Produce("error", 0, "error", 20, this);
		}
	}
}

