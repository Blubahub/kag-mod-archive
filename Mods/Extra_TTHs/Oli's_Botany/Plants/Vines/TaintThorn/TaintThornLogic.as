// Grain logic

#include "PlantGrowthCommon.as";
#include "Hitters.as";
#include "canGrow.as";
void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0);
	this.set_u8(growth_time, 40);
	this.set_u16("quality", this.get_u16("quality") + 3);
	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);
	this.Tag("builder always hit");
	this.Tag("vine");
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
	
	CBlob@[] sky;
	getBlobsByName(name, @sky);
	
	if(sky.length > 200)
	{
		for(uint i = 0; i <= 190; i++)
		{
			if (sky[i] !is null)
			{
				sky[i].server_Die();
			}
		}
	}
	server_CreateBlob(name, -1, Vec2f(position + Vec2f(XORRandom(3)-1*4, -15)));
	server_CreateBlob(name, -1, Vec2f(position + Vec2f(XORRandom(3)-1*2, -10)));
	
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}