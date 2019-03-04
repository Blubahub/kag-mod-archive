//common tunnel functionality

bool getTunnels(CBlob@ this, CBlob@[]@ tunnels)
{
	CBlob@[] list;
	getBlobsByName("mouse_hole", @list);
	const u8 teamNum = this.getTeamNum();

	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this)
		{
			tunnels.push_back(blob);
		}
	}

	return tunnels.length > 0;
}