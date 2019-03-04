// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

void onInit(CBlob@ this)
{

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//load config
	if (getRules().exists("ctf_costs_config"))
	{
		cost_config_file = getRules().get_string("ctf_costs_config");
	}

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Sacrifice");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "priest");


	{
		ShopItem@ s = addShopItem(this, "Sacrifice Gold", "$GOLD$", "sacrifice", "Sacrifice gold to empower the golden being.", true);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 10);
	}
}

void onTick(CBlob@ this)
{
	this.set_string("shop description", this.get_string("owner")+"'s Altar");
	
	bool found = false;
	
	CBlob@[] fg;
	getBlobsByName("goldenbeing", @fg);
	for(uint i = 0; i < fg.length; i++)
	{
		if(fg[i].getPlayer() !is null)
		if(fg[i].getPlayer().getUsername() == this.get_string("owner")){
			found = true;
		}
	}
	if(!found)
	{
		server_CreateBlob("altarunused", -1, this.getPosition());
		this.server_Die();
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
		bool isServer = (getNet().isServer());
		u16 callerint, item;
		if (!params.saferead_netid(callerint) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		if(name == "sacrifice"){
			CBlob@[] fg;
			getBlobsByName("goldenbeing", @fg);
			for(uint i = 0; i < fg.length; i++)
			{
				if(fg[i].getPlayer().getUsername() == this.get_string("owner")){
					fg[i].set_s16("power",fg[i].get_s16("power")+10);
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