// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "MakeSeed.as";
#include "modname.as";
//#include "BuilderHittable.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ first = this.addSpriteLayer("firstgear", this.getFilename() , 11, 11, blob.getTeamNum(), blob.getSkinNum());
	CSpriteLayer@ second = this.addSpriteLayer("secondgear", this.getFilename() , 11, 11, blob.getTeamNum(), blob.getSkinNum());
	CSpriteLayer@ fier = this.addSpriteLayer("fire", this.getFilename() , 8, 8, blob.getTeamNum(), blob.getSkinNum());

	if (first !is null)
	{
		Animation@ anim = first.addAnimation("default", 0, false);
		anim.AddFrame(12);
		first.SetOffset(Vec2f(-5, 4));
		first.SetAnimation("default");
		first.SetRelativeZ(-1);
	}
	
	if (second !is null)
	{
		Animation@ anim = second.addAnimation("default", 0, false);
		anim.AddFrame(12);
		second.SetOffset(Vec2f(5, 4));
		second.SetAnimation("default");
		second.SetRelativeZ(-2);
		second.RotateBy(45, Vec2f(0.0f,-0.0f));
	}
	
	if (fier !is null)
	{
		Animation@ anim = fier.addAnimation("default", 2, true);
		int[] frames = {20,21,22,23};
		fier.animation.AddFrames(frames);
		fier.SetOffset(Vec2f(0, 7));
		fier.SetAnimation("default");
		fier.SetRelativeZ(2);
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("firstgear") !is null){
		this.getSpriteLayer("firstgear").RotateBy(-5, Vec2f(0.0f,-0.0f));
	}
	if(this.getSpriteLayer("secondgear") !is null){
		this.getSpriteLayer("secondgear").RotateBy(5, Vec2f(0.0f,-0.0f));
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Mix");
	this.set_u8("shop icon", 25);
	//this.Tag("builder always hit");

	{
		ShopItem@ s = addShopItem(this, "Mix Gold", "$MIXEDGOLD$", "mat_mixedgold", "Mix 15 gold and 15 blue gold.", true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 15);
		AddRequirement(s.requirements, "blob", "mat_bluegold", "Blue Gold", 15);
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
		
		string name = params.read_string();
		{
		    if(name.findFirst("mat_") != -1)
			{
				CBlob@ callerBlob = getBlobByNetworkID(caller);
				CInventory@ inv = callerBlob.getInventory();
				CBlob@ mat = server_CreateBlob(name);
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(40);
					if (!callerBlob.server_PutInInventory(mat))
					{
					mat.setPosition(callerBlob.getPosition());
					}
				}
			}
		}
	}
}