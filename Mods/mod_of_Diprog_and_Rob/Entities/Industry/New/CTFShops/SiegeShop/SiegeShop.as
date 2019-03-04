// Vehicle Workshop

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_longboat = 75;
const s32 cost_warboat = 130;

const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6,10));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	
	{
		ShopItem@ s = addShopItem( this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true );
		s.crate_icon = 4;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_catapult );
	}
	{
		ShopItem@ s = addShopItem( this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_ballista );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Mounted Bow", "$MountedBow$", "mounted_bow", "A stationary arrow-firing death machine.", false, true );
		s.crate_icon = 6;
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}

	{	 
		ShopItem@ s = addShopItem( this, "Machine Bow", "$MountedBow$", "machine_bow", "Upgraded stationary arrow-firing death machine. Very fast speed.", false, true );
		s.crate_icon = 6;
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Shotgun Bow", "$ShotgunBow$", "shotgun_bow", "Upgraded stationary arrow-firing death machine. Can fire 7 arrows.", false, true );
		s.crate_icon = 11;
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_ballista_ammo );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomber", "$Bomber$", "bomber", "Crush your enemies and their bases with bomber!", false, true );
		s.crate_icon = 3;
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 );
	}
	{
		ShopItem@ s = addShopItem( this, "Submarine", "$Submarine$", "submarine", "Use it to swim under water.", false, true );
		s.crate_icon = 7;
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 750 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 150 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", "For Ballista\nTurns its piercing bolts into a shaped explosive charge.", false );
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", cost_ballista_ammo_upgrade_gold );
		AddRequirement( s.requirements, "not tech", "bomb ammo", "Bomb Bolt", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Sit raft", "$Raft$", "raft", "$Raft$\n\n\n\n\n" + "Make sit raft to sit on it!", false, true );
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150 );
		s.crate_icon = 2;
	}
	{
		ShopItem@ s = addShopItem( this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + descriptions[33], false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_longboat );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
		s.crate_icon = 1;
	}
	{
		ShopItem@ s = addShopItem( this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + descriptions[37], false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_warboat );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 250 );
		s.crate_icon = 2;
	}	
	{
		ShopItem@ s = addShopItem( this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + descriptions[10] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Outpost", "$Outpost$", "packed_outpost", "Use it to spawn at it.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 120 );
	}
	{
		ShopItem@ s = addShopItem( this, "cannon", "$Cannon$", "cannon", "Powerful cannon with exploding bullets.", false, true );
		s.crate_icon = 19;
		AddRequirement( s.requirements, "coin", "", "Coins", 140 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Diving Helmet", "$divinghelmet$", "divinghelmet", "Breath under water. Can be put to inventory.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Cannon Balls", "$Mat_cannon_balls$", "mat_cannon_balls", "Ammo for cannons.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Arrow Dinghy", "$ArrowDinghy$", "arrow_dinghy", "$ArrowDinghy$\n\n\n\n\nDinghy with mounted bow!");
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 300 );
	}

	
	


	
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
		
		bool isServer = (getNet().isServer());
			
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		
		{
			if(name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
			
		}
	}
}
