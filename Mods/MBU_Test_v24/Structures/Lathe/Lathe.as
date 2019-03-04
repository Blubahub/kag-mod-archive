
#include "Requirements.as"
#include "ShopCommon.as"
#include "Hitters.as";
#include "MakeMat.as";

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	getMap().server_SetTile(this.getPosition()+Vec2f(0,4), CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Turn");
	this.set_u8("shop icon", 8);

	AddIconToken("$machine_parts_icon$", "MachineParts.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Machine Parts", "$machine_parts_icon$", "machine_parts", "Pieces of machinery: gears, spring, screws, nuts, bolts, etc.", true);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal", 1);
		s.spawnNothing = true;
	}
	AddIconToken("$revolver_icon$", "revolver_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Revolver", "$revolver_icon$", "revolver", "A small pistol that can hold six rounds and fire rapidly.", true);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal", 1);
		AddRequirement(s.requirements, "blob", "mat_machine_parts", "Machine Parts", 1);
	}
	
	this.Tag("grid_blob");
	this.set_u16("grid_id",0);
	this.set_u16("watts_needed",2000);
}

void onTick(CBlob@ this)
{
	this.set_u16("grid_id",0);
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 24.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			
			if(b !is null && b !is this && b.getName() == "power_node" && b.getShape().isStatic()){
				
				if(b.get_u16("grid_id") > this.get_u16("grid_id")){
					this.set_u16("grid_id",b.get_u16("grid_id"));
				}
			}
		}
	}

	string Grid = "\nNo Grid Connection";
	if(this.get_u16("grid_id") > 0)Grid = "\nGrid Number: "+this.get_u16("grid_id");
	
	this.setInventoryName("Lathe"+"\nRequired Power: 2 kW"+Grid);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	bool canTurn = getRules().get_f32("grid_"+this.get_u16("grid_id")+"_power_ratio") >= 1.0f && this.isOverlapping(caller);
	
	this.set_bool("shop available", canTurn);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{

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
			
			if (name == "machine_parts")
			{
				MakeMat(callerBlob, this.getPosition(), "mat_machine_parts", 4);
			}
		}
	}
}
