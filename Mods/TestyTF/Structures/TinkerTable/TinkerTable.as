// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 5);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 150;
	
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
	AddIconToken("$icon_klaxon$", "Klaxon.png", Vec2f(24, 16), 0);
	AddIconToken("$icon_automat$", "Automat.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_gasextractor$", "GasExtractor.png", Vec2f(24, 16), 0);
	AddIconToken("$icon_mustard$", "Material_Mustard.png", Vec2f(8, 16), 0);
	
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Mechanist's Workshop");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", descriptions[43], false);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gramophone", "$gramophone$", "gramophone", "A device used to play music from Gramophone Records purchased at the Merchant.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Giga Drill Breaker", "$powerdrill$", "powerdrill", "A huge overpowered drill with a durable mithril head.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 2);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Contrabass", "$contrabass$", "contrabass", "A musical instrument for the finest bards.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 1);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Copper Wire (2)", "$mat_copperwire$", "mat_copperwire-2", "A copper wire. Kids' favourite toy.");
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, "Clown's Funny Klaxon", "$icon_klaxon$", "klaxon", "An infernal device housing thousands of lamenting souls.");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 666);
		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, "Autonomous Activator", "$icon_automat$", "automat", "A fish-operated contraption that uses anything in its tiny hands. May be only carried around when not holding anything.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 4);
		AddRequirement(s.requirements, "blob", "fishy", "Fishy", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Zapthrottle Gas Extractor", "$icon_gasextractor$", "gasextractor", "A handheld air pump commonly used for cleaning, martial arts and gas cloud extraction.\n\nLeft mouse: Pull\nRight mouse: Push");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mustard Gas", "$icon_mustard$", "mat_mustard-50", "A bottle of a highly poisonous gas. Causes blisters, blindness and lung damage.");
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}

	// {
		// ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		// AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", descriptions[36], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", descriptions[53], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Arrows (30)", "$mat_arrows$", "mat_arrows-30", descriptions[2], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 15);
		
		// s.spawnNothing = true;
	// }
}

void onTick(CBlob@ this)
{
	CBlob@[] blobs;
	// if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 128.0f, @blobs))
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(96, 64), this.getPosition() + Vec2f(-96, 0), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			
			// print(blob.getName() + "; " + blob.hasTag("vehicle"));
			
			if (blob.hasTag("vehicle"))
			{
				if (blob.getHealth() < blob.getInitialHealth()) blob.server_Heal(1);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
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