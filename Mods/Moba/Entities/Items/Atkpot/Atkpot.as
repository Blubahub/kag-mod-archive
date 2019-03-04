// Lantern script

void onInit(CBlob@ this)
{
	
	this.addCommandID("atkup");
	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!caller.isOverlapping(this))
		return;
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(0, 1), this, this.getCommandID("atkup"), "Change class", params);
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	u16 callerID = params.read_u16();
	CBlob@ caller = getBlobByNetworkID(callerID);
	
	if(caller !is null && cmd == this.getCommandID("atkup"))
	{
		if(caller.get_u8("atk") < 5 && caller.getName() == "knight")
		{
			caller.set_u8("atk", caller.get_u8("atk") + 1);
			this.server_Die();
		}
	}
}