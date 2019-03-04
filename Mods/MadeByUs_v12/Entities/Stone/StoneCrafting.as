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
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Create");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);

	AddIconToken("$hachethead_icon$", "HachetHead.png", Vec2f(6, 6), 0);
	{
		ShopItem@ s = addShopItem(this, "Hachet Head", "$hachethead_icon$", "hachethead", "A crude axe head, can be placed on a stick to make a hachet.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	
	AddIconToken("$stone_anvil_icon$", "StoneAnvil.png", Vec2f(18, 11), 0);
	{
		ShopItem@ s = addShopItem(this, "Make-shift Anvil", "$stone_anvil_icon$", "stone_anvil", "Stone cobbled together to make a crude anvil.", false);
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
			if(name == "stone_anvil"){
				server_CreateBlob("stone_anvil",-1,caller.getPosition());
			}
			if(name == "hachethead"){
				server_CreateBlob("hachethead",-1,caller.getPosition());
			}
		}
	}
}