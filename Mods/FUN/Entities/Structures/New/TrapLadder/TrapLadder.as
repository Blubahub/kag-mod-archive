void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	
	CBlob@[] blobsInRadius;
	const int team = this.getTeamNum();
	if (map.getBlobsInRadius( this.getPosition(), this.getRadius() * 2.0f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null && b.hasTag("player"))
			{
				if (b.getTeamNum() != team && b.isOverlapping(this))
				{
					this.getShape().getVars().isladder = false;
					this.getSprite().SetAnimation("hidden");
				}
				else if ((b.getTeamNum() == team && b.isOverlapping(this)) || !b.isOverlapping(this))
				{
					this.getShape().getVars().isladder = true;
					this.getSprite().SetAnimation("default");
				}
			}
		}
	}
}

