// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	getMap().server_SetTile(this.getPosition()+Vec2f(0,4), CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	AddIconToken("$lathe_icon$", "Lathe.png", Vec2f(24, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Lathe", "$lathe_icon$", "lathe", "A machine designed to fabricate machine parts in high quantities.");
		AddRequirement(s.requirements, "blob", "mat_machine_parts", "Machine Parts", 4);
		AddRequirement(s.requirements, "blob", "duram_bar", "Duram Bars", 2);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
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

			if (item.getName() == "lathe")
			{
				item.setPosition(item.getPosition()+Vec2f(0,8));
			}
		}
	}
}
