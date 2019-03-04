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
			if(hold !is null)if(getNet().isServer()){
				if(hold.getName() == "wisp"){
					if(getNet().isServer())server_CreateBlob("caged_wisp", hold.getTeamNum(), this.getPosition());
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "chicken"){
					if(getNet().isServer())server_CreateBlob("caged_chicken", hold.getTeamNum(), this.getPosition());
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "slime" && !hold.hasTag("baby")){
					if(getNet().isServer())server_CreateBlob("caged_slime", hold.getTeamNum(), this.getPosition());
					hold.server_Die();
					this.server_Die();
				}
			}
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(this.getVelocity().x != 0)
	if(blob !is null)
	if(blob.getName() == "wisp"){
		if(getNet().isServer())server_CreateBlob("caged_wisp", blob.getTeamNum(), this.getPosition());
		blob.server_Die();
		this.server_Die();
	}
}