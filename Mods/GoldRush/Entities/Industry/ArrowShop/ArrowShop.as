// Archer Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_arrows = 15;
const s32 cost_bombarrows = 50;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	{
		ShopItem@ s = addShopItem( this, "Water Arrows Shop", "$WaterArrowShop$", "waterarrowshop", "Upgrade into the Water Arrows shop.", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Arrows", "$mat_arrows$", "mat_arrows", descriptions[2], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_arrows );
	}
	{
		ShopItem@ s = addShopItem( this, "Bomb Arrows Shop", "$BombArrowShop$", "bombarrowshop", "Upgrade into the Bomb Arrows shop.", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 20 );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller)/* && caller.getName() == "archer"*/ );
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
			if(name == "bombarrowshop" || name == "waterarrowshop")
			{
				this.server_Die();
			}
		}
	}
}

