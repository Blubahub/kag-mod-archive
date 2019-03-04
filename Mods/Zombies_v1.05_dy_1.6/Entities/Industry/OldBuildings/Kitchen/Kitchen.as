﻿// Kitchen

#include "ProductionCommon.as";
#include "Requirements.as"
#include "MakeFood.as"
#include "WARCosts.as";

void onInit( CBlob@ this )
{
	this.set_string("produce sound", "Cooked.ogg");

	//amounts for production to assign extra food for
	this.set_u8("amount steak", 3);
	this.set_u8("amount fishy", 3);
	this.set_u8("amount grain", 3);
	//const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "steak", "Uncooked steak", 1 );
		addFoodItem( this, "Steak Chop", 0, "A steak chop with sauce.", 10, 3, @requirements );
	}
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "grain", "Grain", 1 );
		addFoodItem( this, "Bread", 4, "Delicious crunchy whole-wheat bread.", 10, 3, @requirements );
	}
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "fishy", "Uncooked", 1 );
		addFoodItem( this, "Cooked Fish", 1, "A cooked fish on a stick.", 10, 3, @requirements );
	}
	/*
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "grain", "Grain", 1 );
		//AddRequirement( requirements, "blob", "builder", "Builder", 1 );
		addFoodItem( this, "Cake", 5, "A cake made of a builder corpse. Produces 1.", 20, 1, @requirements );
	}
	
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "grain", "Grain", 1 );
		AddRequirement( requirements, "blob", "trader", "   Russian", 1 );
		addFoodItem( this, "Russian Burger", 6, "A hamburger made of a veiny old person.", 30, 1, @requirements );
	}
*/
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getSprite().getConsts().accurateLighting = true;

	this.getCurrentScript().tickFrequency = 87; // opt
}
   
// leave a pile of wood	after death
void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob( "mat_wood", this.getTeamNum(), this.getPosition() );
		if (blob !is null)
		{
			blob.server_SetQuantity( COST_WOOD_KITCHEN/2 );
		}
	}
}

void onTick( CBlob@ this )
{
	/*if (getNet().isServer())
	{
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius(), @blobsInRadius )) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				const string name = b.getName();
				if (name == "grain" ||
					name == "fishy" ||
					name == "steak" )
				{
					this.server_PutInInventory( b );
				}
			}
		}
	}
	*/
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	this.getSprite().PlaySound("/PopIn");

	const string name = blob.getName();
	if (name == "grain") {
		blob.maxQuantity = 3;
		blob.server_SetQuantity(3);
	} else if (name == "fishy") {
		blob.maxQuantity = 3;
		blob.server_SetQuantity(3);
	} else if (name == "steak") {
		blob.maxQuantity = 3;
		blob.server_SetQuantity(3);
	} 
}
