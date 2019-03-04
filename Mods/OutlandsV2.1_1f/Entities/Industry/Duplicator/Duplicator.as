// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "MakeSeed.as";
#include "modname.as";
//#include "BuilderHittable.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ first = this.addSpriteLayer("firstroller", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());
	CSpriteLayer@ second = this.addSpriteLayer("secondroller", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (first !is null)
	{
		Animation@ anim = first.addAnimation("default", 2, true);
		int[] frames = {10,11,12,13};
		first.animation.AddFrames(frames);
		first.SetOffset(Vec2f(-11, 6));
		first.SetRelativeZ(2);
	}
	
	if (second !is null)
	{
		Animation@ anim = second.addAnimation("default", 2, true);
		int[] frames = {10,11,12,13};
		second.animation.AddFrames(frames);
		second.SetOffset(Vec2f(12, 6));
		second.SetRelativeZ(2);
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Duplicate");
	this.set_u8("shop icon", 25);
	//this.Tag("builder always hit");

	{
		ShopItem@ s = addShopItem(this, "Duplicate stone", "$STONES$", "mat_stone", "Duplicate 25 stone to 100!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		AddRequirement(s.requirements, "blob", "mat_puremagic", "Pure Magic", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Duplicate Wood", "$WOOD$", "mat_wood", "Duplicate 25 wood to 100!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "mat_puremagic", "Pure Magic", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Duplicate gold", "$GOLD$", "mat_gold", "Duplicate 25 gold to 100!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
		AddRequirement(s.requirements, "blob", "mat_puremagic", "Pure Magic", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Duplicate blue gold", "$BLUEGOLD$", "mat_bluegold", "Duplicate 25 blue gold to 100!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_bluegold", "Blue Gold", 25);
		AddRequirement(s.requirements, "blob", "mat_puremagic", "Pure Magic", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Duplicate master stone", "$MASTERSTONE$", "mat_masterstone", "Duplicate 25 master stone to 100!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_masterstone", "Master Stone", 25);
		AddRequirement(s.requirements, "blob", "mat_puremagic", "Pure Magic", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Duplicate Pure Magic...", "$PUREMAGIC$", "mat_puremagic", "Duplicate 30 pure magic to 50!", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_puremagic", "Pure Magic", 30);
		AddRequirement(s.requirements, "blob", "mat_fflesh", "Fresh Flesh", 20);
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
		    if(name.findFirst("mat_") != -1 && name != "mat_puremagic")
			{
				CBlob@ callerBlob = getBlobByNetworkID(caller);
				CInventory@ inv = callerBlob.getInventory();
				CBlob@ mat = server_CreateBlob(name);
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(100);
					if (!callerBlob.server_PutInInventory(mat))
					{
					mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			if(name == "mat_puremagic")
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