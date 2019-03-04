// Quarters.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

s32 cost_beer = 5;
s32 cost_meal = 10;
s32 cost_egg = 30;
s32 cost_burger = 20;

const f32 beer_ammount = 1.0f;
const f32 heal_ammount = 0.25f;
const u8 heal_rate = 30;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$cookedsteak$", "CookedSteak.png", Vec2f(16, 8), 0);
	AddIconToken("$bread$", "Bread.png", Vec2f(16, 16), 1);
	AddIconToken("$burger$", "Food.png", Vec2f(16, 16), 6);
	AddIconToken("$fishstick$", "Food.png", Vec2f(16, 16), 1);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Cook");
	this.set_u8("shop icon", 22);

	{
		ShopItem@ s = addShopItem(this, "Bread", "$bread$", "bread", "Plain ol' bread.", true);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Burger", "$burger$", "burger", "The backbone of a good restuarant.", true);
		AddRequirement(s.requirements, "blob", "bread", "Bread", 1);
		AddRequirement(s.requirements, "blob", "cooked_steak", "Steak", 1);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop buy"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		bool spawnToInventory = params.read_bool();
		bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
		string blobName = params.read_string();
		u8 s_index = params.read_u8();
		{
			this.getSprite().PlaySound("/sand_fall.ogg");
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(2);
		planks.SetOffset(Vec2f(12.0f, 0.0f));
		planks.SetRelativeZ(-100);
	}
}