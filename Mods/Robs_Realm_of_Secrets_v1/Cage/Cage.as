void onInit(CBlob@ this)
{
	this.addCommandID("fill");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(24, Vec2f(0,0), this, this.getCommandID("fill"), "Capture a small creature.", params);
	button.SetEnabled(caller.getCarriedBlob() !is null);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("fill"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(hold.getName() == "wisp"){
					server_CreateBlob("caged_wisp", hold.getTeamNum(), this.getPosition());
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "chicken"){
					server_CreateBlob("caged_chicken", hold.getTeamNum(), this.getPosition());
					hold.server_Die();
					this.server_Die();
				}
			}
		}
	}
}