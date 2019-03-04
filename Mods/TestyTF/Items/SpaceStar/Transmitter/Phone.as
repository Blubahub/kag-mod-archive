// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "MakeSeed.as";
#include "MakeCrate.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	AddIconToken("$ss_badger$", "SS_Icons.png", Vec2f(32, 16), 0);
	AddIconToken("$ss_raid$", "SS_Icons.png", Vec2f(16, 16), 2);
	AddIconToken("$ss_minefield$", "SS_Icons.png", Vec2f(16, 16), 3);

	this.getCurrentScript().tickFrequency = 1;
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "SpaceStar Ordering!");
	this.set_u8("shop icon", 11);
	
	// {
		// ShopItem@ s = addShopItem(this, "Wonderful Fluffy Badger!", "$ss_badger$", "badger-parachute", "Every child's dream! Get your Wonderful Fluffy Badger today!");
		// AddRequirement(s.requirements, "coin", "", "Coins", 199);
		
		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "Combat Chicken Assault Squad!", "$ss_raid$", "raid", "Get your own soldier... TODAY!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1249);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Portable Minefield!", "$ss_minefield$", "minefield", "A brave flock of landmines! No more trespassers!");
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
		
		s.spawnNothing = true;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound(XORRandom(100) > 50 ? "/ss_order.ogg" : "/ss_shipment.ogg");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (getNet().isServer())
		{
			string[] spl = name.split("-");

			if (spl.length > 1)
			{
				if (spl[1] == "parachute")
				{
					CBlob@ blob = server_MakeCrateOnParachute(spl[0], "SpaceStar Ordering Goods", 0, -1, Vec2f(callerBlob.getPosition().x, 0));
					blob.Tag("unpack on land");
				}
			}
			else
			{
				if (spl[0] == "raid")
				{
					for (int i = 0; i < 4; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("scoutchicken", "SpaceStar Ordering Assault Squad", 0, -1, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else if (spl[0] == "minefield")
				{
					for (int i = 0; i < 10; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("mine", "SpaceStar Ordering Mines", 0, -1, Vec2f(callerBlob.getPosition().x + (256 - XORRandom(512)), XORRandom(64)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else
				{
					CBlob@ blob = server_CreateBlob(spl[0], -1, Vec2f(callerBlob.getPosition().x, 0));
				}
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("/ss_hello.ogg");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", true);
}