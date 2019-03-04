// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

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

	AddIconToken("$darkorb$", "DarkOrb.png", Vec2f(8, 8), 0);
	AddIconToken("$wraithcloak$", "WraithCloak.png", Vec2f(16, 16), 0);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 3));
	this.set_string("shop description", "Totally Legit Goods");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Coins", "$COIN$", "coins-10", "Cash for yer gold.", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 15);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gold", "$GOLD$", "gold-15", "Gold for yer cash.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem( this, "Working Mine", "$mine$", "faultymine", "A legit working mine.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem( this, "Satchel", "$satchel$", "bomb_satchel", "A safely packed bag of gunpowder.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem( this, "Wraith Cloak", "$wraithcloak$", "wraithcloak", "Made of what?!?", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 1000);
	}
	{
		ShopItem@ s = addShopItem( this, "Dark Orb", "$darkorb$", "darkorb", "Corruption beyond compare.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 1000);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f_zero);

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
			
			
			if(name.findFirst("gold-") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					MakeMat(this, callerBlob.getPosition(), "mat_gold", parseInt(name.split("-")[1]));
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