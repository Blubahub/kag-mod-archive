// Builder Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(9,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	bool npc_guards_enabled = getRules().get_bool("npc_guards_enabled");

	{	 
		ShopItem@ s = addShopItem( this, "Wood", "$mat_wood$", "mat_wood", "Exchange 50 Gold for 250 Wood", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}

	{
		ShopItem@ s = addShopItem( this, "Stone", "$mat_stone$", "mat_stone", "Exchange 125 Gold for 250 Stone", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 125 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for wood", "$mat_gold$", "mat_gold", "Exchange 1500 Wood for 250 Gold", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1500 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for stone", "$mat_gold$", "mat_gold", "Exchange 500 Stone for 250 Gold", true );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for coins", "$mat_gold$", "mat_gold", "Buy 250 gold for 125 coins.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 125 );
	}
	{
		ShopItem@ s = addShopItem( this, "Coins for gold", "$coin_trade$", "coin_trade", "Buy 125 coins for 250 gold.", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 250 );
	}
	if (npc_guards_enabled)
	{
		{
			ShopItem@ s = addShopItem( this, "Hire Knight Guard", "$knight_bot$", "knight_bot", "An NPC knight that will fight for you. You can take care of knight guards by dropping them food when needed or taking them to a dorm with a migrant", true );
			AddRequirement( s.requirements, "coin", "", "Coins", 200 );
		}
		{
			ShopItem@ s = addShopItem( this, "Hire Archer Guard", "$archer_bot$", "archer_bot", "An NPC archer that will fight for you. You can take care of archer guards by dropping them food and ammo when needed or taking them to a dorm with a migrant", true );
			AddRequirement( s.requirements, "coin", "", "Coins", 150 );
		}
	}
	{
			ShopItem@ s = addShopItem( this, "Hire Migrant", "$migrant_bot$", "migrant_bot", "Migrants normally can be rescued or purchased here. Place near dorm to allow for healing and a one-time respawn point", true );
			AddRequirement( s.requirements, "coin", "", "Coins", 250 );
	}
/*

	{
		ShopItem@ s = addShopItem( this, "Mega Saw", "$megasaw$", "megasaw", "Buy Mega Saw for 500 coins.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
	}
*/
	//this.set_string("required class", "builder");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
}
