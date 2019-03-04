// Grain logic

#include "PlantGrowthCommon.as";
#include "Hitters.as";
#include "canGrow.as";
void onInit(CBlob@ this)
{
	this.set_u8(growth_time, 1);
	this.set_u16("quality", this.get_u16("quality") + 3);
	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);
	this.Tag("builder always hit");
	this.Tag("vine");
	if(getNet().isServer())
	{
		this.server_SetTimeToDie(10);
	}
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
	
	Vec2f position = this.getPosition();
	string name = this.getName();
	if(this.get_u8("vine number") < 20)
	{
		printf("Number of vines: " + this.get_u8("vine number"));
		CBlob@ vine = server_CreateBlob(name, -1, Vec2f(position + Vec2f(0, -8)));
		if( vine !is null)
		{
			vine.set_u8("vine number", this.get_u8("vine number") + 1);
		}
	}
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}