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
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Iron Anvil");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Iron Plate (2)", "$mat_ironplate$", "mat_ironplate-2", "A thick sheet of iron.", true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		s.spawnNothing = true;
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