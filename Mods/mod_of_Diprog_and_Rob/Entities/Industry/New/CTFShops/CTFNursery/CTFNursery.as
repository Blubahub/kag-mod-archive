// Nursery

#include "ProductionCommon.as";
#include "Requirements.as";
#include "MakeSeed.as";
#include "WARCosts.as";
#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	
	this.getSprite().SetAnimation("nurserybuilding");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken( "$bushesnursery$", "CTFNursery.png", Vec2f(40,24), 0 );
	AddIconToken( "$treesnursery$", "CTFNursery.png", Vec2f(40,24), 1 );
	AddIconToken( "$grainnursery$", "CTFNursery.png", Vec2f(40,24), 2 );
		
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2,3));	
	this.set_string("shop description", "Build");
	this.set_u8("shop icon", 12);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Bushes Nursery", "$bushesnursery$", "bushesnursery", "", false);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Trees Nursery", "$treesnursery$", "treesnursery", "", false);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Grain Nursery", "$grainnursery$", "grainnursery", "", false);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/Construct.ogg" );
		
		bool isServer = (getNet().isServer());
			
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		
		{
			if(name == "bushesnursery")
			{
				this.set_string("produce sound", "/PopIn");
				{
					addSeedItem( this, "bush", "Bush seed", 8, 6 );
				}
				
				{
					addSeedItem( this, "flowers", "Flowers seed", 8, 6 );
				}
				
				{
					addSeedItem( this, "chaparral", "Flowers seed", 8, 6 );
				}
				
				this.getSprite().SetAnimation("bushesnursery");
				
			}
			if(name == "treesnursery")
			{
				this.set_string("produce sound", "/PopIn");
				{
					addSeedItem( this, "tree_pine", "Pine tree seed", 8, 6 );
				}
				
				{
					addSeedItem( this, "tree_bushy", "Oak tree seed", 8, 6 );
				}
				
				this.getSprite().SetAnimation("treesnursery");
				
			}
			if(name == "grainnursery")
			{
				this.set_string("produce sound", "/PopIn");
				{
					addSeedItem( this, "grain_plant", "Grain plant seed", 8, 6 );
				}
				
				this.getSprite().SetAnimation("grainnursery");
				
			}
			
			this.Tag("inventory access");
			this.set_string("autograb blob", "seed");
			this.inventoryButtonPos = Vec2f(0.0f, -6.0f);
			this.set_Vec2f("shop offset", Vec2f(0,10000));
		}
	}
}

