// Factory

#include "ProductionCommon.as";

void onInit( CBlob@ this )
{
	this.addCommandID("launch");
	this.set_TileType("background tile", CMap::tile_wood_back);	
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (!isProducing(this))
	{
		caller.CreateGenericButton( 12, Vec2f(-14.0,3.0), this, this.getCommandID("launch"), "Start Producing.", params );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("launch"))
		addProductionItem( this, "Bomber", "$Bomber$", "bomber", "", 200, false, 1);
}