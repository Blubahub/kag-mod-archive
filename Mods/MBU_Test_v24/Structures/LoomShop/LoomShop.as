// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "HumanoidClasses.as";

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Weave and Sow");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));

	
	AddIconToken("$leather$", "Leather.png", Vec2f(10, 9), 0);
	AddIconToken("$mat_hemp$", "Hemp.png", Vec2f(16, 16), 1);
	AddIconToken("$cloth$", "Cloth.png", Vec2f(16, 8), 0);
	
	
	AddIconToken("$backpack_icon$", "backpack_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Backpack", "$backpack_icon$", "backpack", "A larger sack worn on your back.", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 2);
	}
	AddIconToken("$leatherpants_icon$", "leather_pants_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Leather Pants", "$leatherpants_icon$", "leather_pants", "Crude Armour.\n+2 defense to legs", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 2);
	}
	AddIconToken("$leathershirt_icon$", "leather_shirt_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Leather Shirt", "$leathershirt_icon$", "leather_shirt", "Crude Armour.\n+2 Defense to arms and torso", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 4);
	}
	
	AddIconToken("$cloth$", "Cloth.png", Vec2f(16, 8), 0);
	{
		ShopItem@ s = addShopItem(this, "Weave Cloth", "$cloth$", "cloth", "A light dyeable fabric.", false);
		AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 50);
	}
	AddIconToken("$cloth_pants_icon$", "cloth_pants_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Cloth Pants", "$cloth_pants_icon$", "cloth_pants", "Light weight clothes for keeping the junk hidden.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
	}
	AddIconToken("$cloth_shirt_icon$", "cloth_shirt_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Cloth Shirt", "$cloth_shirt_icon$", "cloth_shirt", "Light weight clothes for keeping them tiddies hidden.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 2);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", this.isOverlapping(caller));
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}

		}
	}
}

void onInit(CSprite @this){
	this.RemoveSpriteLayer("wheel");
	CSpriteLayer@ backarm = this.addSpriteLayer("wheel", "Loom.png" , 21, 21, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		backarm.SetRelativeZ(-0.1);
		backarm.SetOffset(Vec2f(0,5));
	}
}


void onTick(CSprite @this){

	if(this.getSpriteLayer("wheel") !is null){
		this.getSpriteLayer("wheel").RotateBy(10,Vec2f(0,0));
	}

}