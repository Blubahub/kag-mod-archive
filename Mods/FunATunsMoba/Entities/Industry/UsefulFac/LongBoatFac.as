// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "ProductionCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.Tag("getthis");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.set_u32("minionCD", 0);
	addSeedItem( this, "blah", "bleg", 23, 1);
	addSeedItem1( this, "blah", "bleg", 23, 1);
	addSeedItem2( this, "blah", "bleg", 23, 1);
	addSeedItem3( this, "blah", "bleg", 23, 1);
	addSeedItem4( this, "blah", "bleg", 23, 1);
}

ShopItem@ addSeedItem( CBlob@ this, const string &in seedName,const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, "atkpot", newIcon, "atkpot", "", 45, false, 1, requirements );
	return item;
}

ShopItem@ addSeedItem1( CBlob@ this, const string &in seedName,const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, "defpot", newIcon, "defpot", "", 45, false, 1, requirements );
	return item;
}

ShopItem@ addSeedItem2( CBlob@ this, const string &in seedName,const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, "spdpot", newIcon, "atkpot", "", 45, false, 1, requirements );
	return item;
}

ShopItem@ addSeedItem3( CBlob@ this, const string &in seedName,const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, "jmppot", newIcon, "atkpot", "", 45, false, 1, requirements );
	return item;
}

ShopItem@ addSeedItem4( CBlob@ this, const string &in seedName,const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, "mat_bombs", newIcon, "mat_bombs", "", 30, false, 2, requirements );
	return item;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
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