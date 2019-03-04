void onInit( CBlob@ this )
{
	this.addCommandID("usesword");
	this.Tag("gold");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("usesword"), "Become immortal!", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("usesword"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			this.getSprite().PlaySound("/party_join", 0.9f, 1.00f);
			if(getNet().isServer()){
				CBlob @statue = server_CreateBlob("goldenstatue", caller.getTeamNum(), this.getPosition());
				if(statue !is null)if(caller.getPlayer() !is null)statue.set_string("name",caller.getPlayer().getUsername());
			}
			caller.Tag("goldenstatue");
			caller.server_Die();
			this.server_Die();
		}
		
	}
}
