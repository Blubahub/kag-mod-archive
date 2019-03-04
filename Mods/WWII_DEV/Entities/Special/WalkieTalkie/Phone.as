// ArcherShop.as

#include "MakeCrate.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "MakeSeed.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 1;
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "SpaceStar Ordering!");
	this.set_u8("shop icon", 11);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem(this, "Nuke!", "$nuke$", "b29", "Orders a powerful b29 bomber to drop a thermonuclear warhead on the middle of the map!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
	}

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
		this.set_bool("shop available", false);
		this.set_u32("next use", getGameTime() + 300);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", getGameTime() >= this.get_u32("next use"));
}