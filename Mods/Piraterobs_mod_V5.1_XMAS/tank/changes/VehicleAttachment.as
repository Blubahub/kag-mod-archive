// requires VEHICLE attachment point

const uint REATTACH_TIME = 60 * getTicksASecond();

void onInit(CBlob@ this)
{
	this.addCommandID("detach vehicle");
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() != this.getTeamNum())
		return;

	AttachmentPoint@[] aps;
	if (!this.getAttachmentPoints(@aps))
		return;

	for (uint i = 0; i < aps.length; i++)
	{
		AttachmentPoint@ ap = aps[i];
		if (!ap.socket || ap.name != "VEHICLE")
			continue;
		
		CBlob@ occBlob = ap.getOccupied();
		if (occBlob is null)
			continue;
		
		CBitStream params;
		params.write_netid( occBlob.getNetworkID() );
		caller.CreateGenericButton( 1, ap.offset + Vec2f(0, -8), this, this.getCommandID("detach vehicle"), "Detach " + occBlob.getInventoryName(), params );
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer() && cmd == this.getCommandID("detach vehicle"))
	{
		CBlob@ vehicle = getBlobByNetworkID(params.read_netid());
		if (vehicle !is null)
		{
			vehicle.server_DetachFrom(this);
			vehicle.IgnoreCollisionWhileOverlapped(null);
			this.IgnoreCollisionWhileOverlapped(null);

			vehicle.set_u32("reattach time", getGameTime() + REATTACH_TIME);
		}
	}
}
