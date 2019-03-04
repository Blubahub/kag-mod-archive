//BF VectorWorks by Strathos

shared class PosInfo
{
	Vec2f pos;
	f32 dist;
	
	PosInfo( Vec2f position, f32 distance )
	{
		pos = position;
		dist = distance;
	}
}

PosInfo[] getTilePosInRadius( Vec2f center, u8 radius )
{
	CMap@ map = getMap();
	f32 tilesize = map.tilesize;
	PosInfo[] list;
	
	Vec2f TopLeft = map.getTileWorldPosition( Vec2f( center.x - radius, center.y - radius )/tilesize );
	Vec2f BottomRight = map.getTileWorldPosition( Vec2f( center.x + radius, center.y + radius )/tilesize );

	for ( f32 y = TopLeft.y; y <= BottomRight.y; y += tilesize )
		for ( f32 x = TopLeft.x; x <= BottomRight.x; x += tilesize )
		{
			f32 centerDistance = ( Vec2f( x, y ) - center ).Length();
			if ( centerDistance <= radius )
			{
				list.push_back( PosInfo( Vec2f( x, y ), centerDistance ) );
			}
		}
	
	return list;
}

void removeMarkersInRadius( string markName, Vec2f position, f32 radius )
{
	CMap@ map = getMap();
	Vec2f[] markers;
	map.getMarkers( markName, markers );
	for ( int i = 0; i < markers.length(); i++ )
	{
		f32 distance = ( position - markers[i] ).Length();
		if ( distance < radius )
			map.RemoveMarker( markName, i );
	}
}