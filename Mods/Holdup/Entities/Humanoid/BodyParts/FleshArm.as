
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.1f && hitterBlob !is this)
	{
		Sound::Play("FleshHit.ogg", this.getPosition());
	}

	return damage;
}
