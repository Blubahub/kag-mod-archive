// include this for SoldierPlace.as functionality to work

void onBlobDie( CRules@ this, CBlob@ blob )
{
	CBlob@ owner = getBlobByNetworkID( blob.get_netid( "owner" ) );
	if (owner !is null)
	{
		const string propertyName = blob.getName() + " count";
		owner.set_u16( propertyName, owner.get_u16( propertyName ) + 1 );
		if (owner.isMyPlayer()){
			Sound::Play("Add");
		}
	}
}