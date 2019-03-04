// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "HumanoidClasses.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Craft");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	
	AddIconToken("$metal_bar$", "MetalBar.png", Vec2f(13, 6), 0);
	AddIconToken("$cloth$", "Cloth.png", Vec2f(16, 8), 0);
	AddIconToken("$mat_dirt$", "MaterialDirt.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_sand$", "Sand.png", Vec2f(16, 16), 1);
	AddIconToken("$glass_clump$", "GlassClump.png", Vec2f(10, 6), 0);

	AddIconToken("$barrel_icon$", "Barrel.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Barrel", "$barrel_icon$", "barrel", "A barrel for storing items.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Filled Bucket", "$_buildershop_filled_bucket$", "filled_bucket", Descriptions::filled_bucket, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	AddIconToken("$bed_icon$", "Bed.png", Vec2f(23, 13), 0);
	{
		ShopItem@ s = addShopItem(this, "Bed", "$bed_icon$", "bed", "A nice cozy place to sleep and get intimate.", false);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::boulder_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::trampoline_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", Descriptions::crate, false);
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	
	
	
	
	AddIconToken("$knife_icon$", "knife_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Knife", "$knife_icon$", "knife", "A crude knife, used for butchering chickens, surgery or stabbing backs.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	AddIconToken("$hachethead_icon$", "hachet_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Hachet", "$hachethead_icon$", "hachet", "A crude axe, for chopping down trees and wood blocks.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 20);
	}
	AddIconToken("$hammer_icon$", "hammer_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Hammer", "$hammer_icon$", "hammer", "A hammer for breaking bricks. Doesn't stun you like picks do when breaking bricks.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
	}
	AddIconToken("$pickaxe_icon$", "pick_axe_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Pickaxe", "$pickaxe_icon$", "pick_axe", "A combination pick and axe.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 60);
	}
	
	
	
	
	
	AddIconToken("$sand_icon$", "Sand.png", Vec2f(16, 16), 3);
	{
		ShopItem@ s = addShopItem(this, "Sand", "$sand_icon$", "mat_sand", "It's coarse and rough and irritating and it gets everywhere.", false);
		AddRequirement(s.requirements, "blob", "mat_dirt", "Dirt", 10);
		s.spawnNothing = true;
	}
	AddIconToken("$fizz_icon$", "FizzPowder.png", Vec2f(16, 16), 3);
	{
		ShopItem@ s = addShopItem(this, "Fizz Powder", "$fizz_icon$", "mat_fizz", "A fine powder that fizzles and explodes when lit.", false);
		AddRequirement(s.requirements, "blob", "mat_dirt", "Dirt", 5);
		AddRequirement(s.requirements, "blob", "mat_sand", "Sand", 5);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood);
		AddRequirement(s.requirements, "blob", "glass_clump", "Glass", 1);
	}
	AddIconToken("$jar_icon$", "Jar.png", Vec2f(6, 7), 0);
	{
		ShopItem@ s = addShopItem(this, "Jar", "$jar_icon$", "jar", "A Jar for storing liquids like dye.", false);
		AddRequirement(s.requirements, "blob", "glass_clump", "Glass", 1);
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
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,-4), this, this.getCommandID("switch"), "Switch to Builder", params);
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
			
			if (name == "mat_sand")
			{
				MakeMat(callerBlob, this.getPosition(), "mat_sand", 10);
			}
			
			if (name == "mat_fizz")
			{
				MakeMat(callerBlob, this.getPosition(), "mat_fizz", 5);
			}
		}
	}
	
	if (cmd == this.getCommandID("switch"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		if(caller.getName() == "humanoid")
		{
			equipBuilder(caller);
		}	
	}
}
