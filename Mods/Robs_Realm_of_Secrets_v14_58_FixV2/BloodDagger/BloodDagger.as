#include "ChangeClass.as";
#include "Hitters.as";

void onInit( CBlob@ this )
{
	this.addCommandID("usesword");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("usesword"), "Damage yourself to get a heart", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("usesword"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
            if(getNet().isServer()){
				CBlob @heart = server_CreateBlob("heart", -1, this.getPosition());
				heart.Tag("dont_eat");
				caller.server_Hit(caller, this.getPosition(), Vec2f(0,1), 1.0f, Hitters::sword, false);
			}
		}
		
	}
}
