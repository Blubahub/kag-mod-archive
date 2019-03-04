#include "Hitters.as";
#include "ShieldCommon.as";
#include "LimitedAttacks.as";
#include "Requirements_Tech.as";
#include "SSKExplosion.as";
#include "SSKMovesetCommon.as"

const f32 trampoline_speed = 4.0f;
const f32 stomp_speed = 2.0f;

//blob functions
void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(1000);
	sprite.getConsts().accurateLighting = false;
	this.SetLight( true );
	this.SetLightRadius( 15.0f );
	this.set_u32("last smoke puff", 0 );
	
    this.set_u8( "blocks_pierced", 0 );
    this.set_u8( "state", 0 );
    this.server_SetTimeToDie( 30 );
    this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
    LimitedAttack_setup(this);
    u32[] tileOffsets;
    this.set( "tileOffsets", tileOffsets );
	this.Tag("projectile");

	this.getSprite().SetFacingLeft( !this.getSprite().isFacingLeft() ); // ?  it turns sides when setting frame
}

void onTick( CBlob@ this )
{
    u8 state = this.get_u8( "state" );
    f32 angle = 0;
	
	if (this.get_u8( "state" ) != 2)  //unstomped Bill
	{
		this.getShape().SetGravityScale( 0.0f );
		if (this.getVelocity().x > 0)
		{
			this.getSprite().SetFrame(1);    //Make Bullet Bill face upright
		}
		else
		{
			this.getSprite().SetFrame(2);
		}
	}
	if (this.get_u8( "state" ) == 2)
	{
		this.getShape().SetGravityScale( 1.0f );
		if (this.get_u8( "stompVelocityX" ) > 0)
		{
			this.getSprite().SetFrame(2);    //Make Bullet Bill be upside down upon being stomped
			this.setAngularVelocity(25.0);
		}
		else
		{
			this.getSprite().SetFrame(1);
			this.setAngularVelocity(-25.0);
		}
	}
	

    if (state == 0) //we haven't hit anything yet!
    {
        angle = (this.getVelocity()).Angle();
		this.setAngleDegrees( -angle+180.0f );
		
		const u32 gametime = getGameTime();
		u32 lastSmokeTime = this.get_u32("last smoke puff");
		int ticksTillSmoke = 3;
		int diff = gametime - (lastSmokeTime + ticksTillSmoke);
		if (diff > 0)
		{
			CParticle@ p = ParticleAnimated("tumblesmoke2.png", this.getPosition(), Vec2f(0, 0), XORRandom(360), 1.0f, 4, 0.0f, true);
			if ( p !is null)
			{
				p.Z = 500.0f;
			}
		
			lastSmokeTime = gametime;
			this.set_u32("last smoke puff", lastSmokeTime);
		}
				
        Pierce( this, angle );
    }

}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )	// not used by engine - collides = false
{
	return ((this.get_u8( "state" ) != 2) && (this.getTeamNum() != blob.getTeamNum()) || (blob.getShape().isStatic() && !blob.getShape().getConsts().platform));
}

void Pierce( CBlob @this, f32 angle )
{
	CMap@ map = this.getMap();

	Vec2f initVelocity = this.getVelocity();
	Vec2f velDir = initVelocity;
	velDir.Normalize();

	f32 dmg = 1.0f;

	Vec2f pos = this.getPosition();
	Vec2f tailpos = pos - velDir * 12.0f;
	Vec2f tippos = pos + velDir * 12.0f;
	Vec2f midpos = pos + velDir * 6.0f;
	
	Vec2f[] positions = {tippos, midpos, pos, tailpos};
	
	for(uint i = 0; i < positions.length; i++)
	{	
		Vec2f temp = positions[i];
		TileType overtile = map.getTile(temp).type;
		if(map.isTileSolid(overtile))
		{
			//BallistaHitMap( this, map.getTileOffset(temp), temp, initVelocity, dmg, Hitters::ballista );
			//this.server_HitMap( temp, initVelocity, dmg, Hitters::ballista ); 
			break;
		}
	}
	
    f32 vellen = this.getShape().vellen;
    HitInfo@[] hitInfos;

	if (vellen > 0.1f)
    if ( map.getHitInfosFromArc( tailpos, -angle, 10, vellen + 12.0f, this, false, @hitInfos ) )
    {
		for (uint i = 0; i < hitInfos.length; i++)
        {
            HitInfo@ hi = hitInfos[i];

            if (hi.blob !is null) // blob
            {
                if ( !hi.blob.isCollidable() || !doesCollideWithBlob(this, hi.blob)) {
                    continue;
                }

                if ( LimitedAttack_has_hit_actor(this, hi.blob) ) {
                    continue;
                }
				
				f32 dmg2 = 4.0f;
				
				if (hi.blob.getVelocity().y <= stomp_speed)
				{
					BallistaHitBlob( this, hi.hitpos, initVelocity, dmg2, hi.blob, Hitters::ballista );

					CustomHitData customHitData(8, 2.0f, 0.06f);
					server_customHit(this, hi.blob, hi.hitpos, initVelocity, dmg2, Hitters::ballista, true, customHitData);

					LimitedAttack_add_actor(this, hi.blob);
				
					ParticleAnimated( "Entities/Effects/Sprites/Explosion.png",
								this.getPosition(),
								Vec2f(0.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
				}
            }
            //else map is handled above
        }
    }
}

void BallistaHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
    if (hitBlob !is null)
    {
		
        // check if shielded
        if (hitBlob.hasTag("flesh"))
        {
            this.getSprite().PlaySound( "Whack1.ogg" );
        }
        else
        {
            this.getSprite().PlaySound( "ArrowHitGroundFast.ogg" );
        }
    }
}

void BallistaHitMap( CBlob@ this, u32 tileOffset, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{	
	if(this.get_u8( "state" ) == 1)
		return;
	
    //check if we've already hit this tile
    u32[]@ offsets;
    this.get( "tileOffsets", @offsets );

    if( offsets.find(tileOffset) >= 0 ) { return; }
	
	this.getSprite().PlaySound( "Sounds/Thunder2.ogg", 0.5 );
	ParticleAnimated( "Entities/Effects/Sprites/Explosion.png",
							this.getPosition(),
							Vec2f(0.0,0.0f),
							1.0f, 1.0f, 
							3, 
							0.0f, true );

	CMap@ map = getMap();

    this.getSprite().PlaySound( "ArrowHitGroundFast.ogg" );
    f32 angle = velocity.Angle();
    TileType t = map.getTile(tileOffset).type;
    u8 blocks_pierced = this.get_u8( "blocks_pierced" );
    bool stuck = false;

	if (t == CMap::tile_bedrock)
	{
		//die
		this.Tag("dead");
		this.server_Die();
		this.getSprite().Gib();
	}
    else if (!map.isTileGround(t))
    {
        Vec2f tpos = worldPoint;
        map.server_DestroyTile( tpos, 1.0f, this );
        Vec2f vel = this.getVelocity();
        this.push( "tileOffsets", tileOffset );
		
 
    }
    else
    {
        stuck = false;
    }

    if (stuck)
    {
        this.set_u8( "state", 1 );
        this.set_u8( "angle", Maths::get256DegreesFrom360(angle)  );
        
        Vec2f lock = this.getPosition();
        
        this.set_f32( "lock_x", lock.x );
        this.set_f32( "lock_y", lock.y );
        
        this.Sync("state",true);
        this.Sync("lock_x",true);
        this.Sync("lock_y",true);

        //this.doTickScripts = false;
		this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob is null) { // map collision?
        return;
    }
	if (blob.hasTag("fire bolt"))
	{
	blob.server_Die();
	}

    Vec2f pos = this.getPosition();
    Vec2f vel = blob.getOldVelocity();
	Vec2f moveVel = this.getOldVelocity();
    Vec2f blobpos;
    
    if(blob.getShape() is null)
		blobpos = blob.getPosition();
	else
		blobpos = blob.getShape().getVars().oldpos;
	
    f32 horizDist = Maths::Abs( (blobpos.x -  pos.x) );
    
    Vec2f up(0.0f,-1.0f);
    
    f32 vellen = vel.Length();
    f32 vel_angle = up.AngleWith(vel);
    
	if ( blob.getVelocity().y > stomp_speed && this.getTeamNum() != blob.getTeamNum() ) //dont bounce still stuff
    {
       
            
            //different force if buttons pressed
            f32 bounceForce = blob.isKeyPressed( key_jump ) ? 1.4f :
								blob.isKeyPressed( key_down ) ? 0.7f : 1.0f;
            
				bounceForce *= trampoline_speed;
            
            //reflect vel off the trampoline if we're jumping in
            if(Maths::Abs( vel_angle ) > 90)
            {
				f32 reflected_angle = ((vel_angle > 0) ? 90-vel_angle : -90-vel_angle);
				
				vel.RotateBy( reflected_angle * 2.0f, Vec2f() );
			}
			
            //add bounce and "drag"
            vel = vel * 0.5f + up * bounceForce;
            
	        blob.setVelocity(vel);
            this.AddForce(-vel * blob.getMass() * 0.1f );
            
            this.getSprite().PlaySound( "MarioStomp.ogg" );       
			ParticleAnimated( "Sprites/Smoke.png",
								this.getPosition() + Vec2f(0.0,-4.0f),
								Vec2f(0.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
			
			this.set_u8( "state", 2 );
			this.getShape().getConsts().collidable = false;
			this.getShape().getConsts().bullet = false;
			this.set_u8( "stompVelocityX", moveVel.x );
			this.setVelocity(Vec2f(0, 0));
			this.server_SetTimeToDie( 2 );
    }
}
