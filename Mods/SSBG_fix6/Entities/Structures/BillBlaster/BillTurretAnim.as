// Mounted Bow logic
#include "MakeDustParticle.as";

const Vec2f arm_offset = Vec2f( 0, -6 );

void onInit( CSprite@ this )
{
    CSpriteLayer@ arm = this.addSpriteLayer( "arm", "bill_tube", 16, 16 );
	this.SetRelativeZ( 2000.0f );
	
	this.SetEmitSoundVolume( 0.6f );
    
	if (arm !is null)
    {
		{
			Animation@ anim = arm.addAnimation( "armdefault", 0, false );
			anim.AddFrame(1);
		}
		{
			Animation@ anim = arm.addAnimation( "litfuse", 16, false );
			//anim.time = 16;
			anim.AddFrame(1);
        }
		arm.SetOffset( arm_offset );
    }

    this.getBlob().getShape().SetRotationsAllowed( false );
}

void onTick( CSprite@ this )
{
    //set the arm angle based on GUNNER mouse aim, see above ^^^^
	CBlob@ blob = this.getBlob();
    CSpriteLayer@ arm = this.getSpriteLayer( "arm" );
	bool facing_left = this.isFacingLeft();
	bool litFuse = blob.get_bool( "litFuse" );
	//Arm anim: rotate arm and show if loaded ammo
	if ( arm !is null )
	{
			
		f32 aimAngle = blob.get_u16( "aimAngle" );
		f32 compensate = ( aimAngle > 90 && aimAngle < 270 ) ? 180 : 0;//can't use facing_left here
		arm.ResetTransform();
		arm.SetFacingLeft(facing_left);
		arm.SetRelativeZ( 1500.0f );
		arm.SetOffset( arm_offset );
		arm.RotateBy( ( aimAngle + compensate ), Vec2f( 0 , 0.0f ) );

		if ( litFuse )
		{
			arm.SetAnimation( "litfuse" );
			this.SetEmitSoundPaused( false );
		}
		else
		{
			if ( arm.isAnimation( "litfuse" ) )
			{
				this.PlaySound( "/BulletShoot.ogg" );
				MakeDustParticle( blob.getPosition() + Vec2f( 10, facing_left ? -4 : 4 ).RotateBy( aimAngle ), "explosion_old.png", 500.0 );
			}
			arm.SetAnimation( "armdefault" );
			this.SetEmitSoundPaused( true );
		}
	}
}