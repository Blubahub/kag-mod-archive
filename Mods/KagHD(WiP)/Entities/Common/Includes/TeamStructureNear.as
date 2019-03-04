bool isTeamStructureNear(CBlob@ this, f32 radius = 128.0f)
{
	CBlob@[] blobsInRadius;
	const int teamNum = this.getTeamNum();
	if (getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is this && b.getTeamNum() == teamNum && (b.hasTag("building") || b.hasTag("door")))
			{
				return true;
			}
		}
	}
	return false;
}