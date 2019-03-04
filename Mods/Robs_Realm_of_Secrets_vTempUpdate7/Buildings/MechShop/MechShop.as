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
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_string("shop description", "Tinker");
	this.set_u8("shop icon", 15);
	
	AddIconToken("$golem_icon$", "GolemNoCore.png", Vec2f(32, 32), 0);
	AddIconToken("$woodengolem_icon$", "WoodenGolemNoCore.png", Vec2f(32, 32), 0);
	AddIconToken("$key_icon$", "Key.png", Vec2f(16, 8), 0);
	AddIconToken("$contrabass_icon$", "Contrabass.png", Vec2f(8, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Golem", "$golem_icon$", "golem", "A defensive mechanical unit.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Wooden Golem", "$woodengolem_icon$", "wooden_golem", "A defensive mechanical unit.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Key", "$key_icon$", "key", "Gives a person access to your doors.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Contrabass", "$contrabass_icon$", "contrabass", "For making music.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
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