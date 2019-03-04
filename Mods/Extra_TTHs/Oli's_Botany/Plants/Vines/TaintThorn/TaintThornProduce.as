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
		this.set_bool("map_damage_raycast", false);
		Explode(this, 10.0f, 1.0f);
		ExtraMutate("arrow", 6, "bomberries", this);
		ExtraMutate("magilog", 5, "boaboulder", this);
	}
}