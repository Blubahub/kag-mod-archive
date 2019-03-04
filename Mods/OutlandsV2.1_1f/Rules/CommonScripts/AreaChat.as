const f32 hearDistance = 350.0f;

bool onClientProcessChat( CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player )
{
	CBlob@ localBlob = getLocalPlayerBlob();
	CBlob@ chatBlob = player.getBlob();
	f32 distance = 9999.0f;
	
	if ( localBlob is chatBlob ) return true;
	
	if ( localBlob !is null && chatBlob !is null )
	{
		distance = localBlob.getDistanceTo( chatBlob );
		if ( distance > hearDistance && distance < hearDistance * 1.3f )
			client_AddToChat( "You hear voices in the vecinity." );
	}
	
	return distance < hearDistance;//ALLCAPS msgs could get a boost
}