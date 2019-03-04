// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

const string[] resources = 
{
	"mat_pistolammo",
	"mat_rifleammo",
	"mat_shotgunammo",
	"mat_gatlingammo"
};

const u8[] resourceYields = 
{
	3,
	2,
	2,
	5
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 5);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 300;
	this.inventoryButtonPos = Vec2f(-8, 0);
	
	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$contrabass$", "Contrabass.png", Vec2f(8, 16), 0);
	AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 0);
	AddIconToken("$powerdrill$", "PowerDrill.png", Vec2f(32, 16), 0);
	AddIconToken("$rifle$", "Rifle.png", Vec2f(24, 8), 0);
	AddIconToken("$smg$", "SMG.png", Vec2f(24, 8), 0);
	AddIconToken("$revolver$", "Revolver.png", Vec2f(16, 8), 0);
	AddIconToken("$royalarmor$", "RoyalArmor.png", Vec2f(16, 8), 0);
	
	AddIconToken("$mat_ironplate$", "Material_IronPlate.png", Vec2f(8, 8), 0);
	AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$mat_pipe$", "Material_Pipe.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gyromat$", "Material_Gyromat.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gear$", "Material_Gear.png", Vec2f(9, 9), 0);
	AddIconToken("$mat_wheel$", "Material_Wheel.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_tankshell$", "Material_TankShell.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_gatlingammo$", "Material_GatlingAmmo.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_shotgunammo$", "Material_ShotgunAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_rifleammo$", "Material_RifleAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_pistolammo$", "Material_PistolAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_howitzershell$", "Material_HowitzerShell.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_smallbomb$", "Material_SmallBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_incendiarybomb$", "Material_IncendiaryBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_bigbomb$", "Material_BigBomb.png", Vec2f(16, 32), 0);
	AddIconToken("$icon_fragmine$", "FragMine.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_rocket$", "Rocket.png", Vec2f(24, 40), 0);
	AddIconToken("$icon_bazooka$", "Bazooka.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_flamethrower$", "Flamethrower.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_shotgun$", "Shotgun.png", Vec2f(16, 8), 0);
	
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Gunsmith's Workshop");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Low Caliber Ammunition (20)", "$icon_pistolammo$", "mat_pistolammo-20", "Bullets for pistols and SMGs.");
		AddRequirement(s.requirements, "coin", "", "Coins", 60);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High Caliber Ammunition (5)", "$icon_rifleammo$", "mat_rifleammo-5", "Bullets for rifles. Effective against armored targets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 45);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun Shells (4)", "$icon_shotgunammo$", "mat_shotgunammo-4", "Shotgun Shells for... Shotguns.");
		AddRequirement(s.requirements, "coin", "", "Coins", 80);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Machine Gun Ammunition (30)", "$icon_gatlingammo$", "mat_gatlingammo-30", "Ammunition used by the machine gun.");
		AddRequirement(s.requirements, "coin", "", "Coins", 80);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Revolver", "$revolver$", "revolver", "A compact firearm for those with small pockets.\n\nUses Low Caliber Ammunition.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bolt Action Rifle", "$rifle$", "rifle", "A handy bolt action rifle.\n\nUses High Caliber Ammunition.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bobby Gun", "$smg$", "smg", "A powerful submachine gun.\n\nUses Low Caliber Ammunition.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bazooka", "$icon_bazooka$", "bazooka", "A long tube capable of shooting rockets. Make sure nobody is standing behind it.\n\nUses Small Rockets.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Scorcher", "$icon_flamethrower$", "flamethrower", "A tool used for incinerating plants, buildings and people.\n\nUses Oil.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun", "$icon_shotgun$", "shotgun", "A short-ranged weapon that deals devastating damage.\n\nUses Shotgun Shells.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 70);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 3);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
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
	return forBlob.isOverlapping(this) && forBlob.getCarriedBlob() is null;
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
				
				// CBlob@ mat = server_CreateBlob(spl[0]);
							
				// if (mat !is null)
				// {
					// mat.Tag("do not set materials");
					// mat.server_SetQuantity(parseInt(spl[1]));
					// if (!callerBlob.server_PutInInventory(mat))
					// {
						// mat.setPosition(callerBlob.getPosition());
					// }
				// }
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