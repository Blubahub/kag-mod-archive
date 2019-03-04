// Flowers logic
#include "MakeSeed.as"
#include "PlantGrowthCommon.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0); //random facing
	this.getSprite().ReloadSprites(uint(XORRandom(8)), 0); //random colour

	this.getSprite().SetZ(10.0f);

	this.set_u8(growth_chance, default_growth_chance);
	this.set_u8(growth_time, default_growth_time);
}

void onTick(CBlob @this){

	CBlob @attached = this.getAttachments().getAttachedBlob("PICKUP");

	if(attached !is null)
	if(getNet().isServer())
	if(!this.hasTag("dried")){
		this.server_Die();
		attached.DropCarried();
		attached.server_Pickup(server_CreateBlob("herb", -1, this.getPosition()));
		this.Tag("dried");
	}

}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}