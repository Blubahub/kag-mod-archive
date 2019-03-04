// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_bomb = 20;
const s32 cost_waterbomb = 30;
const s32 cost_keg = 120;
const s32 cost_mine = 80;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(7, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	{
		ShopItem@ s = addShopItem( this, "Bomb", "$bomb$", "mat_bombs", descriptions[1], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_bomb );
	}
	{
		ShopItem@ s = addShopItem( this, "Water Bomb", "$waterbomb$", "mat_waterbombs", descriptions[52], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_waterbomb );
	}
	{
		ShopItem@ s = addShopItem( this, "Satchel", "$SatchelIcon$", "satchel", "it will burn structures and enemies", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{
		ShopItem@ s = addShopItem( this, "Mine", "$mine$", "mine", descriptions[20], false );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_mine );
	}
	{
		ShopItem@ s = addShopItem( this, "Keg", "$keg$", "keg", descriptions[4], false );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_keg );
	}
	{
		ShopItem@ s = addShopItem( this, "Mini Keg", "$MiniKegIcon$", "mini_keg", "Mini Keg", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Sticky Bomb", "$StickyBombIcon$", "mat_stickybombs", "", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 40 );
	}
	this.set_string("required class", "knight");
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
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
}
