#include "VehicleCommon.as"
#include "Hitters.as"
#include "GetAttached.as"
#include "Explosion.as"

#include "BomberCommon.as"

const int woodPrice = 1000;
const int stonePrice = 2000;
const int goldPrice = 300;
void onInit(CBlob@ this )
{
	Vehicle_Setup( this,
                   34.0f, // move speed
                   0.19f,  // turn speed
                   Vec2f(0.0f, -5.0f), // jump out velocity
                   true  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_SetupAirship( this, v, -350.0f );
    
    this.SetLight( true );
    this.SetLightRadius( 48.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    
	this.set_f32("map dmg modifier", 35.0f);
                           
    //this.getShape().SetOffset(Vec2f(0,0));  
  //  this.getShape().getConsts().bullet = true;
//	this.getShape().getConsts().transports = true;

	CSprite@ sprite = this.getSprite();
	BomberInfo bomber;	  
	this.set("bomberInfo", @bomber);
	
	for (int i = 0; i < bombTypeNames.length; i++)
	{
		this.addCommandID(bombTypeNames[i]);
	}
	this.addCommandID("upgrade");
	this.addCommandID("own");
	this.addCommandID("lock");
	this.addCommandID("unlock");
	this.addCommandID("kick");
	// add balloon
	InitLayers(sprite, "Balloon.png");
	//repairing
	this.set_u16("repair_costs", 1000);
	this.set_string("repair_mat_cfg", "mat_wood");
	this.set_string("repair_mat_name", "Wood");
}

void onTick( CBlob@ this )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{			
		if(this.getHealth() > 1.0f)
		{
			Vehicle_StandardControls( this, v );
			
			
		
			if (this.hasTag("has_fuel"))
				v.move_speed = 34.0f;
			else
			{
				v.fly_amount = 0.0f;
				v.move_speed = 0.0f;
			}
			//TODO: move to atmosphere damage script
			f32 y = this.getPosition().y;
			if(y < (maxY * (-1)))
			{
				if(getGameTime() % 1 == 0)
					if (XORRandom(3)==2) { Explode(this,8,3.0); }
					this.server_Hit( this, this.getPosition(), Vec2f(0,0), 0.075f, 0, true );
			}
		}
		else
		{
			this.server_DetachAll();
			this.setAngleDegrees(this.getAngleDegrees()+(this.isFacingLeft()?1:-1));
			if (this.isOnGround() || this.isInWater())
			{
				this.server_SetHealth(-1.0f);
				this.server_Die();
			}
			else
			{
				//TODO: effects
				if(getGameTime() % 30 == 0)
					this.server_Hit( this, this.getPosition(), Vec2f(0,0), 0.05f, 0, true );
			}
		}
	}
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_ground( this, blob );
}			 

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}

	if (attached !is null)
	{
		CBlob@ attachedattached = getAttached( attached, "PICKUP" );
		if (attachedattached !is null && (attachedattached.hasTag("heavy weight") || attachedattached.hasTag("medium weight")))
			attached.server_DetachAll();
		else 
		{
			if (!this.hasTag("locked"))
				Vehicle_onAttach( this, v, attached, attachedPoint );
		}
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onDetach( this, v, detached, attachedPoint );
}		


// SPRITE

void onInit( CSprite@ this )
{
	this.SetZ(-50.0f);
	this.getCurrentScript().tickFrequency = 5;
}

void onTick( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	f32 ratio = 1.0f - (blob.getHealth()/blob.getInitialHealth());
	this.animation.setFrameFromRatio(ratio);
	
	CSpriteLayer@ balloon = this.getSpriteLayer( "balloon" );
	if (balloon !is null)
	{
		if(blob.getHealth() > 1.0f)
			balloon.animation.frame = Maths::Min((ratio)*3,1.0f);
		else
			balloon.animation.frame = 2;
	}
	
	CSpriteLayer@ burner = this.getSpriteLayer( "burner" );
	if (burner !is null)
	{
		burner.SetOffset( Vec2f(0.0f, -14.0f) );
		s8 dir = blob.get_s8("move_direction");
		if(dir == 0)
		{
			blob.SetLightColor( SColor(255, 255, 240, 171 ) );
			burner.SetAnimation("default");
		}
		else if(dir < 0)
		{
			blob.SetLightColor( SColor(255, 255, 240, 200 ) );
			burner.SetAnimation("up");
		}
		else if(dir > 0)
		{
			blob.SetLightColor( SColor(255, 255, 200, 171 ) );
			burner.SetAnimation("down");
		}
	}
}
	
void onRender( CSprite@ this )
{

	CBlob@ blob = this.getBlob();
	CBlob@ flyer = getAttached(blob, "FLYER");
	
	const u16 coal = blob.getBlobCount("mat_coal");
	const u16 bombs = blob.getBlobCount("mini_keg");
	
	float health = Maths::Round(blob.getHealth());
	
		/////* STRINGS */////
	
	string low_h = "Safe height";                          // Flashy green
	string mid_h = "Correct height";                       // Dark green
	string high_h = "High height - Fly less higher!";      // Orange
	string die_h = "DANGER - Fly less higher!";            // Red

	string full_c = "Very high fuel level";                // Flashy green
	string high_c = "High fuel level";                     // Dark green
	string mid_c = "Medium fuel level";                    // Black
	string low_c = "DANGER - Low fuel level";              // Orange
	string empty_c = "NO COAL - REFILL";                   // Red
	
	string str_bombs = "Bombs : "+bombs;                         // From flashy green to black
	
	string str_life = "Health : "+blob.getHealth();
	
		/////* STRING CHOOSING VARIABLES */////
	
	string str_h;											         // Height
	string str_c;											         // Fuel
		  
	float bomberPosY = blob.getPosition().y;
	float bomberPosY_from_danger = bomberPosY + 150;
	
	if (flyer !is null && flyer.isMyPlayer() && flyer.isAttached()) {
	
			SColor col_c = SColor(255,0,0,0);
			SColor col_h = SColor(255,0,0,0);
			SColor col_b = SColor(255,0,(bombs*44.6)+32,0);
			SColor col_l = SColor(255,0,0,0);
			
			SColor white = SColor(255,255,255,255);
			SColor black = SColor(255,0,0,0);
	
		// Health
			if (health>5)
			{
				col_l = SColor(255,0,255,0);
			}
			else if (health>3)
			{
				col_l = SColor(255,255,100,0);
			}
			else
			{
				col_l = SColor(255,255,0,0);
			}
	
		// Coal		
			if (coal > 1000) {
				col_c = SColor(255,0,255,0);
				str_c = full_c;
			}
			else if (coal > 500) {
				col_c = SColor(255,0,180,0);
				str_c = high_c;
			}
			else if (coal > 100) {
				col_c = SColor(255,180,180,0);
				str_c = mid_c;
			}
			else if (coal > 0) {
				col_c = SColor(255,255,80,0);
				str_c = low_c;
			}
			else {
				col_c = SColor(255,255,0,0);
				str_c = empty_c;
			}
			
		// Height
			if (bomberPosY_from_danger > 400) {
				col_h = SColor(255,0,255,0);
				str_h = low_h;
			}
			else if (bomberPosY_from_danger > 200) {
				col_h = SColor(255,60,180,0);
				str_h = mid_h;
			}
			else if (bomberPosY_from_danger > 50) {
				col_h = SColor(255,255,80,0);
				str_h = high_h;
			}
			else {
				this.PlaySound("warning.ogg", 0.5f);
				col_h = SColor(255,255,0,0);
				str_h = die_h;
			}
		
		float coalbary = 275-coal*0.12;
		
		if (coal<=0) {
			float coalbary=275;
		}
		else if (coal>1000) {
			float coalbary=151;
		}

		GUI::DrawPane(Vec2f(20,150), Vec2f(30,275));
		GUI::DrawRectangle(Vec2f(23,coalbary), Vec2f(27,274), SColor(255,0,0,0));
		GUI::DrawRectangle(Vec2f(21,250), Vec2f(29,275), SColor(125,255,0,0));
		
		GUI::DrawPane(Vec2f(34,150),Vec2f(270,275));
		
		GUI::DrawRectangle(Vec2f(41,157),Vec2f(63,179), black);
		GUI::DrawRectangle(Vec2f(42,158),Vec2f(62,178), col_c);
		GUI::DrawText(str_c,Vec2f(68,159),white);
		
		GUI::DrawRectangle(Vec2f(41,185),Vec2f(63,207),black);
		GUI::DrawRectangle(Vec2f(42,186),Vec2f(62,206),col_h);
		GUI::DrawText(str_h,Vec2f(68,187),white);
		
		GUI::DrawRectangle(Vec2f(41,213),Vec2f(63,235),black);
		GUI::DrawRectangle(Vec2f(42,214),Vec2f(62,234),col_b);
		GUI::DrawText(str_bombs,Vec2f(68,215),white);
		
		GUI::DrawRectangle(Vec2f(41,242),Vec2f(63,264),black);
		GUI::DrawRectangle(Vec2f(42,243),Vec2f(62,263),col_l);
		GUI::DrawText(str_life, Vec2f(68,244), white);
	}
		/*GUI::DrawText( stats ,
				Vec2f(10, 200), Vec2f(200, 200), color, true, true, true );*/
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	u16 woodCount = caller.getBlobCount("mat_wood");
	const u16 stoneCount = caller.getBlobCount("mat_stone");
	const u16 goldCount = caller.getBlobCount("mat_gold");
	
	BomberInfo@ bomber;
	if (!this.get( "bomberInfo", @bomber )) {
		return;
	}
	
	string owner = this.get_string("owner");
	
	CBlob@ flyer = getAttached( this, "FLYER" );
	if (flyer !is null && flyer.isMyPlayer())
	{
		for (int i = 0; i < bombTypeNames.length; i++)
		{
			if (bomber.bomb_type == i)
			{
				uint nextType = i + 1;
				if (nextType < bombTypeNames.length)
				{
					flyer.CreateGenericButton( bombIcons[nextType], Vec2f(0,8), this, this.getCommandID(bombTypeNames[nextType]), "Swap bomb type to " + bombNames[nextType] + ". " + bombNames[i] + " is selected.", params );
					break;
				}
				else
					flyer.CreateGenericButton( bombIcons[0], Vec2f(0,8), this, this.getCommandID(bombTypeNames[0]), "Swap bomb type to " + bombNames[0] + ". " + bombNames[i] + " is selected.", params );
			}
		}
		
	}

	bool hasMat = woodCount >= woodPrice && stoneCount >= stonePrice && goldCount >= goldPrice;
	if (!this.hasTag("upgraded"))
	{
		if (hasMat)
			caller.CreateGenericButton( 15, Vec2f(8,0), this, this.getCommandID("upgrade"), "Upgrade Bomber", params );
		else if (!hasMat)
		{
			CButton@ upgradeBtn = caller.CreateGenericButton( 15, Vec2f(8, 0), this, 0, "Upgrade Bomber Requers: " + woodPrice + " Wood, " + stonePrice + " Stone, " + goldPrice + " Gold." );
		if (upgradeBtn !is null) { upgradeBtn.SetEnabled( false );}
		}
	}
	if (!this.hasTag("owned"))
	{
		caller.CreateGenericButton( 0, Vec2f(-8,0), this, this.getCommandID("own"), "Set this bomber as yours.", params );
	}
	
	if (caller.getPlayer().getUsername() == owner && this.hasTag("owned"))
	{
		CBlob@ flyer = getAttached(this,"FLYER");
		if (flyer !is null && flyer.isAttached())
		{
			caller.CreateGenericButton( 1, Vec2f(-8,0), this, this.getCommandID("kick"), "Kick", params );
		}
		else if (this.hasTag("locked"))
		{
			caller.CreateGenericButton( 1, Vec2f(-8,0), this, this.getCommandID("unlock"), "Unlock", params );
		}
		else
		{
			caller.CreateGenericButton( 0, Vec2f(-8,0), this, this.getCommandID("lock"), "Lock", params );
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	BomberInfo@ bomber;
	if (!this.get( "bomberInfo", @bomber )) {
		return;
	}
	CPlayer@ player;
	CBlob@ blob = getBlobByNetworkID( params.read_netid() );
	if (blob !is null) @player = blob.getPlayer();
	
    for (uint i = 0; i < bombTypeNames.length; i++)
    {
        if (cmd == this.getCommandID(bombTypeNames[i]))
        {
            bomber.bomb_type = i;
            break;
        }
    }
	if (cmd == this.getCommandID("upgrade"))
	{
		CSprite@ sprite = this.getSprite();
		InitLayers(sprite, "UpgradedBomber.png");
		this.getSprite().PlaySound("/Construct.ogg"); 
		blob.TakeBlob("mat_wood", woodPrice);
		blob.TakeBlob("mat_stone", stonePrice);
		blob.TakeBlob("mat_gold", goldPrice);
		/*sprite.RemoveScript("Wooden.as");
		*sprite.AddScript("Stone.as");
		*this.RemoveScript("Wooden.as");
		*this.AddScript("Stone.as");*/
		this.server_SetHealth(20.0f);
		this.Tag("upgraded");
	}
	if (cmd == this.getCommandID("lock"))
	{
		AttachmentPoint@ flyer = getFlyerPoint(this.getAttachments());
		flyer.offset = Vec2f(100000,100000);
		this.Tag("locked");
	}
	if (cmd == this.getCommandID("kick"))
	{
		CBlob@ flyer = getAttached(this,"FLYER");
		if (flyer !is null)
			flyer.server_DetachFrom(this);
	}
	if (cmd == this.getCommandID("unlock"))
	{
		AttachmentPoint@ flyer = getFlyerPoint(this.getAttachments());
		flyer.offset = Vec2f(0, -2);
		this.Untag("locked");
	}
	if (cmd == this.getCommandID("own"))
	{
		if (player !is null) this.set_string("owner", player.getUsername()); 
		this.Tag("owned");
	}
}

void InitLayers(CSprite@ this, string spriteName)
{
	CSpriteLayer@ balloonToRem = this.getSpriteLayer( "balloon" );
	CSpriteLayer@ backgroundToRem = this.getSpriteLayer( "background" );
	CSpriteLayer@ burnerToRem = this.getSpriteLayer( "burner" );
	if (balloonToRem !is null)
		this.RemoveSpriteLayer("balloon");
	if (backgroundToRem !is null)
		this.RemoveSpriteLayer("background");
	if (burnerToRem !is null)
		this.RemoveSpriteLayer("burner");

	CSpriteLayer@ balloon = this.addSpriteLayer( "balloon", spriteName, 48, 64 );
	if (balloon !is null)
	{
		balloon.addAnimation("default",0,false);
		int[] frames = { 0, 2, 3 };
		balloon.animation.AddFrames(frames);
		balloon.SetRelativeZ(1.0f);
		balloon.SetOffset( Vec2f(0.0f, -26.0f) );
	}
	
	CSpriteLayer@ background = this.addSpriteLayer( "background", spriteName, 32, 16 );
	if (background !is null)
	{
		background.addAnimation("default",0,false);
		int[] frames = { 3 };
		background.animation.AddFrames(frames);
		background.SetRelativeZ(-5.0f);
		background.SetOffset( Vec2f(0.0f, -5.0f) );
	}
	
	CSpriteLayer@ burner = this.addSpriteLayer( "burner", spriteName, 8, 16 );
	if (burner !is null)
	{
		{
			Animation@ a = burner.addAnimation("default",3,true);
			int[] frames = { 41, 42, 43 };
			a.AddFrames(frames);
		}
		{
			Animation@ a = burner.addAnimation("up",3,true);
			int[] frames = { 38, 39, 40 };
			a.AddFrames(frames);
		}
		{
			Animation@ a = burner.addAnimation("down",3,true);
			int[] frames = { 44, 45, 44, 46 };
			a.AddFrames(frames);
		}
		burner.SetRelativeZ(1.5f);
		burner.SetOffset( Vec2f(0.0f, -26.0f) );
	}
}

AttachmentPoint@ getFlyerPoint(CAttachment@ this)
{
	return this.getAttachmentPointByName("FLYER");
}