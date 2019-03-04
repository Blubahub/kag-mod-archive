#include "ChangeClass.as";

void onInit( CBlob@ this )
{
	this.addCommandID("useitem");
	this.set_string("boss","");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("useitem"), "Become corrupt and hateful.", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("useitem"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
            CBlob@ blob = ChangeClass(caller,"knight",caller.getPosition(),9);
			if(blob !is null)blob.set_u8("race",1);
			if(blob !is null)blob.set_string("boss",this.get_string("boss"));
			if(blob !is null)this.server_Die();
		}
		
	}
}
