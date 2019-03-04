// Scripts by Diprog, sprite by RaptorAnton. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "WizardsRespawnCommand.as"
void onInit( CSprite@ this )
{	
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ cristal = this.addSpriteLayer( "cristal", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(cristal !is null)
	{

		Animation@ anim = cristal.addAnimation( "default", 1, true );
		const int[] frames = {7,8,9,10,11,12};
		anim.time = 6;
    	anim.loop = true;
		anim.AddFrames(frames);
		cristal.SetRelativeZ( 10 );
		cristal.SetVisible(false);
	}

	CSpriteLayer@ nocristal = this.addSpriteLayer( "nocristal", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(nocristal !is null)
	{
		Animation@ anim = nocristal.addAnimation( "default", 1, true );
		anim.AddFrame(13);
		nocristal.SetRelativeZ( 10 );
		nocristal.SetVisible(true);
	}
}
void onInit( CBlob@ this )
{	 
	InitWizardAltarClasses( this );
    this.SetLight( true );
    this.SetLightRadius( 64.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;
	this.addCommandID("put_cristal");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.set_Vec2f("shop offset", Vec2f(0, 2));
	this.set_Vec2f("shop menu size", Vec2f(4,2));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem( this, "30 Regular Orbs", "$Mat_orbs$", "mat_orbs", "Hurt your enemies", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "5 Fire Orbs", "$Mat_fireorbs$", "mat_fireorbs", "Set stuff on fire", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "3 Bomb Orbs", "$Mat_bomborbs$", "mat_bomborbs", "Hurts more and destroys terrain", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "10 Water Orbs", "$Mat_waterorbs$", "mat_waterorbs", "Splashes and stuns", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Invisibility", "$Invis_potion$", "invis_potion", "Makes you invisible", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Lightness", "$Light_potion$", "light_potion", "Makes you lighter", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	bool hasCristal = caller.getBlobCount("cristal") > 0;
	if (!this.hasTag("cristal") && hasCristal)
	{
		caller.CreateGenericButton( "$Cristal$", Vec2f(0,-2), this, this.getCommandID("put_cristal"), "Build Cristal", params );
	}
	else if (!this.hasTag("cristal") && !hasCristal)
	{
		CButton@ btn = caller.CreateGenericButton( "$Cristal$", Vec2f(0,-2), this, 0, "Build Cristal Requers: Cristal" );
			if (btn !is null) { btn.SetEnabled( false );}
	}

    if (canChangeClass( this, caller ) && caller.getTeamNum() == this.getTeamNum() && this.hasTag("cristal"))
    {
        CBitStream params;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton( "$change_class$", Vec2f(0,0), this, SpawnCmd::buildMenu, "Swap Class", params );
    }
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	onWizardAltarRespawnCommand( this, cmd, params );
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}


	if (cmd == this.getCommandID("put_cristal"))
	{
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );

		blob.TakeBlob( "cristal", 1 );
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ cristal = sprite.getSpriteLayer("cristal");
		CSpriteLayer@ nocristal = sprite.getSpriteLayer("nocristal");
		if (cristal !is null)
			cristal.SetVisible(true);
		if (nocristal !is null)
			nocristal.SetVisible(false);
		sprite.PlaySound("/Construct.ogg"); 
		this.Tag("cristal");
	}
}