// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "MakeSeed.as";
#include "modname.as";
//#include "BuilderHittable.as";
f32 crusherpos = 0.0f;

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ crusher = this.addSpriteLayer("crusher", this.getFilename() , 8, 8, blob.getTeamNum(), blob.getSkinNum());

	if (crusher !is null)
	{
		Animation@ anim = crusher.addAnimation("default", 2, true);
		anim.AddFrame(30);
		crusher.SetOffset(Vec2f(0, 0));
		crusher.SetRelativeZ(-2);
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("crusher") !is null){
		this.getSpriteLayer("crusher").SetOffset(Vec2f(0, Maths::Cos(crusherpos)*3-2));
		crusherpos+=0.2f;
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Upgrade");
	this.set_u8("shop icon", 25);
	//this.Tag("builder always hit");

	{
		ShopItem@ s = addShopItem(this, "Upgrade drill", "$UDRILL$", "upgradeddrill", "Upgrade Drill!", true);
		AddRequirement(s.requirements, "blob", "drill", "Drill", 1);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
		AddRequirement(s.requirements, "blob", "mat_masterstone", "Master Stone", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Upgrade saw", "$USAW$", "upgradedsaw", "Upgrade Mill Saw!", true);
		AddRequirement(s.requirements, "blob", "saw", "Mill Saw", 1);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_masterstone", "Master Stone", 120);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
	}
}