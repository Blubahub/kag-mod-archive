void onInit(CBlob@ this)
{
	this.addCommandID("cut_apart");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.hasTag("dead"))
	if(caller.getCarriedBlob() !is null)
	if(caller.getCarriedBlob().getName() == "crude_knife"){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("cut_apart"), "Butcher", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("cut_apart"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null)
			if(hold.getName() == "crude_knife"){
				if(getNet().isServer()){
					server_CreateBlob("leather", -1, this.getPosition());
					this.server_Die();
				}
			}
		}
	}
}