// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	// Sword Icons
	AddIconToken( "$woodenblade_$", "WoodenBlade.png", Vec2f(16,16), 0);
	AddIconToken( "$stoneblade_$", "StoneBlade.png", Vec2f(16,16), 0);
	AddIconToken( "$ironblade_$", "IronBlade.png", Vec2f(16,16), 0);
	AddIconToken( "$mithrilblade_$", "MithrilBlade.png", Vec2f(16,16), 0);
	AddIconToken( "$platiumblade_$", "PlatiumBlade.png", Vec2f(16,16), 0);
	
	// Bow Icons
	AddIconToken( "$woodenbow_$", "WoodenBow.png", Vec2f(16,16), 0);
	AddIconToken( "$stonebow_$", "StoneBow.png", Vec2f(16,16), 0);
	AddIconToken( "$ironbow_$", "IronBow.png", Vec2f(16,16), 0);
	AddIconToken( "$mithrilbow_$", "MithrilBow.png", Vec2f(16,16), 0);
	AddIconToken( "$platiumbow_$", "PlatiumBow.png", Vec2f(16,16), 0);
  AddIconToken( "$triplebow_$", "TripleBow.png", Vec2f(16,16), 0);
	
	// Armor Icons
	AddIconToken( "$woodenarmor_$", "WoodenArmor.png", Vec2f(32,32), 0);
	AddIconToken( "$stonearmor_$", "StoneArmor.png", Vec2f(32,32), 0);
	AddIconToken( "$ironarmor_$", "IronArmor.png", Vec2f(32,32), 0);
	AddIconToken( "$mithrilarmor_$", "MithrilArmor.png", Vec2f(32,32), 0);
	AddIconToken( "$platiumarmor_$", "PlatiumArmor.png", Vec2f(32,32), 0);
	AddIconToken( "$tunic_$", "TravelersTunic.png", Vec2f(32,32), 0);
	AddIconToken( "$TITAN_$", "TITAN.png", Vec2f(32,32), 0);
	
	
	// Special Sword Icons
	AddIconToken( "$greed_$", "Greed.png", Vec2f(16,16), 0);
	AddIconToken( "$shadowblade_$", "ShadowBlade.png", Vec2f(16,16), 0);
	AddIconToken( "$bladeoflight_$", "BladeOfLight.png", Vec2f(16,16), 0);
	AddIconToken( "$bladeofundead_$", "BladeOfUndead.png", Vec2f(16,16), 0);
    

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(8, 8));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Wooden Sword", "$woodenblade_$", "woodenblade", "A sword made of wood. x1.1 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Stone Sword", "$stoneblade_$", "stoneblade", "A sword made of stone. x1.25 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Iron Sword", "$ironblade_$", "ironblade", "A sword made of iron. x1.5 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Mithril Sword", "$mithrilblade_$", "mithrilblade", "A sword made of mithril. x1.75 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
	}
	{
		ShopItem@ s = addShopItem(this, "Platium Sword", "$platiumblade_$", "platiumblade", "A sword made of platinum. x2 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 350);
	}
	{
		ShopItem@ s = addShopItem(this, "Wooden Bow", "$woodenbow_$", "woodenbow", "A bow made of wood. x1.1 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Stone Bow", "$stonebow_$", "stonebow", "A bow made of stone. x1.25 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Iron Bow", "$ironbow_$", "ironbow", "A bow made of iron. x1.5 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Mithril Bow", "$mithrilbow_$", "mithrilbow", "A bow made of mithril. x1.75 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
	}
	{
		ShopItem@ s = addShopItem(this, "Heart Singer Bow", "$platiumbow_$", "platiumbow", "Extremely deadly bow. x4 dmg", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 1500);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 950);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Wooden Armour", "$woodenarmor_$", "woodenarmor", "Armor made of wood", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Travelers Tunic", "$tunic_$", "tunic", "Armor that reduces defense but increases speed", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Stone Armour", "$stonearmor_$", "stonearmor", "Armor made of stone", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Iron Armour", "$ironarmor_$", "ironarmor", "Armor made of iron", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Mithril Armour", "$mithrilarmor_$", "mithrilarmor", "Armor made of mithril", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
	}
	{
		ShopItem@ s = addShopItem(this, "Platium Armour", "$platiumarmor_$", "platiumarmor", "Armor made of platinum", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 350);
	}
	{
		ShopItem@ s = addShopItem(this, "T.I.T.A.N", "$TITAN_$", "TITAN", "THE INSANE TOUGH ARMOR NECKTIE", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 1000);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 1500);
	}
	{
		ShopItem@ s = addShopItem(this, "Greed", "$greed_$", "greed", "A sword that gives you coins", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 400);
	}
	{
		ShopItem@ s = addShopItem(this, "The Shadow Blade", "$shadowblade_$", "shadowblade", "A sword that increases speed and damage", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
	}
	{
		ShopItem@ s = addShopItem(this, "The Blade Of Light", "$bladeoflight_$", "bladeoflight", "A sword that heals and increases damage", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 450);
	}
	{
		ShopItem@ s = addShopItem(this, "The Blade Of Undead", "$bladeofundead_$", "bladeofundead", "A sword that summons skeles", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 700);
	}
  {
		ShopItem@ s = addShopItem(this, "Triple Bow", "$triplebow_$", "triplebow", "A bow that fires 3 arrows", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 2500);
	}
}/*
void onTick( CBlob@ this )
{
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	print("button call");
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ Fire_on = caller.CreateGenericButton( "$mat_wood$", Vec2f(10.0f,1.0f), this, this.getCommandID("Smelt"), "Smelt", params);
	if(caller.getDistanceTo(this) < 20.0f && HasOre(this) && !this.get_bool( "Smelting"))
	{
		if(Fire_on != null)
		{
			Fire_on.SetEnabled(true);
		}
	}
	else
	{
			Fire_on.SetEnabled(false);
	}
	
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	u16 netID;
	print("1");
	if(!params.saferead_netid(netID))
	{
	    return;
	}
	print("2");
	CBlob@ caller = getBlobByNetworkID(netID);
    if(cmd == this.getCommandID("Smelt") && !this.get_bool( "Smelting") && caller != null)
	{
		if(this.getBlobCount("bf_angelite") >= 10)
		{
		this.TakeBlob("bf_angelite", 10);
		this.TakeBlob("bf_coal", 5);
		this.set_u8("Smelt_bar", 0);
		this.set_bool( "Smelting" , true);
		}
		else if(this.getBlobCount("bf_cobalt") >= 10)
		{
		this.TakeBlob("bf_cobalt", 10);
		this.TakeBlob("bf_coal", 5);
		this.set_u8("Smelt_bar", 1);
		this.set_bool( "Smelting" , true);
		}
		else if(this.getBlobCount("bf_scandium") >= 10)
		{
		this.TakeBlob("bf_scandium", 10);
		this.TakeBlob("bf_coal", 5);
		this.set_u8("Smelt_bar", 2);
		this.set_bool( "Smelting" , true);
		}
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("fire");
		this.SetLight(true);
	}
}
bool HasOre(CBlob@ this)
{
	return (this.getBlobCount("bf_cobalt") >= 10 || this.getBlobCount("bf_scandium") >= 10 || this.getBlobCount("bf_angelite") >= 10) && this.getBlobCount("bf_coal") >= 5;
}
void TickSmelt( CBlob@ this )
{
    this.set_u8("Smelt_time", this.get_u8("Smelt_time") + 1);
	
}
string findBar(u8 bar)
{	
	if(bar == 0)
	{
		return "bf_angelitemedallions";
	}
	else if(bar == 1)
	{
		return "bf_cobaltbar";
	}
	else if(bar == 2)
	{
		return "bf_scandiumbar";
	}
	else
	{
		return "";
	}
}*/