// Scripts by Diprog, sprite by AsuMagic. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.

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
		ShopItem@ s = addShopItem( this, "Bison", "$Bison$", "bison", "It will crash your teammates and enemies.", false, true );
		s.crate_icon = 21;
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
		AddRequirement( s.requirements, "blob", "food", "McDonald's burgers", 4 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Shark", "$Shark$", "shark", "Let it eat your enemies.", false, true );
		s.crate_icon = 22;
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bunny", "$bunny$", "bunny", "Buy this cute bunny.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 5 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Chicken", "$chicken$", "chicken", "Buy and fly.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Egg", "$egg$", "egg", "Buy and grow it.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 5 );
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
