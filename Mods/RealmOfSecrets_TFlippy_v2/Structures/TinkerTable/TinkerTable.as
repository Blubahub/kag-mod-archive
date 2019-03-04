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
	AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 0);
	AddIconToken("$powerdrill$", "PowerDrill.png", Vec2f(32, 16), 0);
	
	AddIconToken("$mat_ironplate$", "Material_IronPlate.png", Vec2f(8, 8), 0);
	AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$mat_pipe$", "Material_Pipe.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gyromat$", "Material_Gyromat.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gear$", "Material_Gear.png", Vec2f(9, 9), 0);
	AddIconToken("$mat_wheel$", "Material_Wheel.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
	
	
	this.set_Vec2f("shop offset", Vec2f(2,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Mechanist's Workshop");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Copper Wire (2)", "$mat_copperwire$", "mat_copperwire-2", "A copper wire. Kids' favourite toy.", true);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Gear (1)", "$mat_gear$", "mat_gear-1", "A simple metal gear used to construct complex machinery.", true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Accelerated Gyromat (1)", "$mat_gyromat$", "mat_gyromat-1", "A very useful device that accelerates stuff.", true);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 4);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 6);
		AddRequirement(s.requirements, "blob", "mat_gear", "Gear", 1);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Pipe (1)", "$pipe$", "mat_pipe-1", "A pipe. You can peek through it.", true);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 4);
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
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_gear", "Gear", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Tank Shell (1)", "$mat_tankshell$", "mat_tankshell-1", "An highly explosive shell used by tanks.", true);
		AddRequirement(s.requirements, "blob", "mat_ironplate", "Iron Plate", 1);
		AddRequirement(s.requirements, "blob", "mat_gunpowder", "Gunpowder", 10);
		s.spawnNothing = false;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", descriptions[43], true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingots", 5);
		AddRequirement(s.requirements, "blob", "mat_gear", "Gear", 2);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Giga Drill Breaker", "$powerdrill$", "powerdrill", "A huge overpowered drill with a durable mithril head.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingots", 5);
		AddRequirement(s.requirements, "blob", "mat_gear", "Gear", 7);
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