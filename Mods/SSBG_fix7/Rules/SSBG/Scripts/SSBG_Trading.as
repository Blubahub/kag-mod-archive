#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

#define SERVER_ONLY

const int coinsOnDamageAdd = 10;
const int coinsOnKillAdd = 0;
const int coinsOnDeathLose = 50;	
//

void onInit( CBlob@ this )
{	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8,8));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	{
		ShopItem@ s = addShopItem( this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", 60 );
	}	
	{
		ShopItem@ s = addShopItem( this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}	
	{	 
		ShopItem@ s = addShopItem( this, "Javelin", "$ballista_bolt$", "ballista_bolt", "Throw this mutha like a spear or poke people with it like it's a lance! One-time use.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 5 );
	}	
	{	 
		ShopItem@ s = addShopItem( this, "Trampoline", "$trampoline$", "trampoline", "Gets you up to high places. Must be deployed.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 5 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomb", "$mat_bombs$", "mat_bombs", descriptions[1], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Wood", "$mat_wood$", "mat_wood", "Build with wood!", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Stone", "$mat_stone$", "mat_stone", "Build with stone!", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Water Bomb", "$mat_waterbombs$", "mat_waterbombs", "Currently useless.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Keg", "$keg$", "keg", descriptions[19], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 30 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Arrows", "$mat_arrows$", "mat_arrows", descriptions[2], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", "Currently useless.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", "Burn your enemies.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 15 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomb Arrow", "$mat_bombarrows$", "mat_bombarrows", descriptions[51], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bucket", "$bucket$", "bucket", descriptions[36], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{
		ShopItem@ s = addShopItem( this, "Sponge", "$sponge$", "sponge", descriptions[53], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}	
	{
		ShopItem@ s = addShopItem( this, "Boulder", "$boulder$", "boulder", descriptions[17], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Drill", "$drill$", "drill", descriptions[43], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 30 );
	}
	{
		ShopItem@ s = addShopItem( this, "Mine", "$mine$", "mine", descriptions[20], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "Mounted Bow", "$mounted_bow$", "mounted_bow", descriptions[31], false );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{
		ShopItem@ s = addShopItem( this, "Heart", "$heart$", "heart", "Heals yo health up.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bomber", "$bomber$", "bomber", "Thwomp your enemies! Does not actually drop bombs (yet).", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bison", "$bison$", "bison", "Let nature do your bidding!", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Airship", "$airship$", "airship", "A big, bad flying fortress.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bill Blaster", "$bill_blaster$", "bill_blaster", "Shoots Bullet Bills automatically at enemies. Best placed as far away from the action as possible.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{
		ShopItem@ s = addShopItem( this, "Green Koopa Shell", "$green_shell$", "green_shell", "A weapon of choice for the Mario Bros, this tough shell will keep on sliding, ricochetting, and generally just being a pain in the ass until someone stomps on it and throws it off of a cliff.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 40 );
	}
	{
		ShopItem@ s = addShopItem( this, "Nuke", "$nuke$", "nuke", "Deals massive damage to all enemies not hiding behind bedrock. Makes a huge crater and has a high probability of making you into one.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 2000 );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) );
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
	}
}


// OLD STUFF BELOW //

// give coins for killing

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData )
{
	if (victim !is null )
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins( killer.getCoins() + coinsOnKillAdd );
			}
		}

		victim.server_setCoins( victim.getCoins() - coinsOnDeathLose );
	}
}

// give coins for damage

f32 onPlayerTakeDamage( CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale )
{		
	if (attacker !is null && attacker !is victim) {
		attacker.server_setCoins( attacker.getCoins() + DamageScale*coinsOnDamageAdd/this.attackdamage_modifier );
	}

	return DamageScale;
}