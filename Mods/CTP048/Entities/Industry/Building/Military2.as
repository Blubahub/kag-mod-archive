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
AddIconToken( "$apartment$", "apartment.png", Vec2f(32,16), 0 );
AddIconToken( "$siren$", "siren.png", Vec2f(32,16), 0 );
AddIconToken( "$hall$", "hall.png", Vec2f(32,32), 0 );
AddIconToken( "$war_base$", "war_base.png", Vec2f(32,32), 0 );
AddIconToken( "$boulderfactory$", "boulderfactory.png", Vec2f(32,16), 0 );
AddIconToken( "$lanternfactory$", "lanternfactory.png", Vec2f(32,16), 0 );
AddIconToken( "$sawfactory$", "sawfactory.png", Vec2f(32,16), 0 );
AddIconToken( "$logfactory$", "logfactory.png", Vec2f(32,16), 0 );
AddIconToken( "$pa$", "PA.png", Vec2f(32,16), 0 );
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4,4));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	this.Tag(SHOP_AUTOCLOSE);
	
	
	{
		ShopItem@ s = addShopItem( this, "Builder Shop", "$buildershop$", "buildershop", descriptions[54] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	}
	{
		ShopItem@ s = addShopItem( this, "Quarters", "$quarters$", "quarters", descriptions[59] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FACTORY );
	}
	{
		ShopItem@ s = addShopItem( this, "Transport Tunnel", "$tunnel$", "tunnel", descriptions[34] );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_TUNNEL );
	}
	{
		ShopItem@ s = addShopItem( this, "Boulder Factory", "$boulderfactory$", "boulderfactory", "Have you always wanted your own boulder?" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 );
	}
	{
		ShopItem@ s = addShopItem( this, "Saw Factory", "$sawfactory$", "sawfactory", "Now we know how to produce saw in a factory!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 );
	}
	{
		ShopItem@ s = addShopItem( this, "Lantern Factory", "$lanternfactory$", "lanternfactory", "Factory for gas lanterns, best quality!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 300 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Wood Refinery", "$logfactory$", "logfactory", "Factory that recycles old logs" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1500 );
        AddRequirement( s.requirements, "no more", "logfactory", "Wood Refinement Factory", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Runes Trader", "$pa$", "pa", "A trader selling runes at his shop" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 600 );

	}
	
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", !builder_only || caller.getName() == "builder" );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();	
	//if (cmd == this.getCommandID("shop buy"))
	//{
	//	u16 callerID;
	//	if (!params.saferead_u16(callerID))
	//		return;
	//	bool spawnToInventory = params.read_bool();
	//	bool spawnInCrate = params.read_bool();
	//	bool producing = params.read_bool();
	//	string blobName = params.read_string();		
	//	u8 s_index = params.read_u8();

	//	CBlob@ caller = getBlobByNetworkID( callerID );
	//	if (caller !is null)
	//	{				
	//		this.getSprite().PlaySound("/Construct.ogg" ); 
	//		this.getSprite().getVars().gibbed = true;
	//		this.server_Die();

	//		// open factory upgrade menu immediately
	//		if (blobName = "factory")
	//		{
	//			if (cmd == this.getCommandID("upgrade factory menu"))
	//			{
	//				CBlob@ caller = getBlobByNetworkID( params.read_u16() );
	//		}
	//	}
	//} 
	//else 
	if (cmd == this.getCommandID("shop made item"))
	{
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
