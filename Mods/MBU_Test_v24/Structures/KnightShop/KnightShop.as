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
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);


	AddIconToken("$metal_bar$", "MetalBar.png", Vec2f(13, 6), 0);
	AddIconToken("$mat_fizz$", "FizzPowder.png", Vec2f(16, 16), 1);
	AddIconToken("$barrel$", "Barrel.png", Vec2f(16, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "bomb", "A small bomb, watch your hands.\nPress space to light while held.", true);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
		AddRequirement(s.requirements, "blob", "mat_fizz", "Fizz Powder", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bars", 2);
		AddRequirement(s.requirements, "blob", "mat_fizz", "Fizz Powder", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", "A barrel filled with explosives.\nPress space to light while held.", false);
		AddRequirement(s.requirements, "blob", "barrel", "Barrel", 1);
		AddRequirement(s.requirements, "blob", "mat_fizz", "Fizz Powder", 25);
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
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,-4), this, this.getCommandID("switch"), "Switch to Knight", params);
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

			if (name == "filled_bucket")
			{
				CBlob@ b = server_CreateBlobNoInit("bucket");
				b.setPosition(callerBlob.getPosition());
				b.server_setTeamNum(callerBlob.getTeamNum());
				b.Tag("_start_filled");
				b.Init();
				callerBlob.server_Pickup(b);
			}
		}
	}
	
	if (cmd == this.getCommandID("switch"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		if(caller.getName() == "humanoid")
		{
			equipKnight(caller);
		}	
	}
}
