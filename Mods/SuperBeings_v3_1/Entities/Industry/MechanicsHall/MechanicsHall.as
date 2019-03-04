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
	this.set_Vec2f("shop menu size", Vec2f(2, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	AddIconToken("$bombershopicon$", "BomberIcon.png", Vec2f(32, 32), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Hot Air Balloon", "$bombershopicon$", "bomber", "$bombershopicon$\n\n\n" + "Perfect for floating through the skies.", false, true);
		s.crate_icon = 3;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Mounted Bow", "$mounted_bow$", "mounted_bow", "$mounted_bow$\n\n\n" + "Perfect for shooting through enemy's hearts..", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.getTeamNum() == caller.getTeamNum()){
		if(caller.getConfig() == this.get_string("required class"))
		{
			this.set_Vec2f("shop offset", Vec2f_zero);
		}
		else
		{
			this.set_Vec2f("shop offset", Vec2f(6, 0));
		}
		this.set_bool("shop available", this.isOverlapping(caller));
	} else {
		this.set_bool("shop available", false);
	}
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