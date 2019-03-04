// Genreic building

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
	this.set_Vec2f("shop menu size", Vec2f(3,3));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem( this, "Bomb Shop", "$BombShop$", "bombshop", "Buy some bombs" );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Arrow Shop", "$ArrowShop$", "arrowshop", "Buy some arrows" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Builder Shop", "$BuilderShop$", "buildershop", descriptions[54] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Well", "$Well$", "well", "Used to heal you and to fill buckets" );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 75 );
	}
	{
		ShopItem@ s = addShopItem( this, "Transport Tunnel", "$Tunnel$", "tunnel", descriptions[34] );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Storage Cache", "$Storage$", "storage", descriptions[60] );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem( this, "Siege Shop", "$SiegeShop$", "siegeshop", "Used to buy catapult and outpost." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50);
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
