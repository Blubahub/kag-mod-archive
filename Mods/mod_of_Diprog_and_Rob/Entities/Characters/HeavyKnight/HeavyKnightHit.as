#include "FUNHitters.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case FUNHitters::orb:
		dmg = 0.2f;
		break;
	}		
	return dmg;
}