#include "MakeMat.as";
#include "Hitters.as"

const f32 AMMOUNT_FACTOR = 10.0f;

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if ( getNet().isServer() && hitterBlob.hasTag( "mutant" ) && damage < 10.0f )//damage check for hatchery outbreak
	{
		u16 ammount = Maths::Round( damage * AMMOUNT_FACTOR );
		if ( ammount > 1 )
			MakeMat( hitterBlob, worldPoint, "bf_materialbiomass", ammount );
		else if ( XORRandom(2) == 0 )
			MakeMat( hitterBlob, worldPoint, "bf_materialbiomass", 2 );
	}

	return damage;
}