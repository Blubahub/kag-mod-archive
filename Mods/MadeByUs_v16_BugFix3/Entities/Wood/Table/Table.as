
#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "HumanoidCommon.as";

void onInit(CBlob @ this)
{

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Table");
	this.set_u8("shop icon", 15);
	
	AddIconToken("$leather$", "Leather.png", Vec2f(10, 9), 0);
	
	AddIconToken("$sack_icon$", "Sack.png", Vec2f(7, 9), 0);
	{
		ShopItem@ s = addShopItem(this, "Sack", "$sack_icon$", "sack", "A crude sack for holding your items.", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 1);
	}
	AddIconToken("$backpack_icon$", "Backpack.png", Vec2f(10, 9), 0);
	{
		ShopItem@ s = addShopItem(this, "Backpack", "$backpack_icon$", "backpack", "A larger sack worn on your back.", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 2);
	}
	AddIconToken("$barrel_icon$", "Barrel.png", Vec2f(16, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Barrel", "$barrel_icon$", "barrel", "A barrel for storing items.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal", 1);
	}
	
	AddIconToken("$door_icon$", "BigDoor.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Door", "$door_icon$", "big_door", "A door for when you need a bit of... privacy.\nLocks not included.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		//AddRequirement(s.requirements, "blob", "metalbar", "Metal", 1);
	}
	
	AddIconToken("$flaxshirt_icon$", "flax_shirt_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Leather Shirt", "$flaxshirt_icon$", "flax_shirt", "Keep them tiddies hidden.\n+1 Defense to arms and torso", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 4);
	}
	
	AddIconToken("$flaxpants_icon$", "flax_pants_icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Leather Pants", "$flaxpants_icon$", "flax_pants", "Keep the junk hidden.\n+1 defense to legs", false);
		AddRequirement(s.requirements, "blob", "leather", "Leather", 2);
	}
	
	AddIconToken("$ladder_icon$", "Ladder.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Ladder", "$ladder_icon$", "ladder", "A ladder for climbing.", false);
		AddRequirement(s.requirements, "blob", "stick", "Stick", 4);
	}
	
	this.getSprite().SetZ(-50.0f);
	
	this.addCommandID("lie");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(29, Vec2f(-8,0), this, this.getCommandID("lie"), "Lie Down", params);
	}
	
	this.set_bool("shop available", true);
	if(this.isAttachedToPoint("BED")){
		CAttachment@ attach = this.getAttachments();
		if(attach.getAttachedBlob("BED") !is null){
			this.set_bool("shop available", false);
		}
	}
	
	if(!this.get_bool("shop available")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("surgery"), "Perform Surgery", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		if(isServer){
		}
	}
	
	if (cmd == this.getCommandID("lie"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("BED") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("BED");
						if(attachedBlob.getName() == "humanoid")massSync(attachedBlob);
						this.server_DetachFrom(attachedBlob);
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold is null){
					
						if(!this.isAttachedTo(caller)){
							this.server_AttachTo(caller, "BED");
							if(caller.getName() == "humanoid")massSync(caller);
						} else {
							this.server_DetachFrom(caller);
							if(caller.getName() == "humanoid")massSync(caller);
						}
					
					} else {
						if(hold.getName() == "humanoid"){
							caller.DropCarried();
							this.server_AttachTo(hold, "BED");
							if(hold.getName() == "humanoid")massSync(hold);
						}
					}
				
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob){
	//if (blob.hasTag("player") && this.getTeamNum() == blob.getTeamNum())return false;
	return true;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.isAttachedToPoint("BED");
}