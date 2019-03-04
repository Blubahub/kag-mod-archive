#include "CrateCommon.as"

void onInit(CBlob @this){

	this.Tag("inventory");
	
	this.Tag("medium weight");

	this.set_u8("equip_slot", 4);
	
	this.addCommandID("getin");
	this.addCommandID("getout");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getInventory().getItemsCount() > 0 && this.getInventory().getItem(0) is caller)    // fix - iterate if more stuff in crate
	{
	    CBitStream params;
	    params.write_u16( caller.getNetworkID() );
	    caller.CreateGenericButton( 6, Vec2f(0,-8), this, this.getCommandID("getout"), "Get out", params );
	}
	else if (this.getInventory().getItemsCount() == 0 && caller.getCarriedBlob() is null)
	{
	    CBitStream params;
	    params.write_u16( caller.getNetworkID() );
	    caller.CreateGenericButton( 4, Vec2f(0,-8), this, this.getCommandID("getin"), "Get inside", params );
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("getin"))
	{
	    CBlob @caller = getBlobByNetworkID( params.read_u16() );

	    if (caller !is null) {
	        this.server_PutInInventory( caller );
	    }
	} else if (cmd == this.getCommandID("getout"))
	{
	    CBlob @caller = getBlobByNetworkID( params.read_u16() );

	    if (caller !is null) {
	        this.server_PutOutInventory( caller );
	    }
	}
}