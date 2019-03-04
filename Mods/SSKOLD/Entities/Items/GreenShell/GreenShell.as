#include "Hitters.as";
#include "ShieldCommon.as";
#include "LimitedAttacks.as";
#include "Requirements_Tech.as";
#include "MakeDustParticle.as";
#include "SSKExplosion.as";
#include "SSKMovesetCommon.as"

const f32 trampoline_speed = 8.0f;
const f32 stomp_speed = 2.0f;
const f32 shell_speed = 6.0f;
const f32 shell_damage = 4.0f;
const string shell_sync_cmd = "shell sync";

const u16 MAX_BOUNCES = 30;
const u16 TIME_TO_DIE = 30;

//blob functions
void onInit( CBlob@ this )
{
	this.addCommandID(shell_sync_cmd);

	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(1000);
	sprite.getConsts().accurateLighting = false;
	
	this.Tag("invincible");
    this.set_u8( "blocks_pierced", 0 );
    this.set_u8( "state", 0 );
	this.getShape().SetRotationsAllowed(false);
    LimitedAttack_setup(this);
    u32[] tileOffsets;
    this.set( "tileOffsets", tileOffsets );
	this.Tag("projectile");
	this.Tag("shell");

	this.set_bool("initiated", false);

	this.SetMapEdgeFlags( u8(CBlob::map_collide_none) | u8(CBlob::map_collide_nodeath) );	// fall out of map in every direction
}

void onTick( CBlob@ this )
{
    u8 state = this.get_u8( "state" );
	CMap@ map = getMap();
	const f32 ts = map.tilesize;
	const f32 y_ts = ts * 0.2f;
	const f32 x_ts = ts * 1.4f;
	Vec2f pos = this.getPosition();
	bool surface_right = map.isTileSolid(pos + Vec2f(x_ts, y_ts-map.tilesize)) || map.isTileSolid(pos + Vec2f(x_ts, y_ts));
	bool surface_left = map.isTileSolid(pos + Vec2f(-x_ts, y_ts-map.tilesize)) || map.isTileSolid(pos + Vec2f(-x_ts, y_ts));
		
	if (state == 0) //not sliding
    {	
		this.setVelocity(Vec2f( 0.0f, this.getVelocity().y ));
		this.getSprite().SetAnimation("default");	
    }
	
	if (state == 1) //sliding right
	{
		this.setVelocity(Vec2f( shell_speed, this.getVelocity().y ));
		this.getSprite().SetAnimation("sliding");
		this.SetFacingLeft( false );
		
		if (surface_right)
			{
				ParticleAnimated( "Sprites/dust.png",
								this.getPosition(),
								Vec2f(0.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
				
				this.getSprite().PlaySound( "shellbump.ogg" );
				if (getNet().isServer())
				{
					this.set_u8( "state", 2 );
					SyncShell( this );
				}
			}
	}
	
	if (state == 2) //sliding left
	{
		this.setVelocity(Vec2f( -shell_speed, this.getVelocity().y ));
		this.getSprite().SetAnimation("sliding");
		this.SetFacingLeft( true );
		
		if (surface_left)
			{
				ParticleAnimated( "Sprites/dust.png",
								this.getPosition(),
								Vec2f(0.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
			
				this.getSprite().PlaySound( "shellbump.ogg" );

				if (getNet().isServer())
				{
					this.set_u8( "state", 1 );
					SyncShell( this );
				}
			}
	}
	
	if (state == 3) //dead
	{
		this.getShape().getConsts().mapCollisions = false;
		this.getShape().getConsts().collidable = false;
		this.getSprite().SetAnimation("default");
		if (this.get_u8( "stompVelocityX" ) > 0)
		{
			this.setAngularVelocity(25.0);   //Make shell spin upon being killed
		}
		else
		{
			this.getSprite().SetFrame(1);
			this.setAngularVelocity(-25.0);
		}
	}

    const u16 mapWidth = map.tilemapwidth * map.tilesize;
    const u16 mapHeight = map.tilemapheight * map.tilesize;

    // die when falling below map
   	if (pos.y > mapHeight)
	{
		this.server_Die();
	}

	// warp to at sides of map
   	if (pos.x < 0)
	{
		this.setPosition(Vec2f(mapWidth, pos.y));
	}	
   	else if (pos.x > mapWidth)
	{
		this.setPosition(Vec2f(0, pos.y));
	}	
}

void SyncShell( CBlob@ this )
{
	u8 state = this.get_u8( "state" );	
	CBitStream bt;
	bt.write_u8( state );	
	this.SendCommand( this.getCommandID(shell_sync_cmd), bt );
}

void HandleShell( CBlob@ this, CBitStream@ bt )
{	
	u8 state;	
	state = bt.read_u8();	
	this.set_u8( "state", state );

	bool initiated = this.get_bool("initiated");

	if (!initiated)
	{
		this.server_SetTimeToDie( TIME_TO_DIE );
		this.set_bool("initiated", true);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if( cmd == this.getCommandID(shell_sync_cmd) )
    {
		HandleShell( this, params );
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )	// not used by engine - collides = false
{
	return ((this.get_u8( "state" ) != 3) || (blob.getShape().isStatic() && !blob.getShape().getConsts().platform));
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

	u8 state = this.get_u8( "state" );
    Vec2f pos = this.getPosition();
    Vec2f vel = blob.getOldVelocity();
	Vec2f moveVel = this.getOldVelocity();
	this.set_u8( "stompVelocityX", moveVel.x );
    
    Vec2f up(0.0f,-1.0f);
	
	if (state == 0)
	{
		if (blob.getOldVelocity().x > 0)
		{
			this.getSprite().PlaySound( "mariostomp.ogg" );

			if (getNet().isServer())
			{
				this.set_u8( "state", 1 );
				SyncShell( this );
			}
		}
		if (blob.getOldVelocity().x < 0)
		{
			this.getSprite().PlaySound( "mariostomp.ogg" );

			if (getNet().isServer())
			{
				this.set_u8( "state", 2 );
				SyncShell( this );
			}
		}
	}
    
	if ( blob.getVelocity().y > stomp_speed ) //dont bounce still stuff
    {                  
		//different force if buttons pressed
		f32 bounceForce = 	blob.isKeyPressed( key_jump ) ? 1.4f :
							blob.isKeyPressed( key_down ) ? 0.7f : 1.0f;
		
		bounceForce *= trampoline_speed;
		
		//add bounce and "drag"
		vel = vel * 0.5f + up * bounceForce;
		
		blob.setVelocity(vel);
		this.AddForce(-vel * blob.getMass() * 0.1f );
		
		this.getSprite().PlaySound( "mariostomp.ogg" );
		
		if (state == 0) //sliding right
		{
			if (blob.isFacingLeft()) //slide either right or left
			{
				if (getNet().isServer())
				{
					this.set_u8( "state", 2 ); 
					SyncShell( this );
				}
			}
			else
			{
				if (getNet().isServer())
				{
					this.set_u8( "state", 1 ); 
					SyncShell( this );
				}
			}
		}
		else if (state == 1 || state == 2) //sliding
		{
			if (getNet().isServer())
			{
				this.set_u8( "state", 0 ); //stop sliding
				SyncShell( this );
			}
		}
    }
	else if (state == 1 || state == 2)
	{
		Vec2f velocity = blob.getPosition() - this.getPosition();
		if (!blob.hasTag("shell"))
		{
			CustomHitData customHitData(2, 4.0f, 0.04f);
			server_customHit(this, blob, blob.getPosition(), velocity, shell_damage, Hitters::spikes, true, customHitData);
		}
			
		if (blob.getPlayer() !is null)
			this.getSprite().PlaySound( "whack1.ogg" );
			
		if (blob.hasTag("shell"))
		{
			this.getSprite().PlaySound( "shellbump.ogg" );
			if (state == 1)
			{
				ParticleAnimated( "Sprites/dust.png",
								this.getPosition(),
								Vec2f(0.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
				
				if (getNet().isServer())
				{
					this.set_u8( "state", 2 );
					SyncShell( this );
				}
			}
			if (state == 2) 
			{
				ParticleAnimated( "Sprites/dust.png",
								this.getPosition(),
								Vec2f(0.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
				
				if (getNet().isServer())
				{
					this.set_u8( "state", 1 );
					SyncShell( this );
				}
			}
		}
	}
}

void killShell( CBlob@ this )
{
	ParticleAnimated( "Sprites/Smoke.png",
						this.getPosition() + Vec2f(0.0,-4.0f),
						Vec2f(0.0,0.0f),
						1.0f, 1.0f, 
						3, 
						0.0f, true );
	
	if (getNet().isServer())
	{
		this.set_u8( "state", 3 );
		SyncShell( this );
	}

	this.getShape().getConsts().collidable = false;
	this.getShape().getConsts().bullet = false;
	this.setVelocity(Vec2f(0, 0));
	this.server_SetTimeToDie( 3 );
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.getSprite().PlaySound( "mariostomp.ogg" );
	
	if (getNet().isServer())
	{
		if (detached.isFacingLeft()) //facing left
			this.set_u8( "state", 2 );
		else
			this.set_u8( "state", 1 );		

		SyncShell( this );
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	u8 state = this.get_u8( "state" );
	return (state == 0);
}