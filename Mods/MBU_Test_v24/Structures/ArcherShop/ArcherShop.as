// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"
#include "HumanoidClasses.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Fletch");
	this.set_u8("shop icon", 25);


	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "arrow", "Flying pointy things.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 90);
		s.spawnNothing = true;
	}
	
	this.addCommandID("switch");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,4));
	this.set_bool("shop available", this.isOverlapping(caller));
	
	if(this.isOverlapping(caller)){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,-4), this, this.getCommandID("switch"), "Switch to Archer", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}

			if (name == "arrow")
			{
				for(int i = 0;i < 30;i++)callerBlob.server_PutInInventory(server_CreateBlob(name,-1,callerBlob.getPosition()));
			}
		}
	}
	
	if (cmd == this.getCommandID("switch"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		if(caller.getName() == "humanoid")
		{
			equipArcher(caller);
		}	
	}
}
