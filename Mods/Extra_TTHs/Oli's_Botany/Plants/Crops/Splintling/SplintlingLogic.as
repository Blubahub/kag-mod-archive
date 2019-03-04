// Grain logic

#include "PlantGrowthCommon.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0);
	this.set_u8(growth_time, 24 / ((this.get_u16("quality")/100)+1));
	this.set_u16("quality", this.get_u16("quality") + 3);
	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);

	this.Tag("builder always hit");

	// this script gets removed so onTick won't be run on client on server join, just onInit
	if (this.hasTag("instant_grow"))
	{
		GrowGrain(this);
	}
}


void onTick(CBlob@ this)
{
	if (this.hasTag(grown_tag))
	{
		GrowGrain(this);
	}
}

void GrowGrain(CBlob @this)
{
	this.Tag("has grain");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
