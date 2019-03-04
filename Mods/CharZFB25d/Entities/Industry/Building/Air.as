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
	this.set_Vec2f("shop menu size", Vec2f(2,5));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	 
	AddIconToken( "$gliderfactory$", "GliderIcon.png", Vec2f(32,16), 0 );
    AddIconToken( "$bomberfactory$", "BomberIcon.png", Vec2f(32,16), 0 );
	AddIconToken( "$bomberfactory2$", "BomberIcon.png", Vec2f(32,16), 0 );
	AddIconToken( "$missileshipfactory$", "FighterIcon.png", Vec2f(32,16), 0 );
	AddIconToken( "$mballoonfactory$", "BalloonIcon.png", Vec2f(32,16), 0 );
	//AddIconToken( "$building$", "building.png", Vec2f(32,16), 0 );
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Glider", "$gliderfactory$", "gliderfactory", "Fighter used to fight off bombers" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 );
		AddRequirement( s.requirements, "no more", "gliderfactory", "Glider factory", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bomber  Factory", "$bomberfactory2$", "bomberfactory2", "Bomber specified in dropping siege bombs." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 125 );
		AddRequirement( s.requirements, "no more", "bomberfactory2", "Bomber factory", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Missile Ship Factory", "$missileshipfactory$", "missileshipfactory", "Missile ship both good at assaulting buildings and ships." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 );
	//	AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 250 );
		AddRequirement( s.requirements, "no more", "missileshipfactory", "Missile Ship factory", 6 );
	}
	{
		ShopItem@ s = addShopItem( this, "Private Balloon", "$mballoonfactory$", "mballoonfactory", "Manufactures three small balloons at a time. Only one seat and one attachable gun slot." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 );
		AddRequirement( s.requirements, "no more", "mballoonfactory", "Private Balloon factory", 6 );

	}
	
	{
		ShopItem@ s = addShopItem( this, "Back", "$building$", "military", "Go Back" );
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
