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

	//ICONS
	//AddIconToken("$m1$", "M1.png", Vec2f(16, 8), 0);
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
		ShopItem@ s = addShopItem(this, "M1", "$m1$", "m1", "A Semiautomatic rifle", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		ShopItem@ s = addShopItem(this, "K98", "$k98$", "k98", "Powerful german bolt-action rifle.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 135);
	}
	{
		ShopItem@ s = addShopItem(this, "Tommy Gun", "$tommy$", "tommy", "An automatic sub-machine-gun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 65);
	}
	{
		ShopItem@ s = addShopItem(this, "Trench Gun", "$trenchgun$", "trenchgun", "A pump action shotgun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "PPSH41", "$ppsh41$", "ppsh41", "Russian SMG with high rate of fire.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 95);
	}
	{
		ShopItem@ s = addShopItem(this, "Stg44", "$stg44$", "stg44", "German assault rifle with slow rate of fire and high damage.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 105);
	}
	{
		ShopItem@ s = addShopItem(this, "Mp40", "$mp40$", "mp40", "Versatile german SMG with a medium rate of fire.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
	}
	{
		ShopItem@ s = addShopItem(this, "M3", "$m3$", "m3", "Lower spectrum american SMG with medium specs.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Colt1911", "$colt1911$", "colt1911", "An M1911.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Luger", "$luger$", "luger", "German semi automatic pistol.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Enfield No 2", "$enfieldno2$", "enfieldno2", "Extremely powerful british revolver. 2.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Bulldog Revolver", "$charterarmsbulldog$", "charterarmsbulldog", "Light semi auto revolver.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Panzerschreck", "$panzerschreck$", "panzerschreck", "Rocket Launcher shooting HE rounds.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
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