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
	this.set_Vec2f("shop menu size", Vec2f(5,6));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{	 
		ShopItem@ s = addShopItem( this, "Lantern", "$lantern$", "lantern", descriptions[9], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LANTERN );
	}
	{
		ShopItem@ s = addShopItem( this, "Bucket", "$bucket$", "bucket", descriptions[36], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BUCKET );
	}
	{
		ShopItem@ s = addShopItem( this, "Sponge", "$sponge$", "sponge", descriptions[53], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SPONGE );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Boulder", "$boulder$", "boulder", descriptions[17], false );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 35 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_TRAMPOLINE );
	}
	
	{	 
		ShopItem@ s = addShopItem( this, "Saw", "$saw$", "saw", descriptions[12], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Drill", "$drill$", "drill", descriptions[43], false );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_DRILL );
	}
	{
		ShopItem@ s = addShopItem( this, "Crate", "$wcc$", "wcc", descriptions[18], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CRATE );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Water Lantern", "$waterlantern$", "waterlantern", "Lantern crafted for underwater exploration.", false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scuba Air Tank", "$airtank$", "airtank", "Air Tank for longer underwater explorations. Buying more than one has no effect", false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CRATE );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 10 );
	}
	/*
	{
		ShopItem@ s = addShopItem( this, "Outpost", "$outpost$", "outpost", "An outpost, used for cheap spawning/storing, can be mobilized", false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
	}
	*/
	{
		ShopItem@ s = addShopItem( this, "Fireplace", "$fireplace$", "fireplace", "A quick/cheap way to cook food, Kitchen produces more, throw meat on fire to cook!", false);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 30);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 10 );
	}
	
	this.set_string("required class", "builder");
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
