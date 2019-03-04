// Scripts by Diprog, sprite by Diprog. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5,1));
	this.set_string("shop description", "Buy");

	{	 
		ShopItem@ s = addShopItem( this, "McDonald's Burger", "$food$", "food", "Buy it and throw in teammates.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Cake", "$cake$", "cake", "CAAAKE!", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Cooked Meat", "$cookedmeat$", "cookedmeat", "Just buy and eat!", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Cooked Fish", "$cookedfish$", "cookedfish", "Just buy and eat!", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bread", "$bread$", "bread", "Buy and eat.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	
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
