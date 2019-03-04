//Version 1
//Core rules for RP - Diplomat stuff


// u8 team;
// 1 = team 1
// 2 = team 2

// 0 = war
// 1 = neutral
// 2 = friends/allies

void onInit( CRules@ this )
{
	//team 1 status with team 2 (war)
	this.add_u8("1 2", 0);

	if(getNet().isServer())
	{
		this.Sync("1 2", true);
	}

}

void syncDiplomats(CRules@ this,int team,int team2, int status)
{
	this.set_u8(team + " " + team2, status);
	if(getNet().isServer())
	{
		this.Sync(team + " " + team2, true);
	}
}