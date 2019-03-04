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
	this.set_Vec2f("shop menu size", Vec2f(2,8));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	AddIconToken( "$stonefactory$", "ResIconspng.png", Vec2f(32,16), 1 );
	AddIconToken( "$goldfactory$", "ResIconspng.png", Vec2f(32,16), 2 );
	AddIconToken( "$tradingpost$", "tradingpost2.png", Vec2f(32,16), 0 );
	AddIconToken( "$logfactory$", "ResIconspng.png", Vec2f(32,16), 0 );
	AddIconToken( "$nursery$", "ResIconspng.png", Vec2f(32,16), 3 );
	AddIconToken( "$trader2$", "trader2.png", Vec2f(32,16), 0 );
	AddIconToken( "$grainnursery$", "ResIconspng.png", Vec2f(32,16), 4 );
//	AddIconToken( "$building$", "building.png", Vec2f(32,16), 0 );
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Warehouse", "$storage$", "storage", "Item storage" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
	}	
	
	{
		ShopItem@ s = addShopItem( this, "Wood Refinery", "$logfactory$", "logfactory", "Factory that recycles old logs" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
        AddRequirement( s.requirements, "no more", "logfactory", "Wood Refinement Factory", 1 );
	}
	// {
		// ShopItem@ s = addShopItem( this, "Stone Refinement Factory", "$stonefactory$", "stonefactory", "Creates stone" );
		// AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
		// AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 );
		// AddRequirement( s.requirements, "no more", "stonefactory", "Stone Refinement Factory", 6 );

	// }
	// {
		// ShopItem@ s = addShopItem( this, "Gold Refinement Factory", "$goldfactory$", "goldfactory", "Creates gold" );
		// AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
		// AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 500 );
		// AddRequirement( s.requirements, "no more", "goldfactory", "Gold Refinement Factory", 3 );
	// }
	{
		ShopItem@ s = addShopItem( this, "Nursery", "$nursery$", "nursery", "Tree seeds"  );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		AddRequirement( s.requirements, "no more", "nursery", "Nursery", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Grain Nursery", "$grainnursery$", "grainnursery", "Plant grain that will yield coins"  );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		AddRequirement( s.requirements, "no more", "nursery", "Nursery", 6 );
	}
    {
		ShopItem@ s = addShopItem( this, "Trader", "$trader2$", "trader2", "I ran, *cough* came from far away land full with riches! Take a look what I have to offer."  );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
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

