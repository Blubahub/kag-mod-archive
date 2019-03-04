// Scripts by Diprog, sprite by AsuMagic. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "MakeSeed.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back_moss);
	this.SetLight(true);
	this.SetLightRadius(64.0f );
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5,3));
	this.set_string("shop description", "Buy stuff");
	this.set_u8("shop icon", 25);
	

	{
		ShopItem@ s = addShopItem(this, "Tree Seed", "$seedicon$", (XORRandom(512) >= 256 ? "summontreebushy" : "summontreepine"), "Seeds for regrowing forests.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}	
	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", "Pillage.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}	
	{
		ShopItem@ s = addShopItem( this, "30 Regular Orbs", "$mat_orbs$", "mat_orbs", "The basic kind of orbs.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 15 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Skeleton Rain", "$sskeleton$", "sskeleton", "Powered by dark magic.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}	
	{
		ShopItem@ s = addShopItem( this, "Scroll of Zombie Rain", "$szombie$", "szombie", "Powered by dark magic.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}	
	{
		ShopItem@ s = addShopItem(this, "Book of the Dragoon", "$sdragoon$", "sdragoon", "A spellbook to become a Dragoon.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150 );
	}	
	{
		ShopItem@ s = addShopItem(this, "Book of the Slayer", "$sslayer$", "sslayer", "A spellbook to become a Slayer.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50 );
	}	
	{
		ShopItem@ s = addShopItem(this, "Book of the Necromancer", "$snecromancer$", "snecromancer", "A spellbook to become a Necromancer.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 75 );
	}
	{
		ShopItem@ s = addShopItem(this, "Book of the Gargoyle", "$sgargoyle$", "sgargoyle", "A spellbook to become a Gargoyle.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem(this, "Book of the Arsonist", "$sarsonist$", "sarsonist", "A spellbook to become an Arsonist for 1 life.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50 );
	}
	{
		ShopItem@ s = addShopItem(this, "Book of the Undead Bunny", "$sbunny$", "sbunny", "A spellbook to become an Undead Bunny.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 75 );
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", "Boom boom bang", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs",  "Splash splash drip", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine",  "Remote Boom", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg",  "Big Boom bang", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	u8 kek = caller.getTeamNum();	
	if (kek == 1)
	{
		this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
	}
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
		
		bool isServer = (getNet().isServer());
			
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		CBlob@ blob = getBlobByNetworkID( caller );
		CBlob@ tree;
		Vec2f pos = this.getPosition();
		
		string name = params.read_string();
		
		{
			if(name == "summontreepine")
			{
				if (isServer)
				{
					server_MakeSeed(pos, "tree_pine");
				}			
			}
			
			if(name == "summontreebushy")
			{
				if (isServer)
				{
					server_MakeSeed(pos, "tree_bushy");
				}
			}		
		}
	}
}