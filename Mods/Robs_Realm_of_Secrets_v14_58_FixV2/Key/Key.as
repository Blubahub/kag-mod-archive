void onInit(CBlob@ this)
{
	this.addCommandID("use");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this && caller.getTeamNum() != this.getTeamNum() && !caller.hasTag("key"+this.getTeamNum())){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(3, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("use"))
		{
			caller.Tag("key"+this.getTeamNum());
			this.server_Die();
		}
	}
}