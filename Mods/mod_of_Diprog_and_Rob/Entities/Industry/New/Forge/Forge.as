#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "ProductionCommon.as";


int producingTime = 65;
int time = producingTime * 30;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;
	this.set_u32("producing_time", time);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(1,1));
	this.set_string("shop description", "Produce");
	this.set_u8("shop icon", 12);

	{	 
		ShopItem@ s = addShopItem( this, "Coal", "$Mat_coal$", "mat_coal", "Use it as fuel for bomber or as material for blocks.", false);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 4000 );
	}
	
}
void onTick(CBlob@ this)
{
	if (!isProducing(this))
	{
		this.getSprite().SetAnimation("default");
	}
	else
		this.getSprite().SetAnimation("producing");
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) && !isProducing(this) /*&& caller.getName() == "builder"*/ );
	if (isProducing(this))
	{
		CButton@ button = caller.CreateGenericButton( 12, Vec2f(0,8), this, 0, "Forge is producing" );
		if (button !is null) 
			button.SetEnabled( false );
	}
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		
		{
			/*if(name == "make_coal")
				addProductionItem( this, "Coal", "$mat_coal$", "mat_coal", "Coal for bomber", producingTime, false, 1 );*/
		}
	}
}
