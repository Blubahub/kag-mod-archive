// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//load config
	if (getRules().exists("ctf_costs_config"))
	{
		cost_config_file = getRules().get_string("ctf_costs_config");
	}

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Totally Legit Goods");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Coins", "$COIN$", "coins-10", "Cash for yer gold.", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 20);
	}
	{
		ShopItem@ s = addShopItem( this, "Working Mine", "$mine$", "faultymine", "A legit working mine.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25);
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
		    if(name.findFirst("coins-") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					   callerPlayer.server_setCoins( callerPlayer.getCoins() + parseInt(name.split("-")[1]) );
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