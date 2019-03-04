void onInit( CBlob@ this )
{
	if (!this.exists( "eat sound" )) {
		this.set_string( "eat sound", "/Eat.ogg" );
	}
}

void Heal( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("player") && blob.getHealth() < blob.getInitialHealth()) 
	{
		if ( this.getName() == "heart" )
			blob.server_Heal( 1.0f );
		else
			blob.server_SetHealth( blob.getInitialHealth() );
			
		this.server_Die();
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob is null) {
		return;
	}
						  
	if (getNet().isServer() && !blob.hasTag("dead")) 
	{
		Heal( this, blob );
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (getNet().isServer()) 
	{
		Heal( this, attached );
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint )
{
	if (getNet().isServer()) 
	{
		Heal( this, detached );
	}
}

void onDie( CBlob@ this )
{
	this.getSprite().PlaySound( this.get_string( "eat sound") );
}
