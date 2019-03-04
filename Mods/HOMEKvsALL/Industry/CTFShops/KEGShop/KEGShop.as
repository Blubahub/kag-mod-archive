// BoatShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"


void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 8));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
	}
	
	AddIconToken("$minikeg$", "MiniKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Mini-Keg", "$minikeg$", "minikeg", "A smaller keg, can be used by anyone.\n50% weaker than a normal keg.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	
	
/*	AddIconToken("$kegarrow$", "MaterialKegArrow.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Keg Arrow", "$kegarrow$", "mat_kegarrows", "A Keg attached to an arrow.\nTotally not a ballista bomb bolt.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
*/	
	AddIconToken("$instakeg$", "InstaKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Instant Exploding Keg", "$instakeg$", "instakeg", "A Keg that instantly explodes.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 160);
	}
	
	AddIconToken("$bouncykeg$", "BouncyKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Bouncy Keg", "$bouncykeg$", "bouncykeg", "A Keg with springs attached.\nCareful of the backfire.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	
	AddIconToken("$rocketkeg$", "RocketKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Firework Keg", "$rocketkeg$", "rocketkeg", "A Keg with a built in thruster, goes up fast.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	
	AddIconToken("$trikeg$", "TriKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Triple Keg", "$trikeg$", "trikeg", "Three Mini-Kegs packed into one cluster Keg.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 140);
	}
	AddIconToken("$superkeg$", "Superkeg.png", Vec2f(16, 16), 0);
	{
        ShopItem@ s = addShopItem(this, "Homek Keg", "$superkeg$", "superkeg", "A Keg infused with the magic of Homek God.\nUse against Australians.", false);
        AddRequirement(s.requirements, "coin", "", "Coins", 250);
    }
	
	
	///////////////////////////////Bombs
	
	AddIconToken("$bomb$", "MatBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", "A standard explosive bomb.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	
	AddIconToken("$waterbomb$", "WaterBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", "A bomb that stuns and deals no damage.\nExplodes on impact.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	/*
	AddIconToken("$knockbackbomb$", "MatKnockbackBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Knockback Bomb", "$knockbackbomb$", "mat_knockbackbombs", "A bomb that explodes with extra concussive force.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	
	AddIconToken("$firebomb$", "MatFireBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Fire Bomb", "$firebomb$", "mat_firebombs", "A bomb which sets the area around it on fire upon exploding.\nExplodes on contact.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}*/
} 

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}