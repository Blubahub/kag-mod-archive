#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this ){
	
	//Placing
	
	this.Tag("tileplace");
	this.set_s16("placetile",196);
	this.set_s16("material_cost",10);
	this.Tag("secondary_tileplace");
	this.set_s16("secondary_placetile",205);
	this.set_s16("secondary_material_cost",2);
	
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Carve");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	AddIconToken("$table_icon$", "Table.png", Vec2f(21, 7), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Table", "$table_icon$", "table", "A simple table for cooking.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	
	AddIconToken("$loom_icon$", "Loom.png", Vec2f(21, 21), 0);
	{
		ShopItem@ s = addShopItem(this, "Loom", "$loom_icon$", "loom", "A loom for weaving hemp into cloth.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	
	AddIconToken("$washbasin_icon$", "WashBasin.png", Vec2f(16, 6), 0);
	{
		ShopItem@ s = addShopItem(this, "Wash Basin", "$washbasin_icon$", "wash_basin", "A basin to clean dirt and ores in.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
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
			if(name == "table"){
				server_CreateBlob("table",-1,caller.getPosition());
			}
			if(name == "loom"){
				server_CreateBlob("loom",-1,caller.getPosition());
			}
			if(name == "wash_basin"){
				server_CreateBlob("wash_basin",-1,caller.getPosition());
			}
		}
	}
}