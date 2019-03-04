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
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LANTERN);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", descriptions[36], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BUCKET);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", descriptions[53], false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", descriptions[17], false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_TRAMPOLINE);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", descriptions[43], false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", COST_STONE_DRILL);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	
	AddIconToken("$ultradrill_icon$", "UltraDrill.png",Vec2f(32, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "UltraDrill", "$ultradrill_icon$", "ultradrill", "An improved drill.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
	}
	
	AddIconToken("$handlauncher_icon$", "HandLauncher.png",Vec2f(32, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Handlauncher", "$handlauncher_icon$", "handlauncher", "A Hand-Held Catapult.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	
	AddIconToken("$ultratramp_icon$", "UltraTrampoline.png",Vec2f(64, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "UltraTrampoline", "$ultratramp_icon$", "ultratrampoline", "An improved trampoline.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	
	AddIconToken("$ultralantern_icon$", "UltraLantern.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Ultra-Lantern", "$ultralantern_icon$", "ultralantern", "Produces a significant amount of light.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	
	AddIconToken("$chainsaw_icon$", "Chainsaw.png",Vec2f(32, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Chainsaw", "$chainsaw_icon$", "chainsaw", "A device for rapidly chopping down trees and brain-eaters.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	
	AddIconToken("$parachute_icon$", "ParachuteIcon.png",Vec2f(32, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Parachute", "$parachute_icon$", "parachute", "Slows your fall.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
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
