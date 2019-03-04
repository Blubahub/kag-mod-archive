void onInit(CBlob@ this)
{
	this.set_s16("password",XORRandom(10));
	
	this.addCommandID("clone");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is null && caller.getCarriedBlob().getName() == "metal_bar"){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("clone"), "Clone", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("clone"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "metal_bar"){
						CBlob @newkey = server_CreateBlob("simplekey", -1, this.getPosition());
						hold.server_Die();
						newkey.set_s16("password",this.get_s16("password"));
						newkey.Sync("password",true);
						caller.server_Pickup(newkey);
					}
				}
			}
		}
	}
}