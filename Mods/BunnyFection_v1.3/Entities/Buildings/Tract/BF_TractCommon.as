//BF_TractCommon script

bool getTunnels( CBlob@ this, CBlob@[]@ tunnels )
{
	CBlob@[] list;
	getBlobsByTag( "travel tunnel", @list );
	const u8 teamNum = this.getTeamNum();

	for (uint i=0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum()
			&& getGameTime() > blob.get_u16( "lastHit" ) + 300)
		{
			tunnels.push_back( blob );
		}
	}
	return tunnels.length > 0;
}

Vec2f closestStruct( CBlob@ this )
{
	CBlob@ closestStr = null;
	f32 minDistance = 9999.0f;
	CBlob@[] list;
	getBlobsByTag( "travel tunnel", @list );

	for (uint i=0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if ( blob is this )
		{
			continue;
		}
		f32 distanceTo = this.getDistanceTo( blob );
		if ( distanceTo < minDistance )
		{
			minDistance = distanceTo;
			@closestStr = blob;
		}
	}
	if ( closestStr !is null )
		return closestStr.getPosition() - this.getPosition();
	else
		return Vec2f( minDistance, minDistance );
}

f32 closestLinkedStruct( CBlob@ this )
{
	f32 minDistance = 9999.0f;
	
	CBlob@ hatchery = getBlobByNetworkID( getRules().get_s16( "hatcheryID" ) );
	if ( hatchery is null )
		return minDistance;
	bool hatcheryToLeft = hatchery.getPosition().x < this.getPosition().x;

	CBlob@[] list;
	getBlobsByTag( "travel tunnel", @list );

	for (uint i=0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if ( blob is this ) continue;
		
		f32 distanceTo = this.getDistanceTo( blob );
		bool blobToLeft = blob.getPosition().x < this.getPosition().x;
		if ( distanceTo < minDistance && hatcheryToLeft == blobToLeft )
			minDistance = distanceTo;
	}
	return minDistance;
}