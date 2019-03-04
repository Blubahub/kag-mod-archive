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

	//Shop pricing
	//Odds and ends
	s32 cost_lantern = 0;
	//Pistols
	s32 cost_colt1911 = 0;
	s32 cost_fiveseven = 20;
	//Sub Machine Guns
	s32 cost_chicom = 80;
	s32 cost_mp5 = 80;
	s32 cost_uzi = 80;
	//Rifle
	s32 cost_m1grand = 120;
	s32 cost_sniper = 500;
	//Automatic Rifle
	s32 cost_m16 = 150;
	s32 cost_ak47 = 180;
	//Shotguns
	s32 cost_remington870 = 200;
	//Spechul
	s32 cost_raygun = 700;

	//End of shop pricing

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
		AddRequirement(s.requirements, "coin", "", "Coins", cost_lantern);
	}
// pistols
	{
		ShopItem@ s = addShopItem(this, "colt1911", "$colt1911$", "colt1911", "The starter weapon, cheap and ineffective.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_colt1911);
	}

	{
		ShopItem@ s = addShopItem(this, "fiveseven", "$fiveseven$", "fiveseven", "20 rounds, superiour aiming, semi-auto... couldn't ask for a better pistol.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_fiveseven);
	}
// Rifles
	{
		ShopItem@ s = addShopItem(this, "m1", "$m1$", "m1", "A faithful rifle, that stands the test of time?", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_m1grand);
	}
	
	{
		ShopItem@ s = addShopItem(this, "sniper", "$sniper$", "sniper", "Long distance and headshots your thing??", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_sniper);
	}
	
// Sub Machine Guns
	{
		ShopItem@ s = addShopItem(this, "chicom", "$chicom$", "chicom", "A rapid firing sub machine gun!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_chicom);
	}
	{
		ShopItem@ s = addShopItem(this, "mp5", "$mp5$", "mp5", "A rapid firing sub machine gun!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_mp5);
	}
	{
		ShopItem@ s = addShopItem(this, "uzi", "$uzi$", "uzi", "A rapid firing sub machine gun!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_uzi);
	}


// Automatic Rifles
	{
		ShopItem@ s = addShopItem(this, "m16", "$m16$", "m16", "A fully automatic rifle? Fuck yeah!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_m16);
	}

	{
		ShopItem@ s = addShopItem(this, "ak47", "$ak47$", "ak47", "Trusty Russian fully automatic rifle! Kills stuff!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ak47);
	}
// Shotguns

	{
		ShopItem@ s = addShopItem(this, "remington870", "$remington870$", "remington870", "Boom.. Chk Chk.. BOOM.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_remington870);
	}
	
//Spechul guns

	{
		ShopItem@ s = addShopItem(this, "raygun", "$raygun$", "raygun", "A mysterious alien artifact.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_raygun);
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