
void onInit(CBlob@ this)
{
	this.addCommandID("use");
}


void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "stub_hook"){
						server_CreateBlob("grapple", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "stick"){
						server_CreateBlob("bow", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
				}
			}
		}
	}
}