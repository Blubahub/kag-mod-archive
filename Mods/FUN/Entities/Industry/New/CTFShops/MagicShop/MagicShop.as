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
	this.set_Vec2f("shop menu size", Vec2f(4,1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	{	 
		ShopItem@ s = addShopItem( this, "Mega Drill", "$Mega_drill$", "mega_drill", "Use it to kill enemies and destroy their tower", false );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Cristal", "$Cristal$", "cristal", "For building a Wizard Altar.", true );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 1000 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 125 );
	}
	{
		ShopItem@ s = addShopItem( this, "Soul Stone", "$SoulStone$", "soulstone", "For transformation into a Wizard.", true );
		AddRequirement( s.requirements, "blob", "soulstoneshard", "Soul Stone Shard", 2 );
	}
	{
		ShopItem@ s = addShopItem( this, "Blood Jar", "$BloodJar$", "bloodjar", "Used to activate Portal.", true );
		AddRequirement( s.requirements, "blob", "knight", "Dead Knight", 1 );
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
