void onInit( CBlob@ this )
{
	this.addCommandID("use");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("use"), "Gain corruption.", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			caller.set_s16("corruption",caller.get_s16("corruption")+(100-XORRandom(20)));
			this.server_Die();
		}
		
	}
}
