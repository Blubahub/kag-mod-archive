// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);
AddIconToken("$vehicleshop_upgradebomber$", "HeavyBomb.png", Vec2f(32, 16), 1);
AddIconToken("$vehicleshop_upgradebazooka$", "Bazooka.png", Vec2f(32, 16), 1);
AddIconToken("$vehicleshop_upgrademg$", "Bullet.png", Vec2f(32, 16), 1);
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 9));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_catapult);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ballista);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ballista_ammo);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", "For Ballista\nTurns its piercing bolts into a shaped explosive charge.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", cost_ballista_ammo_upgrade_gold);
		AddRequirement(s.requirements, "not tech", "bomb ammo", "Bomb Bolt", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "MG Upgrade", "$vehicleshop_upgrademg$", "upgradeMG", "For Machine Gun\nA secong magazine which doubles the capacity of the Machine Gun able to hold up to 60 bullets.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 1000);
		AddRequirement(s.requirements, "not tech", "MG ammo", "Machine Gun Upgrade", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bazooka Upgrade", "$vehicleshop_upgradebazooka$", "upgradeBazooka", "For Bazooka\nImplementing a 2-stage firing system which enables the bazooka to fire 2 missiles simultaniously.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 1250);
		AddRequirement(s.requirements, "not tech", "Bazooka ammo", "Bazooka Upgrade", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bomber Upgrade", "$vehicleshop_upgradebomber$", "upgradeBomber", "For Bomber\nAdds a second tube in the bomber so it can hold up to 2 bombs per reload.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 1500);
		AddRequirement(s.requirements, "not tech", "drop bomb ammo", "Bomber Upgrade", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			if (name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
			if (name == "upgradeMG")
			{
				GiveFakeTech(getRules(), "MG ammo", this.getTeamNum());
				//print("MG Tech Given");
			}
			if (name == "upgradeBazooka")
			{
				GiveFakeTech(getRules(), "Bazooka ammo", this.getTeamNum());
				//print("Bazooka Tech Given");
			}
			if (name == "upgradeBomber")
			{
				GiveFakeTech(getRules(), "drop bomb ammo", this.getTeamNum());
				//print("bomber Tech Given");
			}
		}
	}
}