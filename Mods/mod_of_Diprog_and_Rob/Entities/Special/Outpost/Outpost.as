#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

f32 startHealth;
f32 healthToDie = 8.0f;
int repairCost = 200;
bool onlyOneHit = true;

const s32 cost_bomb = 20;
const s32 cost_arrows = 15;

void onInit( CBlob@ this )
{
	AddIconToken( "$Medkit$", "Medkit.png", Vec2f(16,16), 0 );
		
	startHealth = this.getHealth();
	this.addCommandID("repair");
	this.Tag("respawn");
    this.Tag("heavy weight");
	InitClasses( this );
	InitRespawnCommand( this );				
	this.Tag("change class store inventory");	
	
	//repairing
	this.set_u16("repair_costs", 500);
	this.set_string("repair_mat_cfg", "mat_wood");
	this.set_string("repair_mat_name", "Wood");
	this.set_Vec2f("repair_offset", Vec2f(6,0));
	
	this.getSprite().SetAnimation("default");
	
	this.set_Vec2f("shop offset", Vec2f(-6, 0));
	this.set_Vec2f("shop menu size", Vec2f(4,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem( this, "Bomb", "$bomb$", "mat_bombs", descriptions[1], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_bomb );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Arrows", "$mat_arrows$", "mat_arrows", descriptions[2], true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_arrows );
	}
	
	{	 
		ShopItem@ s = addShopItem( this, "McDonald's Burger", "$food$", "food", "Buy it and throw in teammates.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	
	{	 
		ShopItem@ s = addShopItem( this, "Medkit", "$Medkit$", "medkit", "Unpack hearts.", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 15 );
	}
	
}

void onTick( CBlob@ this )
{	
	if (this.getHealth() <= healthToDie)
	{
		this.Untag("respawn");
		this.server_setTeamNum(255);
		this.getSprite().SetAnimation("dead");
		
		
		if (onlyOneHit)
		{
			this.getSprite().PlaySound("/catapult_destroy.ogg"); 
			onlyOneHit = false;
		}
	}
	this.getSprite().SetZ(-25);
    
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{	
	if ( blob.getRadius() >= this.getRadius() || (blob.hasTag("blocks water") &&  blob.getRadius() < this.getRadius()))
	{
		return true;
	}
	else return false;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	u16 woodCount = caller.getBlobCount("mat_wood");
	
    if (canChangeClass( this, caller ) && caller.getTeamNum() == this.getTeamNum())
    {
        CBitStream params;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton( "$change_class$", Vec2f(0,0), this, SpawnCmd::buildMenu, "Swap Class", params );
    }
	if (this.getHealth() > healthToDie) this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
	else if (this.getHealth() <= healthToDie && woodCount >= repairCost)
	{
		caller.CreateGenericButton( 15, Vec2f(6,0), this, this.getCommandID("repair"), "Repair Outpost" , params );
	}
	else if (this.getHealth() <= healthToDie && woodCount < repairCost)
	{
		CButton@ repairBtn = caller.CreateGenericButton( 15, Vec2f(6,0), this, 0, "Repair Outpost: Requires "+repairCost+" Wood" );
		if (repairBtn !is null) { repairBtn.SetEnabled( false );}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ blob )
{
	if (this.getTeamNum() == 255 || this.getTeamNum() == blob.getTeamNum())
	{
		return true;
	}
	else return false;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    onRespawnCommand( this, cmd, params );
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
	else if (cmd == this.getCommandID("repair"))
	{
		CBlob@ newOutpost; 
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		this.getSprite().PlaySound("/Construct.ogg"); 
		this.getSprite().Gib();
		
		if(getNet().isServer()){
			blob.TakeBlob( "mat_wood", repairCost );
			this.server_SetHealth(startHealth);
			onlyOneHit = true;
			this.server_Die();
			@newOutpost = server_CreateBlob( "outpost", blob.getTeamNum(), this.getPosition()); 


		}

	}
}




