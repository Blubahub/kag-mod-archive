// Vehicle Workshop

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken( "$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32,8), 1 );
	
	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4,2));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	{
		ShopItem@ s = addShopItem( this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true );
		s.crate_icon = 4;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_catapult );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Outpost", "$Outpost$", "packed_outpost", "Use it to spawn at it.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 120 );
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
	}
}
