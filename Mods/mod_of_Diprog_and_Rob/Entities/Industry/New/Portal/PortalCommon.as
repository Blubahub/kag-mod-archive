bool getPortals( CBlob@ this, CBlob@[]@ portals )
{
	CBlob@[] list;
	getBlobsByTag( "portal travel", @list );
	const u8 teamNum = this.getTeamNum();  	

	for (uint i=0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum()
			&& !blob.hasTag("under raid") && blob.hasTag("activated")) // HACK
		{
			portals.push_back( blob );
		}
	}

	return portals.length > 0;
}