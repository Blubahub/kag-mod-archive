// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//load config
	if (getRules().exists("ctf_costs_config"))
	{
		cost_config_file = getRules().get_string("ctf_costs_config");
	}

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	AddIconToken("$goldheart$", "GoldHeart.png", Vec2f(16, 16), 0);
	AddIconToken("$homestone$", "homestone.png", Vec2f(16, 16), 0);
	AddIconToken("$golem$", "Golem.png", Vec2f(32, 32), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Golden Heart", "$goldheart$", "goldheart", "Overheals 1 heart", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Home Stone", "$homestone$", "homestone", "Let's you teleport home", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 10);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Golem", "$golem$", "golem", "Built for defense and offense", true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
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
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}