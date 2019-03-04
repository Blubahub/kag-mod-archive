// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$contrabass$", "Contrabass.png", Vec2f(8, 16), 0);
	AddIconToken("$raft$", "Raft.png", Vec2f(64, 32), 0);
	
	
	this.set_Vec2f("shop offset", Vec2f(2,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 5));
	this.set_string("shop description", "Forge");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", descriptions[36], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
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
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
	}
	{
		ShopItem@ s = addShopItem(this, "Raft", "$raft$", "raft", "Poor man's warship.", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", descriptions[17], false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 30);
	}
}

void onTick(CSprite@ this)
{
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
		this.getSprite().PlaySound("/ChaChing.ogg");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		{			
			if(name.findFirst("mat_") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					string[] tokens = name.split("-");
				
					if(callerPlayer !is null)
					{
						CBlob@ mat = server_CreateBlob(tokens[0]);
						
						if (mat !is null)
						{
							mat.Tag("do not set materials");
							mat.server_SetQuantity(parseInt(tokens[1]));
							if (!callerBlob.server_PutInInventory(mat))
							{
								mat.setPosition(callerBlob.getPosition());
							}
						}
					}
				}
			}
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}