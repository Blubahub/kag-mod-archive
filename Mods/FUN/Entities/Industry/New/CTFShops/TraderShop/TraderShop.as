// Scripts by Diprog, sprite by AsuMagic. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(10,2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	


    {	 
		ShopItem@ s = addShopItem( this, "Wood", "$mat_wood$", "mat_wood", "Exchange 100 Gold for 500 Wood", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 100 );
	}

	{
		ShopItem@ s = addShopItem( this, "Stone", "$mat_stone$", "mat_stone", "Exchange 250 Gold for 500 Stone", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 250 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for wood", "$mat_gold$", "mat_gold", "Exchange 2500 Wood for 500 Gold", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2500 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for stone", "$mat_gold$", "mat_gold", "Exchange 1000 Stone for 500 Gold", true );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 1000 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for cons", "$mat_gold$", "mat_gold", "Buy gold for coins.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
	}
	{
		ShopItem@ s = addShopItem( this, "Coins for flour", "$Coins$", "sellflour", "Sell flour.", true );
		AddRequirement( s.requirements, "blob", "flour", "Flour", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Armor Kit", "$Armorkit$", "armorkit", "To become a Heavy Knight.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Crossbow", "$Crossbow$", "crossbow", "To become a Crossbowman.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Long Bow", "$LongBow$", "longbow", "To become a Hunter.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
	
	
	{
		ShopItem@ s = addShopItem( this, "Scroll of Return", "$Returnscroll$", "returnscroll", "This magic scroll will teleport you to your base.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 150 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Enemy Return", "$Enemyreturnscroll$", "enemyreturnscroll", "This magic scroll will teleport 1 enemy to the his base.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Drought ", "$Droughtscroll$", "droughtscroll", "This magic scroll will evaporate all water in a large surrounding orb.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 120 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Zombies", "$Zombiescroll$", "zombiescroll", "This magic scroll will spawn 5 zombies.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
	}
	{
		ShopItem@ s = addShopItem( this, "Midas Scroll", "$Midasscroll$", "midasscroll", "This magic scroll will turn all stone into gold in 10 blocks radius.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 120 );
	}
	{
		ShopItem@ s = addShopItem( this, "Fish Transform Scroll", "$Fishtransformscroll$", "fishtransformscroll", "This magic scroll will turn all fishes in 10 blocks radius into sharks.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Health", "$Healscroll$", "healscroll", "This magic scroll will heal your teammates.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Powerful Soul Stone", "$SoulStone$", "soulstone", "For transformation into powerful Wizards.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 600 );
	}
	{
		ShopItem@ s = addShopItem( this, "Medium Soul Stone", "$MediumSoulStone$", "medium_soulstone", "For transformation into medium Wizards.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 350 );
	}
	{
		ShopItem@ s = addShopItem( this, "Weak Soul Stone", "$WeakSoulStone$", "weak_soulstone", "For transformation into weak Wizards with special abilities.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{	
	
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
		
		bool isServer = (getNet().isServer());
			
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		
		CPlayer@ player;
		CBlob@ blob = getBlobByNetworkID(caller);
		if (blob !is null) @player = blob.getPlayer();
		
		{
			if(name == "sellflour")
			{
				player.server_setCoins(player.getCoins() + 150);
			}
		}
	}
}
