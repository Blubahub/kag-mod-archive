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
			Produce("bomb", 2, "bomberries", 6, this);
			ExtraMutate("knight", 6, "totemus", this);
			ExtraMutate("knight", 40, "taintthorns", this);
		}
	}
}

