// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

const string[] resources = 
{
	"mat_coal",
	"mat_steel",
	"mat_copper",
	"mat_mithril",
	"mat_goldingot",
	"mat_mithrilenriched",
	"mat_plasteel"
};

const u8[] resourceYields = 
{
	50,
	50,
	50,
	50,
	50,
	50,
	50
};

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("teamlocked tunnel");
	this.Tag("change team on fort capture");
	
	//this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	this.set_Vec2f("travel button pos", Vec2f(3.5f, 4));
	this.inventoryButtonPos = Vec2f(-16, 8);
	this.getCurrentScript().tickFrequency = 30*5; //7.5 coal per minute, mind that teams sometimes have like 10 coal mines
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Coalville Mining Company");
	this.set_u8("shop icon", 25);
		
	{
		ShopItem@ s = addShopItem(this, "Buy Iron Ingot (100)", "$mat_ironingot$", "mat_ironingot-100", "Buy 100 Iron Ingot for 10 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Mithril (100)", "$mat_mithril$", "mat_mithril-100", "Buy 100 Mithril for 10 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Plasteel (100)", "$mat_plasteel$", "mat_plasteel-100", "Buy 100 Plasteel for 10 coins.");
		AddRequirement(s.requirements,"coin","","Coins", 10); //made it cost a lot, so it's better to just conquer the building
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Steel Ingot (100)", "$mat_steelingot$", "mat_steelingot-100", "Buy 100 Steel Ingot for 10 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Mithril Ingot (100)", "$mat_mithrilingot$", "mat_mithrilingot-100", "Buy 100 Mithrilingot for 10 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Sulphur (100)", "$mat_sulphur$", "mat_sulphur-100", "Buy 100 Sulphur for 10 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
		s.spawnNothing = true;
	}
}

/*void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		u8 index = XORRandom(resources.length - 1);
		MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
	}
}*/

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		// if (this.getInventory().isFull()) return;
	
		// u8 index = XORRandom(resources.length - 1);
		// MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
		
		CBlob@ storage = FindStorage(this.getTeamNum());
		u8 index = XORRandom(resources.length);
		
		if (storage !is null)
		{
			MakeMat(storage, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
		}
		else if (!this.getInventory().isFull())
		{
			MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
		}
	}
}

CBlob@ FindStorage(u8 team)
{
	if (team > 100) return null;
	
	CBlob@[] blobs;
	getBlobsByName("stonepile", @blobs);
	
	CBlob@[] validBlobs;
	
	for (u32 i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getTeamNum() == team && !blobs[i].getInventory().isFull())
		{
			validBlobs.push_back(blobs[i]);
		}
	}
	
	if (validBlobs.length == 0) return null;

	return validBlobs[XORRandom(validBlobs.length)];
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(3, -2));
	this.set_bool("shop available", this.isOverlapping(caller));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return true;

	// return false;
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (getNet().isServer())
		{
			string[] spl = name.split("-");
			
			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null) return;
			   
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}