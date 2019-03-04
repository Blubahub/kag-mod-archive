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
			for (int i = 1; i <= this.get_u16("quality")/9+1; i++)
			{
				CBlob@ logs = server_CreateBlob("log", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
				if (logs !is null)
				{
					logs.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
				}
			}
			Produce("boulder", 4, "pebbler", 5, this);
			ExtraMutate("mat_stone", 5, "pebbler", this);
			ExtraMutate("bush", 2, "thorns", this);
			ExtraMutate("builder", 40, "taintthorns", this);
		}
	}
}

