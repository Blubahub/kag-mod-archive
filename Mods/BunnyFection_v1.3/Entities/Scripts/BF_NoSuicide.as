#include "Knocked.as";


f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//print("cData: " + customData );
	if ( hitterBlob.getTeamNum() != 1 )// !hitterBlob.hasTag( "mutant" )
	{
		f32 health = this.getHealth();
		if ( health - damage < 0.0f )
		{
			if( isKnockable( this ) )
				SetKnocked( this, 26 );
				
			return health - 0.1f;//damage to leave at bare minimum health
		}
	}
	return damage;
}