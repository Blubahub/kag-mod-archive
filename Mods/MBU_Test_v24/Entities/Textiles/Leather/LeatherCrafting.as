#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this ){
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Leather");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	AddIconToken("$leather$", "Leather.png", Vec2f(10, 9), 0);
	
	AddIconToken("$pouch_icon$", "pouch_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Pouch", "$pouch_icon$", "pouch", "A small pocket for holding your items.", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 1);
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
		
		CBlob@ item_blob = getBlobByNetworkID(item);
		
		string name = params.read_string();
		if (caller !is null)
		if(isServer){
			if(name == "sack"){
				this.server_Die();
				if (item_blob !is null)caller.server_Pickup(item_blob);
			}
		}
	}
}