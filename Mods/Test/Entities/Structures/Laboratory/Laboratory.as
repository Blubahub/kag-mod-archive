// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

const string[] resources =
{
	"mat_mithril"
};

const u8[] resourceYields =
{
	2,
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 15);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 150;
	this.inventoryButtonPos = Vec2f(-8, 0);

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);


	AddIconToken("$icon_radpill$", "Radpill.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_bobomax$", "Bobomax.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_mustard$", "Material_Mustard.png", Vec2f(8, 16), 0);
	AddIconToken("$icon_raygun$", "Raygun.png", Vec2f(24, 16), 0);
	
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Laboratory");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Handheld Irradiator", "$raygun$", "raygun", "A rather dangerous mithril-powered device used for cancer research.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 3);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mithril-B-Gone", "$icon_radpill$", "radpill", "A piece of medicine that gives you a partial immunity to the adverse effects of Mithril.\nIt's a suppository!");
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 30);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bobomax", "$icon_bobomax$", "bobomax", "A small suicide pill to sweeten up your last moments. Causes severe halucinations.");
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 25);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mustard Gas", "$icon_mustard$", "mat_mustard-50", "A bottle of a highly poisonous gas. Causes blisters, blindness and lung damage.");
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		u8 index = XORRandom(resources.length);

		if (!this.getInventory().isFull())
		{
			MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	// return forBlob.isOverlapping(this) && forBlob.getCarriedBlob() is null;
	return true;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ carried = caller.getCarriedBlob();

	if (isInventoryAccessible(this, caller))
	{
		this.set_Vec2f("shop offset", Vec2f(4, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (getNet().isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				MakeMat(callerBlob, this.getPosition(), spl[0], parseInt(spl[1]));
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}

// void onDie(CBlob@ this)
// {
	// if (getNet().isServer())
	// {
		// CInventory@ inv = this.getInventory();
		// if (inv is null) return;
	
		// int count = inv.getCount("mat_mithril");
	
		// print("" + count);
	
		// if (count > 100)
		// {
			// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
			// boom.setPosition(this.getPosition());
			// boom.set_u8("boom_start", 25 - u8(count / 50));
			// boom.Init();
		// }
	// }
// }