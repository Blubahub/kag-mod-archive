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
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$contrabass$", "Contrabass.png", Vec2f(8, 16), 0);
	AddIconToken("$copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$component$", "Material_Component.png", Vec2f(9, 9), 0);
	AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 0);
	AddIconToken("$powerdrill$", "PowerDrill.png", Vec2f(32, 16), 0);
	
	AddIconToken("$copper_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 0);
	AddIconToken("$iron_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 1);
	AddIconToken("$steel_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 2);
	AddIconToken("$gold_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 3);
	AddIconToken("$mithril_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 4);
	AddIconToken("$lifesteel_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 5);
	AddIconToken("$wilmet_ingot$", "Icon_Ingot.png", Vec2f(13, 7), 6);
	
	
	
	this.set_Vec2f("shop offset", Vec2f(2,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Mechanist's Workshop");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Copper Wire", "$copperwire$", "mat_copperwire-4", "A copper wire. Kids' favourite toy.", true);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Mechanical Component", "$mat_component$", "mat_component-2", "A mechanical component used to construct various complex machinery.", true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Contrabass", "$contrabass$", "contrabass", "A musical instrument for the finest bards.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Gramophone", "$gramophone$", "gramophone", "A device used to play music from Gramophone Records.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingots", 2);
		AddRequirement(s.requirements, "blob", "mat_component", "Mechanical Component", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", descriptions[43], true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Iron Ingots", 5);
		AddRequirement(s.requirements, "blob", "mat_component", "Mechanical Component", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Giga Drill Breaker", "$powerdrill$", "powerdrill", "A huge overpowered drill with a durable mithril head.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingots", 25);
		AddRequirement(s.requirements, "blob", "mat_component", "Mechanical Component", 7);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 4);
		s.spawnNothing = false;
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
		this.getSprite().PlaySound("/ConstructShort");
		
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