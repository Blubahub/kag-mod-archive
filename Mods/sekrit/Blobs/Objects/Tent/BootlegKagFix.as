
void onInit(CBlob@ this)
{
	this.addCommandID("LvlBtn");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// button for runner
	// create menu for class change
	if (caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$change_class$", Vec2f(10, 0), this, this.getCommandID("LvlBtn"), getTranslatedString("Level up [DEBUG]"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("LvlBtn"))
	{
		
		CRules@ rules = getRules();
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(rules.get_u8(caller.getTeamNum()+"TL") < 2)
		{
			rules.add_u8(caller.getTeamNum()+"TL",1);
			rules.Sync(caller.getTeamNum()+"TL",false);
		}
	}
}
