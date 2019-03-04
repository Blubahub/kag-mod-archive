﻿// Genreic building

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8,5));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	bool cook_food_only = getRules().get_bool("cook_food_only");
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Builder Shop", "$buildershop$", "buildershop", descriptions[54] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	}
	if (!cook_food_only)
	{
		{
			ShopItem@ s = addShopItem( this, "Quarters", "$quarters$", "quarters", descriptions[59] );
			AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
		}
	}
	{
		ShopItem@ s = addShopItem( this, "Knight Shop", "$knightshop$", "knightshop", descriptions[55] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	}	
	{
		ShopItem@ s = addShopItem( this, "Archer Shop", "$archershop$", "archershop", descriptions[56] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	}
	{
		ShopItem@ s = addShopItem( this, "Boat Shop", "$boatshop$", "boatshop", descriptions[58] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Vehicle Shop", "$vehicleshop$", "vehicleshop", descriptions[57] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Transport Tunnel", "$tunnel$", "tunnel", descriptions[34] );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 400 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 400 );
	}
	{
		ShopItem@ s = addShopItem( this, "Storage", "$storage$", "storage", descriptions[42] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Nursery", "$nursery$", "nursery", descriptions[40]+"  Grain can be grown and used in kitchen to make bread." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Trader Shop", "$trader2$", "trader2", "Build a trader shop" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 300 );
	}
	{
		ShopItem@ s = addShopItem( this, "Dorm", "$dorm$", "dorm", descriptions[48] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}
	/*
	{
		ShopItem@ s = addShopItem( this, "Hall", "$hall$", "hall", descriptions[3] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 5 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 5 );
	}
	*/
	{
		ShopItem@ s = addShopItem( this, "Kitchen", "$kitchen$", "kitchen", descriptions[39]+" Kitchens produce more food then fireplaces. Food can be carried and used when needed." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 25 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Barracks", "$barracks$", "barracks", descriptions[41]+" You can also change back to a builder through the barracks." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.isOverlapping(caller))
		this.set_bool("shop available", !builder_only || caller.getName() == "builder" );
	else
		this.set_bool("shop available", false );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds
		
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		CBlob@ item = getBlobByNetworkID( params.read_netid() );
		if (item !is null && caller !is null)
		{
			this.getSprite().PlaySound("/Construct.ogg" ); 
			this.getSprite().getVars().gibbed = true;
			this.server_Die();

			// open factory upgrade menu immediately
			if (item.getName() == "factory")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("upgrade factory menu"), factoryParams );
			}
		}
	}
}
