// Genreic building

#include "Requirements.as"
#include "ShopCommon.as";
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
	this.set_Vec2f("shop menu size", Vec2f(4,1));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	 
	
	AddIconToken( "$land$", "building.png", Vec2f(16,16), 0 );
		AddIconToken( "$naval$", "building.png", Vec2f(16,16), 0 );
		AddIconToken( "$air$", "building.png", Vec2f(16,16), 0 );
	AddIconToken( "$ammunition$", "building.png", Vec2f(16,16), 0 );
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Land", "$land$", "land", "Land military buildings" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 0 );
	}	
		{
		ShopItem@ s = addShopItem( this, "Naval", "$naval$", "naval", "Naval military buildings" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 0 );
	}
		{
		ShopItem@ s = addShopItem( this, "Air", "$air$", "air", "Air military buildings" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 0 );
	}
	{
		ShopItem@ s = addShopItem( this, "Back", "$building$", "building", "Go Back" );
		//		s.customButton = true;
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
			if (item.getName() == "land")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("shop menu"), factoryParams );
			}
			if (item.getName() == "air")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("shop menu"), factoryParams );
			}
			if (item.getName() == "naval")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("shop menu"), factoryParams );
			}
			if (item.getName() == "building")
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
