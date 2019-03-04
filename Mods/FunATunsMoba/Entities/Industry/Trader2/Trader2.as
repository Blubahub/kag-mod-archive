// Builder Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4,4));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{	 
		ShopItem@ s = addShopItem( this, "Attack Potion", "$atkpot$", "atkpot", "Increases your attack! I am a beserker!", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 300 );
	}

	{
		ShopItem@ s = addShopItem( this, "Defence Potion", "$defpot$", "defpot", "Increases your defence! Is a fly pestering me? *yawn*", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Speed Potion", "$spdpot$", "spdpot", "Increases your speed! Zoom zoom!", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gravity Potion", "$jmppot$", "jmppot", "Increases your jump height! I CAN FLY!!!", true );
		AddRequirement( s.requirements, "coin", "", "Coin", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Skeleton Bomb", "$mat_bombs$", "mat_bombs", "Throw this to spawn some skeles :D", true );
		AddRequirement( s.requirements, "coin", "", "Coin", 50 );
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