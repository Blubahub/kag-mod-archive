// Trading Post
#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "MakeDustParticle.as";
							 
void onInit( CBlob@ this )
{	
	this.getSprite().SetZ( -50.0f ); // push to background
	this.getShape().getConsts().mapCollisions = false;	   
	
	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));

	//TODO: set shop type and spawn trader based on some property

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8,8));	
	this.set_string("shop description", "Create");
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
		ShopItem@ s = addShopItem( this, "Javelin", "$ballista_bolt$", "ballista_bolt", "Throw this mutha like a spear or poke people with it like it's a lance! One-time use.", true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 5 );
	}	
	{	 
		ShopItem@ s = addShopItem( this, "Trampoline", "$trampoline$", "trampoline", "Gets you up to high places. Must be deployed.", false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 5 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomb", "$mat_bombs$", "mat_bombs", descriptions[1], true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Wood", "$mat_wood$", "mat_wood", "Build with wood!", true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Stone", "$mat_stone$", "mat_stone", "Build with stone!", true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Water Bomb", "$mat_waterbombs$", "mat_waterbombs", "Currently useless.", true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Keg", "$keg$", "keg", descriptions[19], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 30 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Arrows", "$mat_arrows$", "mat_arrows", descriptions[2], true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", "Currently useless.", true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", "Burn your enemies.", true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 15 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomb Arrow", "$mat_bombarrows$", "mat_bombarrows", descriptions[51], true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bucket", "$bucket$", "bucket", descriptions[36], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{
		ShopItem@ s = addShopItem( this, "Sponge", "$sponge$", "sponge", descriptions[53], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}	
	{
		ShopItem@ s = addShopItem( this, "Boulder", "$boulder$", "boulder", descriptions[17], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Drill", "$drill$", "drill", descriptions[43], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 30 );
	}
	{
		ShopItem@ s = addShopItem( this, "Mine", "$mine$", "mine", descriptions[20], true, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "Mounted Bow", "$mounted_bow$", "mounted_bow", descriptions[31], false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{
		ShopItem@ s = addShopItem( this, "Heart", "$heart$", "heart", "Heals yo health up.", false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bomber", "$bomber$", "bomber", "Thwomp your enemies! Does not actually drop bombs (yet).", false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bison", "$bison$", "bison", "Let nature do your bidding!", false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Airship", "$airship$", "airship", "A big, bad flying fortress.", false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bill Blaster", "$bill_blaster$", "bill_blaster", "Shoots Bullet Bills automatically at enemies. Best placed as far away from the action as possible.", false, true );
		AddRequirement( s.requirements, "coin", "", "Coins", 80 );
	}
	{
		ShopItem@ s = addShopItem( this, "Nuke", "$nuke$", "nuke", "Deals massive damage to all enemies not hiding behind bedrock. Makes a huge crater and has a high probability of making you into one.", false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 2000 );
	}
	{
		ShopItem@ s = addShopItem( this, "Jukebox", "$jukebox$", "jukebox", "Buy this to play a random song that'll get everyone pumped up and fighting the good fight! You must have your background music volume turned up in the settings menu.", false, false );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}
}
   

//Sprite updates

void onTick( CSprite@ this )
{
    //TODO: empty? show it.
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

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (hitterBlob.getTeamNum() == this.getTeamNum() && hitterBlob !is this) {
        return 0.0f;
    } //no griffing

	this.Damage( damage, hitterBlob );

	return 0.0f;
}


void onHealthChange( CBlob@ this, f32 oldHealth )
{
	CSprite @sprite = this.getSprite();

	if (oldHealth > 0.0f && this.getHealth() < 0.0f)
	{
		MakeDustParticle(this.getPosition(), "Smoke.png");
		this.getSprite().PlaySound("/BuildingExplosion");
	}
}


