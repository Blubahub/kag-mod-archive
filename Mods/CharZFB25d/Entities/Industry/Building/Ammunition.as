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
	this.set_Vec2f("shop menu size", Vec2f(2,3));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);


	AddIconToken( "$bombfactory$", "bombfactory2.png", Vec2f(32,16), 0 );
	AddIconToken( "$bombsfactory$", "bombsfactory.png", Vec2f(32,16), 0 );
	AddIconToken( "$missilefactory$", "missilefactory.png", Vec2f(32,16), 0 );
	AddIconToken( "$gunfactory$", "gunfactory.png", Vec2f(32,16), 0 );
	AddIconToken( "$mgbulletsfactory$", "mgulletsfactory.png", Vec2f(32,16), 0 );
	AddIconToken( "$bazookafactory$", "bazookafactory.png", Vec2f(32,16), 0 );
	
	this.Tag(SHOP_AUTOCLOSE);
	
	//{
	//	ShopItem@ s = addShopItem( this, "Bomber Bombs Factory", "$bombfactory$", "bombfactory", "Siege bombs made specificaly for the bomber." );
	//	AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1800 );
	//	AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	//	AddRequirement( s.requirements, "no more", "bombfactory", "Bomber Bombs Factory", 6 );
	//}
	//{
	//	ShopItem@ s = addShopItem( this, "Missile Factory", "$missilefactory$", "missilefactory", "Missiles made for the missile ship and the bazooka." );
	//	AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1200 );
	//	AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 );
	//	AddRequirement( s.requirements, "no more", "missilefactory", "Missile Factory", 6 );
	//}

	{
		ShopItem@ s = addShopItem( this, "Bombs Factory", "$bombsfactory$", "bombsfactory", "Normal Bombs for the knight." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 300 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
        AddRequirement( s.requirements, "no more", "bombsfactory", "Bombs Factory", 6 );
	}
	//{
	//	ShopItem@ s = addShopItem( this, "Machine Gun Bullets Factory", "$mgbulletsfactory$", "mgbulletsfactory", "Produces a bag of bullets for the machine gun." );
	//	AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 600 );
	//	AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 150 );
	//	AddRequirement( s.requirements, "no more", "mgbulletsfactory", "Machine Gun Bullets factory", 6 );

	//}
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
