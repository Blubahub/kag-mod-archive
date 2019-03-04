// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	bool isOpen = false;

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 12)); // Doubled this Width by Height
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS - Not really needed but keeping for now
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder"); 
// Other
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		AddRequirement(s.requirements, "coin", "", "Coins", 0);
	}
// pistols
	{
		ShopItem@ s = addShopItem(this, "colt1911", "$colt1911$", "colt1911", "The starter weapon, cheap and somewhat effective.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 10); //20
	}
	{
		ShopItem@ s = addShopItem(this, "Magnum", "$magnum$", "magnum", "Good ol fasioned 6 shooter!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30); //20
	}
	/*
	{
		ShopItem@ s = addShopItem(this, "fiveseven", "$fiveseven$", "fiveseven", "20 rounds, superiour aiming, semi-auto... couldn't ask for a better pistol. 0.5 dmg", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 35); //40 or 50
	}
	{
		ShopItem@ s = addShopItem(this, "Desert Eagle", "$deagle$", "deagle", "One deage! ;)", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 250); //???
	}
	{
		ShopItem@ s = addShopItem(this, "Glock 18", "$glock18$", "glock18", "Bang.. bang, bang, bang, bang bang.... bang.. bang, bang...", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 45); //???
	}
	{
		ShopItem@ s = addShopItem(this, "USP - Silenced", "$uspsilenced$", "uspsilenced", "psst, psst, psst....", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50); //???
	}
	*/

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