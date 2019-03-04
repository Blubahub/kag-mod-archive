bool getBlobsWithTagInRadius(CMap@ map, Vec2f pos, float radius, string tag, CBlob@[]@ list)
{
	CBlob@[] blobs;
	map.getBlobsInRadius(pos, radius, blobs);
	
	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		if (b is null)
		{
			continue;
		}
		
		if (b.hasTag(tag))
		{
			list.push_back(b);
		}
	}
	return list.length > 0;
}