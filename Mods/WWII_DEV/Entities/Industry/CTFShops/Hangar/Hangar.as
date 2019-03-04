// Knight Workshop

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


	//AddIconToken("$tommy$", "Tommy.png", Vec2f(16, 8), 0);

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(8, 8));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	{
		ShopItem@ s = addShopItem(this, "Heavy Cannon", "$heavycannon$", "ballista", "$ballista$\n\n\n" + "Heavy Cannon for defensive or offensive purposes", false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", 350);
	}
	{
		ShopItem@ s = addShopItem(this, "Machinegun", "$machinegun$", "machinegun", "$machinegun$\n\n\n" + "An mounted machinegun for dealing with enemies. High fire rate, medium damage and range.", false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Heavy Machinegun", "$heavymachinegun$", "heavymachinegun", "$heavymachinegun$\n\n\n" + "Heavy Mounted machinegun. Slow rate of fire but very high damage and ammo capacity. Cant be picked up after placing.", false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 85);
	}
	{
		ShopItem@ s = addShopItem(this, "Flak-30 Anti Air", "$lightaa$", "lightaa", "$lightaa$\n\n\n" + "Light german Anti-Air gun firing 20mm rounds with a capacity of 20 rounds per mag. Cant be picked up after placing.", false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 130);
	}
	{
		ShopItem@ s = addShopItem(this, "MG42 Mounted", "$mg42$", "mg42", "$mg42$\n\n\n" + "Very powerful german machinegun. Cant be picked up after placing.", false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 290);
	}
	{
		ShopItem@ s = addShopItem(this, "Bf109", "$bf109$", "bf109", "$bf109$\n\n\n" + "An agile figher used by the AXIS in WW2. Is able to drop bombs.", false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 190);
	}
	{
		ShopItem@ s = addShopItem(this, "Yak-9T", "$yak9t$", "yak9t", "$yak9t$\n\n\n" + "Slightly slower then the Bf109, the yak9t is mounted with a 50mm cannon which can shred through defenses easily.", false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 270);
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