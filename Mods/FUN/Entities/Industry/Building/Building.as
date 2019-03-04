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
	this.set_Vec2f("shop menu size", Vec2f(8,5));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Builder Shop", "$buildershop$", "buildershop", descriptions[54] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	}
	{
		ShopItem@ s = addShopItem( this, "Magic Shop", "$MagicShop$", "magicshop", "Craft magic items!" );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Quarters", "$quarters$", "quarters", descriptions[59] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
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
		ShopItem@ s = addShopItem( this, "Siege Shop", "$SiegeShop$", "siegeshop", "Buy vehicles, craft boats" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Portal", "$Portal$", "portal", "Fast traveling building" );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Barracks", "$Barracks$", "barracks", descriptions[41] );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Kitchen", "$Kitchen$", "ctfkitchen", "Buy some food to use it in battle" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Storage Cache", "$storage$", "storage", descriptions[60] );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem( this, "Wizard Altar", "$WizardAltar$", "wizardaltar", "Transform into a Wizard!"		);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 200 );
	}
	{
	    ShopItem@ s = addShopItem( this, "Trader Shop", "$TraderShop$", "tradershop", "Buy materials!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 20 );
		AddRequirement( s.requirements, "no more", "tradershop", "Trader Shop", 1 );
	}
	{
	    ShopItem@ s = addShopItem( this, "Personal Storage", "$personal_storage$", "personal_storage", "Your own storage, don't forget to hold E and set it as yours!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 300 );
	}
	{
	    ShopItem@ s = addShopItem( this, "Nursery", "$CTFnursery$", "ctfnursery", "Used to plant seeds" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
	}
	{
	    ShopItem@ s = addShopItem( this, "Windmill", "$Mill$", "mill", "Produces flour" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
		AddRequirement( s.requirements, "no more", "mill", "Mills", 8 );
	}
	{
	    ShopItem@ s = addShopItem( this, "Forge", "$Forge$", "forge", "Produces coal" );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 200 );
	}
	{
	    ShopItem@ s = addShopItem( this, "Well", "$Well$", "well", "Fills buckets" );
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
