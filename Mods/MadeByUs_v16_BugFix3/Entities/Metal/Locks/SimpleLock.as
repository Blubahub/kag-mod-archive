void onInit(CBlob@ this)
{
	this.set_s16("password",XORRandom(10));
	
	this.addCommandID("imprint");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is null && caller.getCarriedBlob().getName() == "simplekey"){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(2, Vec2f(0,0), this, this.getCommandID("imprint"), "Match Key", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("imprint"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "simplekey"){
						this.set_s16("password",hold.get_s16("password"));
						this.Sync("password",true);
					}
				}
			}
		}
	}
}