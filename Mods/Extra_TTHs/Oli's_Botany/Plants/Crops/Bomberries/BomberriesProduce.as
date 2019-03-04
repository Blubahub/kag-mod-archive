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
			Explode(this, 5.0f, 1.0f);
			for (int i = 1; i <= this.get_u16("quality")/10+1; i++)
			{
				if (XORRandom(5) == 1) server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
				else if (XORRandom(4) == 1)MakeMat(this, this.getPosition(), "mat_bombarrows", 1);
				else MakeMat(this, this.getPosition(), "mat_bombs", 1);
			}
			Produce("boaboulder", 6, "kegerrynthis", 7, this);
		}
	}
}

