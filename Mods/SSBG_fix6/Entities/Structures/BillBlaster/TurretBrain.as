//TurretBrain by Strathos (based on MountedBow)
#define SERVER_ONLY
#include "BrainCommon.as"
#include "SSBG_BrainFuncs.as"


void onInit( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	blob.set_u32( "shootTime", 0 );
	blob.set_bool( "litFuse", false );
	blob.Tag( "heavy weight" );
	blob.Tag( "turret" );
	blob.Tag("place norotate");
	
	InitBrain( this );
	this.server_SetActive( true );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick( CBrain@ this )
{
    CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	u32 MIN_FIRE_DISTANCE = blob.get_f32( "min_fire_distance" );
	u16 TARGET_LOCK_TIME = blob.get_u16( "target_lock_time" );
	bool ARC360 = blob.get_bool( "arc360" );
	bool facingLeft = blob.isFacingLeft();
	bool litFuse = blob.get_bool( "litFuse" );
	u16 currentAngle = blob.get_u16( "aimAngle" );
	
	this.getCurrentScript().tickFrequency = TARGET_LOCK_TIME;
	
	ssbg_SearchTarget( this, true, ARC360, MIN_FIRE_DISTANCE );

	// logic for target
    if ( target !is null )
    {    
		Vec2f targetVector = target.getPosition() - blob.getPosition();
		f32 targetDistance = targetVector.Length();
		
		
		bool targetVisible = isVisible( blob, target ) ;
		bool inFront = ( ( facingLeft && targetVector.x <= 0 ) || ( !facingLeft && targetVector.x >= 0 ) ) || ARC360;
		bool inRange = targetDistance < MIN_FIRE_DISTANCE;
		
		if ( inRange ) 
		{
			this.getCurrentScript().tickFrequency = 1;
			//targetVector += blob.getVelocity() * 1.0f;//ToDo: add proper interception
			targetVector.y *= -1.0f;
			u16 aimAngle = targetVector.Angle() % 360;

			setAngle( blob, aimAngle );
			Shoot( blob, aimAngle );
			if ( getGameTime() % 90 == 0 )
				this.SetTarget( null );
		}
		else
		{
			if ( !inRange )
				setAngle( blob, facingLeft ? 180 : 0 );
			//print( "Target outOfRange||notVisible. Looking for new target" );
			/*if ( ( !inFront || !inRange ) && currentAngle != 0 && currentAngle != 360 )
			{
				print( "CurretAnglet: " + currentAngle );
				this.getCurrentScript().tickFrequency = 1;
				
				if ( ( currentAngle > 0 && currentAngle < 90) || ( currentAngle > 180 && currentAngle < 270 ) )
					setAngle( blob, currentAngle - 5 );
				else if ( ( currentAngle < 180 && currentAngle > 90) || ( currentAngle > 270  && currentAngle < 360 ) )
					setAngle( blob, currentAngle + 5 );
				if ( currentAngle == 180 || currentAngle == 360 )
					setAngle( blob, 0 );
			}*/	
			
			this.SetTarget( null );
			
			if ( litFuse )
				Shoot( blob, currentAngle );
		}
		
		LoseTarget( this, target );//if target is killed
    }
	else if ( litFuse )
	{
		this.getCurrentScript().tickFrequency = 1;
		Shoot( blob, currentAngle );
	}//else
		//setAngle( blob, 0 );//shouldn't be necessary
}

void setAngle( CBlob@ this, u16 angle )
{
	//I don't like this way of doing it, but couldn't make it work with setAimPos()
	this.set_u16( "aimAngle", angle );
	this.Sync( "aimAngle", true );
}

void Shoot( CBlob@ this, f32 aimAngle )
{
	//check 'reload' time
	const u32 gameTime = getGameTime();	
	u32 shootTime = this.get_u32( "shootTime");
	bool shoot = gameTime > shootTime;
	bool litFuse = this.get_bool( "litFuse" );
	
	if ( !shoot || this.getVelocity().Length() > 0.1f )
		return;
	if ( !litFuse )
	{
		//print( "LIT FUSE!" );
		this.set_bool( "litFuse", true );
		this.Sync( "litFuse", true );
		this.set_u32( "shootTime", gameTime + 45 );
		return;
	}
	
	u16 SHOOT_INTERVAL = this.get_u16( "shoot_interval" );
	string PROJECTILE = this.get_string( "projectile" );
	f32 PROJECTILE_SPEED = this.get_f32( "projectile_speed" );
	f32 PROJECTILE_LIFETIME = this.get_f32( "projectile_lifetime" );

	//Shoot!
	//print( "FIRING! angle: " + aimAngle );
	this.set_u32( "shootTime", gameTime + SHOOT_INTERVAL );
	this.set_bool( "litFuse", false );
	this.Sync( "litFuse", true );

	CBlob@ bullet = server_CreateBlobNoInit( PROJECTILE );
	if ( bullet !is null )
	{		
		bullet.server_setTeamNum( this.getTeamNum() );
		bullet.SetDamageOwnerPlayer( this.getDamageOwnerPlayer() );
       
        Vec2f vel = Vec2f( PROJECTILE_SPEED , 0.0f ).RotateBy( aimAngle );
        bullet.setVelocity( vel );
        Vec2f offset = Vec2f( 0.0f, -6.0f );//this should be a variable
        bullet.setPosition( this.getPosition() + offset );

		bullet.server_SetTimeToDie(-1); // override lock
		bullet.server_SetTimeToDie( PROJECTILE_LIFETIME );
		bullet.Tag( "bow arrow" );
    }
}