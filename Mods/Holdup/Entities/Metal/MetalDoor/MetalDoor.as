
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	damage -= 2.0f;
	if(damage < 0.0f)return 0.0f;
	return damage;
}
