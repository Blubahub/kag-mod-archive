#include "ContainerCommon";

void onInit( CBlob@ this )
{
	this.addCommandID("useitem");
	
	this.set_u8("max_amount", 30);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(22, Vec2f_zero, this, this.getCommandID("useitem"), "Drink Soup", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("useitem"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
            if(getNet().isServer()){
				applyEffects(this, caller);
				this.server_Die();
			}
		}
		
	}
}
