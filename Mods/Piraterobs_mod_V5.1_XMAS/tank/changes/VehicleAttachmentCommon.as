// if you want attach button remember to add
//	this.addCommandID("attach vehicle");
//

void TryToAttachVehicle(CBlob@ this, CBlob@ toBlob = null)
{
	if (this.get_u32("reattach time") > getGameTime())
		return;

	@toBlob = canAttach(this, @toBlob);
	if(toBlob !is null)
		toBlob.server_AttachTo(this, toBlob.getAttachments().getAttachmentPointByName("VEHICLE"));
}

CBlob@ canAttach(CBlob@ this, CBlob@ toBlob = null)
{
	if (this is null || this.getAttachments() is null)
		return null;

	AttachmentPoint@ ap1 = this.getAttachments().getAttachmentPointByName("VEHICLE");
	if (ap1 is null || ap1.socket || ap1.getOccupied() !is null)
		return null;

	CBlob@[] blobsInRadius;	
	if (toBlob !is null)
		blobsInRadius.push_back( toBlob );
	else
		getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*1.5f + 64.0f, @blobsInRadius ); 

	for (uint i = 0; i < blobsInRadius.length; i++)
	{
		CBlob @b = blobsInRadius[i];
		if (b.getTeamNum() != this.getTeamNum() || b.getAttachments() is null)
			continue;

		AttachmentPoint@ ap2 = b.getAttachments().getAttachmentPointByName("VEHICLE");
		if (ap2 !is null && ap2.socket && ap2.getOccupied() is null)
		{
			return @b;
		}
	}
	return null;
}

bool Vehicle_AddAttachButton(CBlob@ this, CBlob@ caller)
{

	CBlob@ toBlob = canAttach(this, @toBlob);
	if( toBlob is null )
		return false;
	
	CBitStream params;
	params.write_netid( toBlob.getNetworkID() );
	caller.CreateGenericButton(0, Vec2f(0, 0), this, this.getCommandID("attach vehicle"), "Attach " + this.getInventoryName(), params);
	
	return true;
}
