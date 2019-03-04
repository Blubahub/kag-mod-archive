#include "EquipCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("harvest_flower");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.getDistanceTo(caller) < 64){
		if(hasSharpTool(caller)){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("harvest_flower"), "Harvest Flowers", params);
		} else {
			CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("harvest_flower"), "Harvest: you need something sharp to be held or equiped");
			if(button !is null)button.SetEnabled(false);
		}
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("harvest_flower"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(hasSharpTool(caller)){
				if(!this.hasTag("harvested"))
				if(getNet().isServer()){
					caller.server_PutInInventory(server_CreateBlob("flower_bundle", -1, this.getPosition()));
					this.Tag("harvested");
					this.server_Die();
				}
			}
		}
	}
}