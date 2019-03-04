// Boat Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_longboat = 50;
const s32 cost_warboat = 500;
const s32 cost_caravel = 1200;
const s32 cost_uboot = 400;
void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8,4));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem( this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + descriptions[10] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
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
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 );
		s.crate_icon = 2;
	}
	{
		ShopItem@ s = addShopItem( this, "Submarine", "$uboot$", "uboot", "$uboot$\n\n\n" + "Armoured submarine great for long underwater adventures, allows you to breathe forever underwater while attached", false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_uboot );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 300 );
		s.crate_icon = 4;
	}
	{
		ShopItem@ s = addShopItem( this, "Caraval", "$Caravel$", "Caravel", "$Caravel$\n\n\n" + "A massive ship equiped with 3 mounted bows, a slot for catapult/ballista, is a spawn point, and has storage/can change classes.", false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_caravel );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1200 );
		s.crate_icon = 4;
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
