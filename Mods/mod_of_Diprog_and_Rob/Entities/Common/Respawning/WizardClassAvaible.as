#include "StandardRespawnCommand.as"

const string req_class = "required class";

const int soulsNeed = 1;

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	AddIconToken( "$changetowizard$", "ChangeToWizard.png", Vec2f(16,16), 0 );
	
	if(!this.exists(req_class))
		return;
	
	string cfg = this.get_string(req_class);
	
	const u16 soulorbsCount = caller.getBlobCount("soulorb");
	const u16 soulstonesCount = caller.getBlobCount("soulstone");

    if (canChangeClass(this,caller) && caller.getName() != cfg && (soulorbsCount >= soulsNeed ||  soulstonesCount >= soulsNeed)) {
        CBitStream params;
        write_classchange(params, caller.getNetworkID(), cfg);
        caller.CreateGenericButton( "$changetowizard$", Vec2f(0,-1), this, SpawnCmd::changeClass, "Transformation into a Wizard", params );
    }
    else if (canChangeClass(this,caller) && caller.getName() != cfg) {
        CButton@ button = caller.CreateGenericButton( "$changetowizard$", Vec2f(0,-1), this, 0, "Transformation into a Wizard: Requires Soul Stone" );
		if (button !is null) button.SetEnabled( false );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	onRespawnCommand( this, cmd, params );

}

