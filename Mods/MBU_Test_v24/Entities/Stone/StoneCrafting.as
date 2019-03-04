#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this ){
	
	//Placing
	
	this.Tag("tileplace");
	this.set_s16("placetile",48);
	this.set_s16("material_cost",10);
	this.Tag("secondary_tileplace");
	this.set_s16("secondary_placetile",64);
	this.set_s16("secondary_material_cost",2);
	
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Create");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);

	AddIconToken("$hachethead_icon$", "hachet_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Hachet", "$hachethead_icon$", "hachet", "A crude axe, for chopping down trees and wood blocks.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 20);
	}
	AddIconToken("$hammer_icon$", "hammer_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Hammer", "$hammer_icon$", "hammer", "A hammer for breaking bricks. Doesn't stun you like picks do when breaking bricks.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
	}
	AddIconToken("$knife_icon$", "knife_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Knife", "$knife_icon$", "knife", "A crude stone knife, used for butchering chickens, surgery or stabbing backs.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
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
			if(name == "stone_anvil"){
				server_CreateBlob("stone_anvil",-1,caller.getPosition());
			} else
			if(name == "hachethead"){
				server_CreateBlob("hachethead",-1,caller.getPosition());
			} else
			if(name == "hammer"){
				server_CreateBlob("hammer",-1,caller.getPosition());
			} else {
				server_CreateBlob(name,-1,caller.getPosition());
			}
		}
	}
}