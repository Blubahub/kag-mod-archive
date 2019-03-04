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
	this.set_bool("has_arrow", false);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	//if(!this.exists("shop available"))
	//this.set_bool("shop available", false);
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2,8));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	//CBlob@ caller = getBlobByNetworkID( params.read_netid() );
	//BuildShopMenu(this, caller, this.get_string("shop description"), Vec2f(0, 0), this.get_Vec2f("shop menu size"));
	AddIconToken( "$bisonnursery$", "bisonnursery.png", Vec2f(32,16), 0 );
//AddIconToken( "$building$", "building.png", Vec2f(32,16), 0 );
	AddIconToken( "$bombsfactory$", "bombsfactory.png", Vec2f(32,16), 0 );
	AddIconToken( "$gunfactory$", "gunfactory.png", Vec2f(32,16), 0 );
	AddIconToken( "$bazookafactory$", "bazookafactory.png", Vec2f(32,16), 0 );
	
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem( this, "Knight Shop", "$knightshop$", "knightshop", descriptions[55] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
		
		
	}	
	{
		ShopItem@ s = addShopItem( this, "Archer Shop", "$archershop$", "archershop", descriptions[56] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	
		
	}
	{
		ShopItem@ s = addShopItem( this, "Vehicle Shop", "$vehicleshop$", "vehicleshop", descriptions[57] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
		
	}
	{
		ShopItem@ s = addShopItem( this, "Bison Nursery", "$bisonnursery$", "bisonnursery", descriptions[03] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 );
        AddRequirement( s.requirements, "no more", "bisonnursery", "Bison Nursery", 3 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bombs Factory", "$bombsfactory$", "bombsfactory", "Normal Bombs for the knight." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 300 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
        AddRequirement( s.requirements, "no more", "bombsfactory", "Bombs Factory", 6 );
	}

	{
		ShopItem@ s = addShopItem( this, "Machine Gun Factory", "$gunfactory$", "gunfactory", "Machine Guns are manufactured here!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1250 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 150 );
        AddRequirement( s.requirements, "no more", "gunfactory", "Gun factory", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bazooka Factory", "$bazookafactory$", "bazookafactory", "Bazooka is manufactured here!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1250 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 150 );
        AddRequirement( s.requirements, "no more", "bazookafactory", "Bazooka factory", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Back", "$building$", "military", "Go Back" );
		//	s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;	
	}
	

	
	
}

	void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", !builder_only || caller.getName() == "builder" );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();	

	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		CBlob@ item = getBlobByNetworkID( params.read_netid() );
		if (item !is null && caller !is null)
		{				
			this.getSprite().PlaySound("/select.ogg" ); 
			this.getSprite().getVars().gibbed = true;
			

			// open factory upgrade menu immediately
			if (item.getName() == "military")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("shop menu"), factoryParams );
			}
		
		}
		this.server_Die();
	}
}
   
// leave a pile of wood	after death
void onDie(CBlob@ this)
{
	/*if (getNet().isServer()) //TODO: Maybe do this if teamkilled.
	{
		CBlob@ blob = server_CreateBlob( "mat_wood", this.getTeamNum(), this.getPosition() );
		if (blob !is null)
		{
			blob.server_SetQuantity( COST_WOOD_BUILDING/2 );
		}
	}*/
}
