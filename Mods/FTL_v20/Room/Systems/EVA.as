
void onInit(CBlob @ this){
	this.set_u8("MaxLevel",0);
	
	this.addCommandID("equip");
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.isOverlapping(caller) && caller.get_u16("air_tank") < 1250 && this.getTeamNum() == caller.getTeamNum()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("equip"), "Equip Space Suit: 20 Scrap", params);
		button.SetEnabled(caller.getInventory().getCount("mat_scrap") >= 20);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("equip"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(caller.getInventory().getCount("mat_scrap") >= 20){
			
				if(getNet().isServer()){
					caller.getInventory().server_RemoveItems("mat_scrap", 20);
					caller.Tag("space_suit");
					caller.set_u16("air_tank",1500);
					caller.Sync("space_suit",true);
					caller.Sync("air_tank",true);
				}
				caller.Tag("space_suit");
				caller.set_u16("air_tank",1500);
			}
		}
	}
}