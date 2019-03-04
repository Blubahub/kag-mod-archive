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
			for (int i = 1; i <= this.get_u16("quality")/7 + 1; i++)
			{
				CBlob@ pebble = server_CreateBlob("pebble", this.getTeamNum(),this.getPosition());
				if (pebble !is null)
				{
					pebble.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
				}
			}
			Produce("boulder", 8, "boaboulder", 6, this);
			ExtraMutate("mat_gold", 8, "goldat", this);
		}
	}
}

