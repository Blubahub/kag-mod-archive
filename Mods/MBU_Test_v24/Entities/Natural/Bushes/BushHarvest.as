#include "EquipCommon.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("harvest_herb");
	this.addCommandID("harvest_hemp");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.getDistanceTo(caller) < 64){
		if(hasSharpTool(caller)){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			caller.CreateGenericButton(15, Vec2f(-4,0), this, this.getCommandID("harvest_herb"), "Harvest Herbs", params);
			
			caller.CreateGenericButton(21, Vec2f(4,0), this, this.getCommandID("harvest_hemp"), "Harvest Hemp", params);
		} else {
			CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("harvest_herb"), "Harvest: you need something sharp to be held or equiped");
			if(button !is null)button.SetEnabled(false);
		}
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("harvest_herb"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(hasSharpTool(caller)){
				if(!this.hasTag("harvested"))
				if(getNet().isServer()){
					caller.server_PutInInventory(server_CreateBlob("herb", -1, this.getPosition()));
					this.Tag("harvested");
					this.server_Die();
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("harvest_hemp"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(hasSharpTool(caller)){
				if(!this.hasTag("harvested"))
				if(getNet().isServer()){
					Material::createFor(caller, "mat_hemp", 10);
					this.Tag("harvested");
					this.server_Die();
				}
			}
		}
	}
}