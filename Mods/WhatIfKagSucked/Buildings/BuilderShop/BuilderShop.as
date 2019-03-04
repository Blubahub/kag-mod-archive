// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Craft");
	this.set_u8("shop icon", 15);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");
	
	AddIconToken("$gunpowder_icon$", "GunPowder.png", Vec2f(16, 16), 3);
	AddIconToken("$bow_icon$", "Bow.png", Vec2f(16, 16), 0);

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LANTERN);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", descriptions[36], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BUCKET);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", descriptions[53], false);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", descriptions[17], false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 20);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW);
		AddRequirement(s.requirements, "blob", "sawblade", "Saw Blade", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bow", "$bow_icon$", "bow", "A bow, for archery.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Gun Powder", "$gunpowder_icon$", "mat_gunpowder", "For explosives.", false);
		AddRequirement(s.requirements, "blob", "mat_sand", "Sand", 125);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 125);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}