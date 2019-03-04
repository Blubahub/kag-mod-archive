//create produce if you have grain!
#include "MakeSeed.as";
#include "MakeMat.as";
#include "Explosion.as";
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
			Explode(this, 20.0f, 2.0f);
			for (int i = 1; i <= this.get_u16("quality")/15 + 1; i++)
			{
				if (XORRandom(3) == 1)server_CreateBlob("keg", this.getTeamNum(), this.getPosition());
			}
		Produce("log", 9, "totemus", 8, this);
		}
	}
}

