void GetPlayersFromTruck(CBlob@ blob, CPlayer@[]@ queuedPlayers)
{
	int count = blob.getAttachmentPointCount();
	for (int i = 0; i < count; i++)
	{
		AttachmentPoint @ap = blob.getAttachmentPoint(i);
		CBlob@ occ = ap.getOccupied();
		if (occ is null) continue;
		CPlayer@ p = occ.getPlayer();
		if (p is null) continue;
		queuedPlayers.push_back(@p);
	}
}