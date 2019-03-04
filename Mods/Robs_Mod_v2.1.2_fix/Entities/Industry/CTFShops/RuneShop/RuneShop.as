// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "RuneIcons.as";

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

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	getTatooRuneIcons();
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Tatoo");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "runemaster");

	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Flame", "$firerunetatoo$", "firerune", "This is gonna burn.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Drop", "$waterrunetatoo$", "waterrune", "Glub glub glub.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Rock", "$earthrunetatoo$", "earthrune", "Hard.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Wind", "$airrunetatoo$", "airrune", "Didn't feel a thing.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Flesh", "$fleshrunetatoo$", "fleshrune", "Wait what.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Timber", "$plantrunetatoo$", "plantrune", "Rustling.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Devour", "$consumerunetatoo$", "consumerune", "It itches.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Nourish", "$growrunetatoo$", "growrune", "I feel strong.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Change", "$polyrunetatoo$", "polyrune", "I don't feel the same.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Move", "$telerunetatoo$", "telerune", "Wasn't I just over there?", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Order", "$negrunetatoo$", "negrune", "Stand straight!", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Rune Tatoo: Chaos", "$chaosrunetatoo$", "chaosrune", "Cheese.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Holy Rune Marking: Light", "$lightrunetatoo$", "lightrune", "Holier than thou.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Holy Rune Marking: Life", "$liferunetatoo$", "liferune", "I feel, so alive!", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Holy Rune Marking: Quick", "$hasterunetatoo$", "hasterune", "Can't catch me.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Holy Rune Marking: Cleanse", "$curerunetatoo$", "curerune", "Be purified!", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Evil Rune Scarring: Dark", "$darkrunetatoo$", "darkrune", "Ahahaha.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Evil Rune Scarring: Death", "$deathrunetatoo$", "deathrune", "I will haunt you.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Evil Rune Scarring: Slow", "$slowrunetatoo$", "slowrune", "Come... back... here...", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Evil Rune Scarring: Plague", "$infectrunetatoo$", "infectrune", "Feel my pain.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
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
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
			if(name != "lightrune" || !callerBlob.hasTag("evil"))
			if(name != "darkrune" || !callerBlob.hasTag("holy"))
			callerBlob.Tag(name+"tatoo");
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