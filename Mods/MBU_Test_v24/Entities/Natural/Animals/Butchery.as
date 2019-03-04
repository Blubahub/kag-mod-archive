#include "EquipCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("cut_apart");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.hasTag("dead")){
		if(hasSharpTool(caller)){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("cut_apart"), "Butcher", params);
		} else {
			CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("cut_apart"), "Butcher: you need something sharp to be held or equiped");
			if(button !is null)button.SetEnabled(false);
		}
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("cut_apart"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(hasSharpTool(caller)){
				if(!this.hasTag("butchered"))
				if(getNet().isServer()){
					caller.server_PutInInventory(server_CreateBlob("leather", -1, this.getPosition()));
					caller.server_PutInInventory(server_CreateBlob("steak", -1, this.getPosition()));
					this.Tag("butchered");
					this.server_Die();
				}
			}
		}
	}
}