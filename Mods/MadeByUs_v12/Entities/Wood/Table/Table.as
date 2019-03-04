
#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";


void onInit(CBlob @ this)
{

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Table");
	this.set_u8("shop icon", 15);
	
	
	AddIconToken("$sack_icon$", "Sack.png", Vec2f(7, 9), 0);
	{
		ShopItem@ s = addShopItem(this, "Sack", "$sack_icon$", "sack", "A crude sack for holding your items.", false);
		AddRequirement(s.requirements, "blob", "flax", "Flax", 1);
	}
	AddIconToken("$backpack_icon$", "Backpack.png", Vec2f(10, 9), 0);
	{
		ShopItem@ s = addShopItem(this, "Backpack", "$backpack_icon$", "backpack", "A larger sack worn on your back.", false);
		AddRequirement(s.requirements, "blob", "flax", "Flax", 4);
	}
	AddIconToken("$barrel_icon$", "Barrel.png", Vec2f(16, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Barrel", "$barrel_icon$", "barrel", "A barrel for storing items.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "metalbar", "Metal", 1);
	}
	
	
	
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
					if(attach.getAttachedBlob("BED") !is null)
					this.server_DetachFrom(attach.getAttachedBlob("BED"));
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold is null){
					
						if(!this.isAttachedTo(caller)){
							this.server_AttachTo(caller, "BED");
						} else {
							this.server_DetachFrom(caller);
						}
					
					} else {
						if(hold.getName() == "humanoid"){
							caller.DropCarried();
							this.server_AttachTo(hold, "BED");
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