
void onInit( CRules@ this )
{
	this.addCommandID("swap classes");
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (this.getCommandID("swap classes") == cmd)
	{
		u16 playerID = params.read_u16();
		string classConfig = params.read_string();
		
		CPlayer@ player = getPlayerByNetworkId(playerID);
		if ( player is null )
			return;
		
		player.set_string("class config", classConfig);
		print("You will now respawn as " + classConfig);
	}
}