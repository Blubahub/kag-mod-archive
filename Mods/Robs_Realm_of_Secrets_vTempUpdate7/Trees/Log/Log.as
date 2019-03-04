#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Hitters.as";

//are builders the only ones that can finish construction?
const bool builder_only = false;

const bool dangerous_logs = false;

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(4);
	this.getBlob().server_setTeamNum(-1);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.getBlob().server_SetTimeToDie(60 * 5); // timeout

}

void onInit( CBlob@ this ){
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 4));
	this.set_string("shop description", "Carve");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$award$", "Ward.png", Vec2f(8, 17), 25);
	AddIconToken("$cage$", "Cage.png", Vec2f(16, 16), 0);
	AddIconToken("$astaff$", "Staff.png", Vec2f(16, 16), 0);
	AddIconToken("$wooden_golem_icon$", "WoodenGolemNoCore.png", Vec2f(32, 32), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "arrows", "Carve log into arrows.");
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ward", "$award$", "ward", "Carve log into a ward.");
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Cage", "$cage$", "cage", "Carve log into a cage.");
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Campfire", "$fireplace$", "fireplace", "Make a campfire.");
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Wooden Golem", "$wooden_golem_icon$", "wooden_golem", "A defensive mechanical unit.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this)
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		if(isServer){
			caller.DropCarried();
			if(name == "arrows"){
				CBlob@ item = server_CreateBlob("mat_arrows", -1, caller.getPosition());
				caller.server_Pickup(item);
			}
			
			if(name == "ward"){
				CBlob@ item = server_CreateBlob("ward", caller.getTeamNum(), caller.getPosition());
				caller.server_Pickup(item);
			}
			
			if(name == "cage"){
				CBlob@ item = server_CreateBlob("cage", caller.getTeamNum(), caller.getPosition());
				caller.server_Pickup(item);
			}
			
			if(name == "staff"){
				CBlob@ item = server_CreateBlob("staff", caller.getTeamNum(), caller.getPosition());
				caller.server_Pickup(item);
			}
			
			if(name == "fireplace"){
				CBlob@ item = server_CreateBlob("fireplace", caller.getTeamNum(), caller.getPosition());
			}
			
			if(name == "wooden_golem"){
				CBlob@ item = server_CreateBlob("wooden_golem", caller.getTeamNum(), caller.getPosition());
				caller.server_Pickup(item);
			}
			
			this.server_Die();

		}
	}
}


//collide with vehicles and structures	- hit stuff if thrown

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool thrown = false;
	CPlayer @p = this.getDamageOwnerPlayer();
	CPlayer @bp = blob.getPlayer();
	if (p !is null && bp !is null && p.getTeamNum() != bp.getTeamNum())
	{
		thrown = true;
	}
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle")) ||
	        (dangerous_logs && this.hasTag("thrown") && blob.hasTag("flesh") && thrown)); // boat
}



void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (dangerous_logs)
	{
		this.Tag("thrown");
		this.SetDamageOwnerPlayer(detached.getPlayer());
		//	printf("thrown");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (dangerous_logs && this.hasTag("thrown"))
	{
		if (blob is null || !blob.hasTag("flesh"))
		{
			return;

		}

		CPlayer@ player = this.getDamageOwnerPlayer();
		if (player !is null && player.getTeamNum() != blob.getTeamNum())
		{
			const f32 dmg = this.getShape().vellen * 0.25f;
			if (dmg > 1.5f)
			{
				//	printf("un thrown " + dmg);
				this.server_Hit(blob, this.getPosition(), this.getVelocity(), dmg, Hitters::flying, false);  // server_Hit() is server-side only
			}
			this.Untag("thrown");
		}
	}
}
