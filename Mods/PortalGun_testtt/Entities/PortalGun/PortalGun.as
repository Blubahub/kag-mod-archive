const f32 BULLET_SPEED = 30.0f;
const f32 BULLET_RANGE = 500.0f;

void onInit(CBlob@ this)
{
	this.addCommandID("shootblue");
	this.addCommandID("shootorange");
	this.server_setTeamNum(0);
}

void onTick(CBlob@ this)
{
	 if (this.isAttached()) 
	 {	 	
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
	    CBlob@ holder = point.getOccupied();
	    const bool action1 = holder.isKeyJustPressed( key_action1 );
	    const bool action2 = holder.isKeyJustPressed( key_action2 );
		if(holder !is null)
		{
			CSprite@ sprite = this.getSprite();
			if (action1)
			{
				Shoot(this,holder,1);
			} 
			else if (action2)
			{
				Shoot(this,holder,2);
			} 

			Vec2f vec = holder.getAimPos() - this.getPosition();
			const f32 aimangle = getAimAngle(this,holder);

			sprite.ResetTransform();
	        sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-5,0) : Vec2f(5,0) );
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		this.set_u16( "ownerID" ,attached.getNetworkID()); // set owner to the player who picks it up
		// maybe make the gun the owner of the portals rather than player?
		// maybe kill the portals on detach?
	}
}

void Shoot( CBlob@ this, CBlob@ holder, u8 type)
{
	if ( !holder.isMyPlayer() )
		return;

	Vec2f pos = holder.getPosition();
	Vec2f aimVector = holder.getAimPos() - pos;
	const f32 aimdist = aimVector.Normalize();
	
	Vec2f vel = (aimVector * BULLET_SPEED);

	f32 lifetime = Maths::Min( 0.05f + BULLET_RANGE/BULLET_SPEED/32.0f, 1.35f); // stolen from shiprekt

	//string owner = (holder.getPlayer().getUsername());

	CBitStream params;
	params.write_Vec2f( vel );
	params.write_f32( lifetime );
	
	params.write_bool( true );
	Vec2f rPos = ( pos + aimVector*3 );
	params.write_Vec2f( rPos );	

	this.getSprite().PlaySound("/PortalShoot");
	
	if (type == 1)
	{
		this.SendCommand( this.getCommandID("shootblue"), params );
	}
	else if (type == 2)
	{
		this.SendCommand( this.getCommandID("shootorange"), params );
	}
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition();
    return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	Vec2f velocity = params.read_Vec2f();
	f32 lifetime = params.read_f32();
	Vec2f pos;		
	Vec2f rPos = params.read_Vec2f();
	pos = rPos + this.getPosition();

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
    CBlob@ holder = point.getOccupied();
	u16 blobID = holder.getNetworkID();

	if (this.getCommandID("shootblue") == cmd /* && canShoot( this ) */ )
	{		
		if (getNet().isServer())
		{
			this.server_setTeamNum(0);
            CBlob@ bullet = server_CreateBlob( "portalbullet", 0, pos );
            if (bullet !is null)
            {
	            bullet.set_u16( "ownerID", this.get_u16( "ownerID" ) ); 
                bullet.setVelocity( velocity );
                bullet.server_SetTimeToDie( lifetime ); 
            }
    	}			
	}

	if (this.getCommandID("shootorange") == cmd /* && canShoot( this ) */ )
	{		
		if (getNet().isServer())
		{
			this.server_setTeamNum(4);
            CBlob@ bullet = server_CreateBlob( "portalbullet", 4, pos );
            if (bullet !is null)
            {
            	bullet.set_u16( "ownerID", this.get_u16( "ownerID" ) );
                bullet.setVelocity( velocity );
                bullet.server_SetTimeToDie( lifetime ); 
            }
    	}		
	}
}