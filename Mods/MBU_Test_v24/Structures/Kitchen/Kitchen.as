// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "HumanoidClasses.as";

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 1));
	this.set_string("shop description", "Cook");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));

	AddIconToken("$steak_icon$", "Food.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Steak", "$steak_icon$", "cooked_steak", "Burnt on the outside, raw on the inside.", false);
		AddRequirement(s.requirements, "blob", "steak", "Raw Steak", 1);
	}
	AddIconToken("$bread$", "Food.png", Vec2f(16, 16), 4);
	{
		ShopItem@ s = addShopItem(this, "Bread", "$bread$", "bread", "Freshly baked bread.", false);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
	}
	AddIconToken("$herb$", "Herb.png", Vec2f(14, 9), 0);
	AddIconToken("$flower_bundle$", "FlowerBundle.png", Vec2f(13, 6), 0);
	{
		ShopItem@ s = addShopItem(this, "Herbs", "$herb$", "herb", "A collection of herbs, you hope.", false);
		AddRequirement(s.requirements, "blob", "flower_bundle", "Flower Bundle", 1);
	}
	AddIconToken("$burger_icon$", "Food.png", Vec2f(16, 16), 6);
	AddIconToken("$cooked_steak$", "Food.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Burger", "$burger_icon$", "burger", "Finally, 'Civilised' food.", false);
		AddRequirement(s.requirements, "blob", "cooked_steak", "Steak", 1);
		AddRequirement(s.requirements, "blob", "bread", "Bread", 2);
		AddRequirement(s.requirements, "blob", "herb", "Herbs", 2);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", this.isOverlapping(caller));
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
		}
	}
}
