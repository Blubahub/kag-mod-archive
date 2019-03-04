// Archer Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_arrows = 15;
const s32 cost_waterarrows = 20;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem( this, "Arrows", "$mat_arrows$", "mat_arrows", descriptions[2], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_arrows );
	}
	{
		ShopItem@ s = addShopItem( this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", descriptions[50], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_waterarrows );
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
	}
}
