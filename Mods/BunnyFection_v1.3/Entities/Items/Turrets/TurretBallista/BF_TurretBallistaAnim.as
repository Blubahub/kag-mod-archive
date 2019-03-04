// Mounted Bow logic
#include "MakeDustParticle.as";

const Vec2f arm_offset = Vec2f( 0, -3 );

void onInit( CSprite@ this )
{
    CSpriteLayer@ arm = this.addSpriteLayer( "arm", this.getConsts().filename, 25, 16 );
	
	this.SetEmitSound( "/BowPull.ogg" );
	this.SetEmitSoundVolume( 0.6f );
    
	if (arm !is null)
    {
		{
			Animation@ anim = arm.addAnimation( "armdefault", 0, false );
			anim.AddFrame(1);
		}
		{
			Animation@ anim = arm.addAnimation( "litfuse", 23, false );
			anim.AddFrame(2);
			anim.AddFrame(3);
			anim.AddFrame(0);
        }
		arm.SetOffset( arm_offset );
    }

    this.getBlob().getShape().SetRotationsAllowed( false );

	this.SetZ(-10.0f);
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
		arm.SetRelativeZ( 1.0f );
		arm.SetOffset( arm_offset );
		arm.RotateBy( ( aimAngle + compensate ), Vec2f( 0 , 3.0f ) );

		if ( litFuse )
		{
			arm.SetAnimation( "litfuse" );
			//this.SetEmitSoundPaused( false );
		}
		else
		{
			if ( arm.isAnimation( "litfuse" ) )
			{
				this.PlaySound( "/BowFire.ogg", 0.4f );
				MakeDustParticle( blob.getPosition() + Vec2f( 10, facing_left ? -4 : 4 ).RotateBy( aimAngle ), "Smoke.png" );
			}
			arm.SetAnimation( "armdefault" );
			this.SetEmitSoundPaused( true );
		}
	}
}

/*void onHealthChange( CBlob@ this, f32 oldHealth )
{

	f32 hp = this.getHealth();
	f32 max_hp = this.getInitialHealth();
	int damframe = hp < max_hp * 0.4f ? 2 : hp < max_hp * 0.9f ? 1 : 0;
	CSprite@ sprite = this.getSprite();
	sprite.animation.frame = damframe;
	CSpriteLayer@ cage = sprite.getSpriteLayer( "cage" );  
	if (cage !is null)
		cage.animation.frame = damframe;
}*/