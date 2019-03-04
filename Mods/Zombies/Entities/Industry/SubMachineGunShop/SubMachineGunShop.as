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

	//Shop pricing
	//Odds and ends
	s32 cost_lantern = 0;
	s32 cost_mp5 = 70;
	s32 cost_uzi = 65;
	s32 cost_chicom = 80;
	// Needs tweaking
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
		AddRequirement(s.requirements, "coin", "", "Coins", 0);
	}
// pistols
	{
		ShopItem@ s = addShopItem(this, "Mp5", "$mp5$", "mp5", "Rapid firing sub machine gun", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
	}
	{
		ShopItem@ s = addShopItem(this, "Chicom", "$chicom$", "chicom", "A call of duty favorite", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
	}
	{
		ShopItem@ s = addShopItem(this, "Uzi", "$uzi$", "uzi", "An Uzi 9mm...", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 65);
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