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
	this.set_Vec2f("shop menu size", Vec2f(3,1));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem( this, "Civilian", "$building$", "military2", "Civil Buildings" );	
	}
	{
		ShopItem@ s = addShopItem( this, "Military", "$building$", "military", "Military Buildings" );	
	}
	{
		ShopItem@ s = addShopItem( this, "Economic", "$building$", "economy", "Economy Buildings" );	
			//s.customButton = true;
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
			this.getSprite().PlaySound("/select.ogg" ); 
			this.getSprite().getVars().gibbed = true;
			
		
			// open factory upgrade menu immediately
			if (item.getName() == "military2")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("shop menu"), factoryParams );
			}
				if (item.getName() == "military")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("shop menu"), factoryParams );
			}
				if (item.getName() == "economy")
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
