void onInit( CBlob@ this )
{
	if (!this.exists("pdamage"))
	{
		this.set_f32("pdamage", 0.0f);
		this.Sync("pdamage", true);
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (this.hasTag("player"))
	{
		this.set_f32("pdamage", this.get_f32("pdamage") + damage);
		this.Sync("pdamage", true);
		return 0.0f;
	}

	return damage;
}