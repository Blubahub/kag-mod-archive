#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 modifier = 1.0f;
	bool reduce_damage = hitterBlob.getTeamNum() >= 100;
	if(reduce_damage)
		modifier /= 2;
	return damage*modifier;
}