void onInit(CBlob@ this)
{
	this.addCommandID("cut_apart");
	this.addCommandID("pluck");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.hasTag("dead"))
	if(caller.getCarriedBlob() !is null){
		if(caller.getCarriedBlob().hasTag("sharp")){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("cut_apart"), "Butcher", params);
		}
	} else {
		//CBitStream params;
		//params.write_u16(caller.getNetworkID());
		
		//CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("pluck"), "Pluck", params);
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
			if(hold.hasTag("sharp")){
				if(!this.hasTag("butchered"))
				if(getNet().isServer()){
					server_CreateBlob("leather", -1, this.getPosition());
					server_CreateBlob("steak", -1, this.getPosition());
					this.Tag("butchered");
					this.server_Die();
				}
			}
		}
	}
	if (cmd == this.getCommandID("pluck"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.getCarriedBlob() is null){
				if(getNet().isServer()){
					CBlob @feather = server_CreateBlob("feather", -1, this.getPosition());
					caller.server_Pickup(feather);
				}
			}
		}
	}
}