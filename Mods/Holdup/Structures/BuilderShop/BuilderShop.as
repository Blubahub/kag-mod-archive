// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "HumanoidClasses.as";

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	this.set_string("shop description", "Craft");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood);
		AddRequirement(s.requirements, "blob", "glass_clump", "Glass", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
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
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::boulder_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::trampoline_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::drill_stone);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::saw_stone);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
	}
	
	
	AddIconToken("$loom_icon$", "Loom.png", Vec2f(21, 21), 0);
	{
		ShopItem@ s = addShopItem(this, "Loom", "$loom_icon$", "loom", "A loom for weaving hemp into cloth.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	AddIconToken("$cloth_shirt_icon$", "cloth_shirt_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Cloth Shirt", "$cloth_shirt_icon$", "cloth_shirt", "Light weight clothes for keeping them tiddies hidden.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 2);
	}
	AddIconToken("$cloth_pants_icon$", "cloth_pants_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Cloth Pants", "$cloth_pants_icon$", "cloth_pants", "Light weight clothes for keeping the junk hidden.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
	}
	AddIconToken("$bed_icon$", "Bed.png", Vec2f(23, 13), 0);
	{
		ShopItem@ s = addShopItem(this, "Bed", "$bed_icon$", "bed", "A nice cozy place to sleep and get intimate.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	
	
	AddIconToken("$leathershirt_icon$", "leather_shirt_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Leather Shirt", "$leathershirt_icon$", "leather_shirt", "Crude Armour.\n+2 Defense to arms and torso", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 4);
	}
	AddIconToken("$leatherpants_icon$", "leather_pants_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Leather Pants", "$leatherpants_icon$", "leather_pants", "Crude Armour.\n+2 defense to legs", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 2);
	}
	AddIconToken("$pouch_icon$", "pouch_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Pouch", "$pouch_icon$", "pouch", "A small pocket for holding your items.", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 1);
	}
	AddIconToken("$backpack_icon$", "backpack_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Backpack", "$backpack_icon$", "backpack", "A larger sack worn on your back.", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 2);
	}
	
	AddIconToken("$knife_icon$", "crude_knife_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Knife", "$knife_icon$", "crude_knife", "A crude knife, used for butchering chickens or stabbing backs.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	AddIconToken("$jar_icon$", "Jar.png", Vec2f(6, 7), 0);
	{
		ShopItem@ s = addShopItem(this, "Jar", "$jar_icon$", "jar", "A Jar for storing liquids like dye.", false);
		AddRequirement(s.requirements, "blob", "glass_clump", "Glass", 1);
	}
	AddIconToken("$barrel_icon$", "Barrel.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Barrel", "$barrel_icon$", "barrel", "A barrel for storing items.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal", 1);
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
