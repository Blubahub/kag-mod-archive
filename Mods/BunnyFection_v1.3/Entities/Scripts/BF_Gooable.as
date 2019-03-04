#include "RunnerCommon.as";

const u8 DEF_MAX_TIME = 90;

void onInit( CBlob@ this )
{
	this.Tag( "gooable" );
	this.set_u8( "stickiedTime", 0 );
	if ( !this.exists( "maxStickiedTime" ) )
		this.set_u8( "maxStickiedTime", DEF_MAX_TIME );
}

void onTick( CBlob@ this )
{
	u8 stickiedTime = this.get_u8( "stickiedTime" );
	if ( stickiedTime > 0 )
	{
		u8 maxTime = this.get_u8( "maxStickiedTime" );
		if ( stickiedTime > maxTime )
			stickiedTime = maxTime;
			
		RunnerMoveVars@ moveVars;
		if ( this.get( "moveVars", @moveVars ) )
		{
			moveVars.walkFactor *= 0.5f;
			moveVars.jumpFactor *= 0.5f;
		}
		this.set_u8( "stickiedTime", stickiedTime - 1 );
	}
}



f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if ( hitterBlob.exists( "gooTime" ) )
	{
		this.set_u8( "stickiedTime", this.get_u8( "stickiedTime" ) + hitterBlob.get_u8( "gooTime" ) );
		print( "gooed! " + this.get_u8( "stickiedTime" ) );
	}
	
	return damage;
}