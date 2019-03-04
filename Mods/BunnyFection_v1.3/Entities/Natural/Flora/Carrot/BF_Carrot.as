// BF_Carrot script

void onInit( CBlob@ this )
{  
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(10.0f);
    sprite.PlaySound("/BF_CarrotPop.ogg", 2.0f);
	sprite.SetFrameIndex( this.get_u8( "growth_level" ) );
	this.setVelocity(Vec2f((XORRandom(2) == 0 ? -1 : 1) * 2, -2));
	this.SetFacingLeft(XORRandom(2) == 0);
	//print( "initGrowLVL: " + this.get_u8( "growth_level" ) );
	this.Tag( "flora" );
}

void Nibble( CBlob@ this, CBlob@ blob )
{
    if (blob.hasTag("player") && !blob.hasTag("mutant"))
    {
		f32 health = blob.getHealth();
		f32 mHealth = blob.getInitialHealth();
		if ( health < mHealth )
        {
			f32 g_lvl = this.get_u8( "growth_level" );
			f32 healthAmmount = ( g_lvl + 1.0f )/2.0f;		
			blob.server_Heal( healthAmmount );
			//print( "::::AteCarrot. Health from: " + health*2.0f + " to " + blob.getHealth()*2.0f );
			this.getSprite().PlaySound( "/Eat.ogg" );
            this.server_Die();
        }
    }
}

void onCollision ( CBlob@ this, CBlob@ blob, bool solid )
{
    if (blob is null)
    {
        return;
    }
    if (getNet().isServer() && !blob.hasTag("dead")) 
    {
        Nibble( this, blob );
    }
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    if (getNet().isServer()) 
    {
        Nibble( this, attached );
    }
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint )
{
    if (getNet().isServer()) 
    {
        Nibble( this, detached );
    }
}