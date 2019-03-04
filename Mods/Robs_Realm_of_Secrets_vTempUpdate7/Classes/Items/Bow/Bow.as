#include "ChangeClass.as";

void onInit( CBlob@ this )
{
	this.addCommandID("useitem");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("useitem"), "Become an Archer.", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("useitem"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
            CBlob@ blob = ChangeClass(caller,"archer",caller.getPosition(),caller.getTeamNum());
		}
		
	}
}