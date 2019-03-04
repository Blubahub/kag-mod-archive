
#include "RunnerCommon.as";

#include "Requirements.as";
#include "ShopCommon.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	this.Tag("flesh");
	this.Tag("player");
	
	this.Tag("isfacingleft");
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Buy Explosives");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$mat_bombs$", "mat_bombs", "Ka-ching, boom boom!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb arrow", "$mat_bombarrows$", "mat_bombarrows", "Ka-ching, woosh, boom!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
}

void onTick(CBlob@ this)
{

	if (this.hasTag("dead"))
		return;

	
	if(XORRandom(100) == 0){
		if(XORRandom(2) == 0)this.Tag("isfacingleft");
		else this.Untag("isfacingleft");
	}
	
	RunnerMoveVars@ moveVars;
	if(this.get("moveVars", @moveVars))
	{
		if(this.get_u8("type") == 0 || this.get_u8("type") == 1){
			moveVars.walkFactor = 0.5f;
			moveVars.jumpFactor = 0.5f;
		}
		if(this.get_u8("type") == 2 || this.get_u8("type") == 3){
			moveVars.walkFactor = 0.25f;
			moveVars.jumpFactor = 0.25f;
		}
	}
	
	if(this.hasTag("isfacingleft"))this.setAimPos(this.getPosition() + Vec2f(-16,0));
	else this.setAimPos(this.getPosition() + Vec2f(16,0));
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 80.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b.getTeamNum() == 0){
					if(b.hasTag("player") && !b.hasTag("dead") && b.getName() != "villager"){
						this.setAimPos(b.getPosition());
					}
				}
			}
		}
	}
		
	if (!getNet().isServer()) return; //---------------------SERVER ONLY
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}



void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}
