bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob !is null)
	{
		if (blob.hasTag("door") || blob.hasTag("blocks water") || blob.hasTag("place norotate"))
			return true;
	}
	return false;
}