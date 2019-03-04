void RequestClassesMenu(CRules@ this, CPlayer@ player)
{
	player.Untag("class picked");
	player.set_u32("class menu time", 0);
	ShowClassesMenu(this, player);
}

void SetTeam(CRules@ this, CPlayer@ player)
{
	const int team = getNet().isClient() ? ((player.getControls().getIndex()) % this.getTeamsCount()) : getPlayerIndex(player);
	player.server_setTeamNum(team);
}

void ShowClassesMenu( CRules@ this, CPlayer@ player )
{
    if (player.isBot())
        return;
    CBitStream params;
    params.write_netid( player.getNetworkID() );
    params.write_u8( sv_max_localplayers );
    this.SendCommand( this.getCommandID("show class menu"), params, player );    
}
