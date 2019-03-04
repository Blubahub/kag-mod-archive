
#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "HumanoidCommon.as";

void onInit(CBlob @ this)
{

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Table");
	this.set_u8("shop icon", 15);
	
	AddIconToken("$steak_icon$", "Food.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Steak", "$steak_icon$", "cooked_steak", "Burnt on the outside, raw on the inside.", false);
		AddRequirement(s.requirements, "blob", "steak", "Raw Steak", 1);
	}
	AddIconToken("$bread_icon$", "Food.png", Vec2f(16, 16), 4);
	{
		ShopItem@ s = addShopItem(this, "Bread", "$bread_icon$", "bread", "Freshly baked bread.", false);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
	}
	AddIconToken("$herb_icon$", "Herb.png", Vec2f(14, 9), 0);
	{
		ShopItem@ s = addShopItem(this, "Herbs", "$herb_icon$", "herb", "A collection of herbs, you hope.", false);
		AddRequirement(s.requirements, "blob", "flower_bundle", "Flower Bundle", 1);
	}
	
	
	this.getSprite().SetZ(-50.0f);
	
	this.addCommandID("lie");
	
	this.Tag("medium weight");
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
		
		CButton@ button = caller.CreateGenericButton(10, Vec2f(0,0), this, this.getCommandID("surgery"), "Perform Surgery", params);
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