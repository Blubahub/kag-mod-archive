// Workbench

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("can settle"); //for DieOnCollapse to prevent 2 second life :)

	InitWorkshop(this);
}


void InitWorkshop(CBlob@ this)
{
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	
	AddIconToken("$gunpowder_icon$", "GunPowder.png", Vec2f(16, 16), 3);
	AddIconToken("$bow_icon$", "Bow.png", Vec2f(16, 16), 0);
	AddIconToken("$anvil_icon$", "Anvil.png", Vec2f(24, 24), 0);


	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LANTERN);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", descriptions[36], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BUCKET);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", descriptions[53], false);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 20);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", descriptions[18], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CRATE);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW);
		AddRequirement(s.requirements, "blob", "sawblade", "Saw Blade", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", descriptions[10], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_DINGHY);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", descriptions[17], false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Anvil", "$anvil_icon$", "anvil", "An anvil for smithing everything.", false);
		AddRequirement(s.requirements, "blob", "mat_metalbars", "Metal Bar", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Gun Powder", "$gunpowder_icon$", "mat_gunpowder", "For explosives.", false);
		AddRequirement(s.requirements, "blob", "mat_sand", "Sand", 125);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 125);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", descriptions[52], true);
		AddRequirement(s.requirements, "blob", "mat_glass", "Glass", 20);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "GunPowder", 25);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bow", "$bow_icon$", "bow", "A bow, for archery.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", descriptions[2], true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 30);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 3);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", descriptions[50], true);
		AddRequirement(s.requirements, "blob", "mat_arrows", "Arrow", 2);
		AddRequirement(s.requirements, "blob", "mat_waterbombs", "Water Bomb", 2);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", descriptions[32], true);
		AddRequirement(s.requirements, "blob", "mat_arrows", "Arrow", 2);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", descriptions[51], true);
		AddRequirement(s.requirements, "blob", "mat_arrows", "Arrow", 1);
		AddRequirement(s.requirements, "blob", "mat_bombs", "Bomb", 1);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 2);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop buy"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		bool spawnToInventory = params.read_bool();
		bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
		string blobName = params.read_string();
		u8 s_index = params.read_u8();

		// check spam
		//if (blobName != "factory" && isSpammed( blobName, this.getPosition(), 12 ))
		//{
		//}
		//else
		{
			this.getSprite().PlaySound("/ConstructShort");
		}
	}
}

//sprite - planks layer

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(6);
		planks.SetOffset(Vec2f(3.0f, -7.0f));
		planks.SetRelativeZ(-100);
	}
}
