#include "StandardRespawnCommand.as"

const string req_class = "required class";

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.exists(req_class))
		return;
	
	string cfg = this.get_string(req_class);
    if (canChangeClass(this,caller) && caller.getName() != cfg) {
        CBitStream params;
        write_classchange(params, caller.getNetworkID(), cfg);
        caller.CreateGenericButton( "$change_class$", Vec2f(0,-16), this, SpawnCmd::changeClass, "Swap Class", params );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	onRespawnCommand( this, cmd, params );
}

