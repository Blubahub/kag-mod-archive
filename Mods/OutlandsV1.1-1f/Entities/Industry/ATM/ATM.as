// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
//#include "BuilderHittable.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	//this.Tag("builder always hit");

	{
		ShopItem@ s = addShopItem(this, "Buy stone", "$STONES$", "mat_stone", "Buy 50 stone for 8 coins!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 8);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Wood", "$WOOD$", "mat_wood", "Buy 50 wood for 4 coins!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy gold", "$GOLD$", "mat_gold", "Buy 50 gold for 15 coins!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell stone", "$STONES$", "coins-4", "Sell 50 stone for 4 coins!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell wood", "$WOOD$", "coins-2", "Sell 50 wood for 2 coin!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell gold", "$GOLD$", "coins-10", "Sell 50 gold for 10 coins!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		{
		    if(name.findFirst("coins-") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (isServer && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					   callerPlayer.server_setCoins( callerPlayer.getCoins() + parseInt(name.split("-")[1]) );
				}
			}
			if(name == "mat_wood" || name == "mat_stone" || name == "mat_gold")
			{
				CBlob@ callerBlob = getBlobByNetworkID(caller);
				CInventory@ inv = callerBlob.getInventory();
				CBlob@ mat = server_CreateBlob(name);
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(50);
					if (!callerBlob.server_PutInInventory(mat))
					{
					mat.setPosition(callerBlob.getPosition());
					}
				}
			}
		}
	}
}
