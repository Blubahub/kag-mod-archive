// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 5);
	
	this.set_string("required class", "sapper");
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	// getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	AddIconToken("$contrabass$", "Contrabass.png", Vec2f(8, 16), 0);
	AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 0);
	AddIconToken("$powerdrill$", "PowerDrill.png", Vec2f(32, 16), 0);
	AddIconToken("$rifle$", "Rifle.png", Vec2f(24, 8), 0);
	AddIconToken("$smg$", "SMG.png", Vec2f(24, 8), 0);
	AddIconToken("$revolver$", "Revolver.png", Vec2f(16, 8), 0);
	
	AddIconToken("$mat_ironplate$", "Material_IronPlate.png", Vec2f(8, 8), 0);
	AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$mat_pipe$", "Material_Pipe.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gyromat$", "Material_Gyromat.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gear$", "Material_Gear.png", Vec2f(9, 9), 0);
	AddIconToken("$mat_wheel$", "Material_Wheel.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_tankshell$", "Material_TankShell.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_gatlingammo$", "Material_GatlingAmmo.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_rifleammo$", "Material_RifleAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_pistolammo$", "Material_PistolAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_howitzershell$", "Material_HowitzerShell.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_smallbomb$", "Material_SmallBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_incendiarybomb$", "Material_IncendiaryBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_bigbomb$", "Material_BigBomb.png", Vec2f(16, 32), 0);
	AddIconToken("$icon_fragmine$", "FragMine.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_rocket$", "Rocket.png", Vec2f(24, 40), 0);
	AddIconToken("$icon_smallrocket$", "Material_SmallRocket.png", Vec2f(8, 16), 0);
	AddIconToken("$icon_nuke$", "Nuke.png", Vec2f(40, 32), 0);
	AddIconToken("$icon_claymore$", "Claymore.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_claymoreremote$", "ClaymoreRemote.png", Vec2f(8, 16), 0);
	
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Demolitionist's Workshop");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Artillery Shell (4)", "$icon_tankshell$", "mat_tankshell-4", "A highly explosive shell used by the artillery.");
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Howitzer Shell (2)", "$icon_howitzershell$", "mat_howitzershell-2", "A large howitzer shell capable of annihilating a cottage.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocket of Doom", "$icon_rocket$", "rocket", "Let's fly to the Moon. (Not really)");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 2);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "S.Y.L.W. 9000 (1)", "$icon_bigbomb$", "mat_bigbomb-1", "A big bomb. Handle with care.");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", descriptions[20], false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fragmentation Mine", "$icon_fragmine$", "fragmine", "A fragmentation mine that fills the surroundings with shards of metal upon detonation.");
		AddRequirement(s.requirements, "coin", "", "Coins", 125);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb (1)", "$bomb$", "mat_bombs-1", descriptions[1], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrow (1)", "$mat_bombarrows$", "mat_bombarrows-1", descriptions[51], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		
		s.spawnNothing = true;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Water Bomb (1)", "$waterbomb$", "mat_waterbombs-1", descriptions[52], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 30);
		
		// s.spawnNothing = true;
	// }	
	{
		ShopItem@ s = addShopItem(this, "Small Bomb (4)", "$icon_smallbomb$", "mat_smallbomb-4", "A small iron bomb. Detonates when it hits surface with enough force.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Incendiary Bomb (1)", "$icon_incendiarybomb$", "mat_incendiarybomb-1", "Sets the peasants on fire.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", descriptions[4], false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		
		s.spawnNothing = true;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Water Arrow (2)", "$mat_waterarrows$", "mat_waterarrows-2", descriptions[50], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 20);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Fire Arrow (2)", "$mat_firearrows$", "mat_firearrows-2", descriptions[32], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 30);
		
		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "R.O.F.L. (1)", "$icon_nuke$", "nuke", "A dangerous warhead stuffed in a cart. Since it's heavy, it can be only pushed around or picked up by balloons.");
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100); // Cart!
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor (1)", "$icon_claymore$", "claymore-1", "A remotely triggered explosive device covered in some sort of slime. Sticks to surfaces.");
		AddRequirement(s.requirements, "coin", "", "Coins", 70);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Small Rocket (1)", "$icon_smallrocket$", "mat_smallrocket-1", "Self-propelled ammunition for rocket launchers.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor Remote Detonator", "$icon_claymoreremote$", "claymoreremote-1", "A device used to remotely detonate Gregors.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);

		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}


// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// bool canChangeClass = caller.getConfig() != "sapper";

	// if(canChangeClass)
	// {
		// this.Untag("class button disabled");
		// this.set_Vec2f("shop offset", Vec2f(4, 0));
		// this.set_bool("shop available", this.isOverlapping(caller));
	// }
	// else
	// {
		// this.Tag("class button disabled");
		// this.set_Vec2f("shop offset", Vec2f(0, 0));
		// this.set_bool("shop available", this.isOverlapping(caller));
	// }
// }

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
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null) return;
				if (callerBlob.getPlayer() !is null && name == "nuke")
				{
					blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				}
				
				if (!blob.hasTag("vehicle"))
				{
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
}