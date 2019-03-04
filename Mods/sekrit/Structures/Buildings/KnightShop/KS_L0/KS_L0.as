// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	onInit(this.getSprite());

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	AddIconToken("$rock$", "rock.png", Vec2f(8, 8), 0);
	this.set_string("required class", "knight0");

	{
		ShopItem@ s = addShopItem(this, "A rock", "$rock$", "rock", "Throw premium rocks", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}	
}


void onInit(CSprite@ this)
{
	CSpriteLayer@ graveType;
	print("Hello");
	//this.SetTexture("");
	if(XORRandom(2) == 1)	
		@graveType = this.addSpriteLayer("shopSprite","KS_L00.png",40,20);
	else
	{
		this.getBlob().set_TileType("background tile", CMap::tile_wood_back);
		@graveType = this.addSpriteLayer("shopSprite","KS_L01.png",40,20);	
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