#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this ){
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Carve");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	AddIconToken("$barrel_icon$", "Barrel.png", Vec2f(16, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Barrel", "$barrel_icon$", "barrel", "A barrel for storing items.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
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
			if(name == "barrel"){
				server_CreateBlob("barrel",-1,caller.getPosition());
			}
		}
	}
}