// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 5));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	AddIconToken("$heat_stack_icon$", "HeatStack.png", Vec2f(24, 24), 0);
	AddIconToken("$workshop_icon$", "BuilderShop.png", Vec2f(24, 24), 0);
	AddIconToken("$archery_icon$", "ArcherShop.png", Vec2f(24, 24), 0);
	AddIconToken("$barracks_icon$", "KnightShop.png", Vec2f(24, 24), 0);
	AddIconToken("$forge_icon$", "Forge.png", Vec2f(24, 24), 0);
	AddIconToken("$kitchen_icon$", "Kitchen.png", Vec2f(24, 24), 0);
	AddIconToken("$chest_icon$", "ChestShop.png", Vec2f(24, 24), 0);
	AddIconToken("$library_icon$", "Library.png", Vec2f(24, 24), 0);
	AddIconToken("$loomshop_icon$", "LoomShop.png", Vec2f(24, 24), 1);
	AddIconToken("$altar_icon$", "Altar.png", Vec2f(24, 24), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Workshop", "$workshop_icon$", "builder_shop", "For simple constructs and allows you to equip builder gear.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Large Chest", "$chest_icon$", "large_chest", "For storing valuables.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Barracks", "$barracks_icon$", "barracks", "For gearing up as a knight.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Archery", "$archery_icon$", "archery", "For creating arrows and switching to archer gear.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Kitchen", "$kitchen_icon$", "kitchen", "For cooking.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Textiles", "$loomshop_icon$", "loom_shop", "For weaving and sowing.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Heat Stack", "$heat_stack_icon$", "heat_stack", "A construction that transfers heat upwards, primarily used for industry.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Forge", "$forge_icon$", "forge", "For the smithing and forging of items.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bars", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Book shelf", "$library_icon$", "library", "For research of various subjects.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Altar", "$altar_icon$", "altar", "A place for sacrifice, worship and marriage.\nWhy did I say sacrifice three times?");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ item = getBlobByNetworkID(params.read_netid());
		if (item !is null && caller !is null)
		{
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();

			// open factory upgrade menu immediately
			if (item.getName() == "factory")
			{
				CBitStream factoryParams;
				factoryParams.write_netid(caller.getNetworkID());
				item.SendCommand(item.getCommandID("upgrade factory menu"), factoryParams);
			}
		}
	}
}
