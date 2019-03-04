// Vehicle Workshop

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 300;
const s32 cost_ballista = 500;
const s32 cost_ballista_ammo = 30;
const s32 cost_airship = 1000;
const s32 cost_bomber = 500;
const s32 cost_mounted_bow = 100;
const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken( "$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32,8), 1 );
	
	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8,3));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	bool extra_siege_vehicles = getRules().get_bool("extra_siege_vehicles");
	{
		ShopItem@ s = addShopItem( this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true );
		s.crate_icon = 4;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_catapult );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200);
	}
	{
		ShopItem@ s = addShopItem( this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_ballista );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500);
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
		ShopItem@ s = addShopItem( this, "Mounted Bow", "$mounted_bow$", "mounted_bow", "$mounted_bow$\n\n\n" + "A mounted bow with a higher rate of fire", false, true );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_mounted_bow );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 30);
	}
	{
		ShopItem@ s = addShopItem( this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_ballista_ammo );
	}
	if (extra_siege_vehicles)
	{
		{
			ShopItem@ s = addShopItem( this, "Air Ship", "$airship$", "airship", "$airship$\n\n\n" + "A multi-passenger ship that flies with a small storage space", false, true );
			s.crate_icon = 5;
			AddRequirement( s.requirements, "coin", "", "Coins", cost_airship );
			AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 400);
		}
		{
			ShopItem@ s = addShopItem( this, "Bomber Balloon", "$bomber$", "bomber", "$bomber$\n\n\n" + "A one seated balloon ship that flies, useful for dropping bombs", false, true );
			s.crate_icon = 5;
			AddRequirement( s.requirements, "coin", "", "Coins", cost_bomber );
			AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200);
		}



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
