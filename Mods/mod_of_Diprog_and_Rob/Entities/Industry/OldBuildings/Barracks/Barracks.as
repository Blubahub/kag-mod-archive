// Scripts by Diprog. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.
#include "BarracksRespawnCommand.as"
void onInit( CBlob@ this )
{	 
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	InitBarracksClasses( this );

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
}


void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    // button for runner
    // create menu for class change
    if (canChangeClass( this, caller ) && caller.getTeamNum() == this.getTeamNum())
    {
        CBitStream params;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton( "$change_class$", Vec2f(0,0), this, SpawnCmd::buildMenu, "Swap Class", params );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    onBarracksRespawnCommand( this, cmd, params );
}
