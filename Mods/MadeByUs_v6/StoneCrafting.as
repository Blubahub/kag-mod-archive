#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this ){
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Carve");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	AddIconToken("$brick_icon$", "Brick.png", Vec2f(8, 8), 0);
	AddIconToken("$slab_icon$", "Slab.png", Vec2f(24, 12), 2);
	
	{
		ShopItem@ s = addShopItem(this, "Brick", "$brick_icon$", "brick", "A brick used for construction.", false);
		//s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Stone Slab", "$slab_icon$", "slab", "A hard slab of stone used for crafting.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this)
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		if(isServer){
			if(name == "slab"){
				server_CreateBlob("slab",-1,caller.getPosition());
			}
		}
	}
}