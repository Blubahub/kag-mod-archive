﻿// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

		{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
	}
	{	
		ShopItem@ s = addShopItem(this, "Superkeg", "$superkeg$", "superkeg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
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