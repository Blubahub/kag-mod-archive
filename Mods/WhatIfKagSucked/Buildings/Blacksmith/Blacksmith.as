// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Smith");
	this.set_u8("shop icon", 15);
	
	AddIconToken("$sword_icon$", "Sword.png", Vec2f(16, 16), 0);
	AddIconToken("$sawblade_icon$", "SawBlade.png", Vec2f(16, 16), 0);
	AddIconToken("$grapple_icon$", "Grapple.png", Vec2f(16, 16), 0);
	AddIconToken("$shield_icon$", "Shield.png", Vec2f(16, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Sword", "$sword_icon$", "sword", "A sword for knights.", false);
		AddRequirement(s.requirements, "blob", "mat_metalbars", "Metal Bar", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Shield", "$shield_icon$", "shield", "A shield for knights.", false);
		AddRequirement(s.requirements, "blob", "mat_metalbars", "Metal Bar", 2);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Grapple", "$grapple_icon$", "grapple", "A grappling hook for archers.", false);
		AddRequirement(s.requirements, "blob", "mat_metalbars", "Metal Bar", 1);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw Blade", "$sawblade_icon$", "sawblade", "A saw blade... for saws.", false);
		AddRequirement(s.requirements, "blob", "mat_metalbars", "Metal Bars", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", descriptions[43], false);
		AddRequirement(s.requirements, "blob", "mat_metalbars", "Metal Bar", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 10);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
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