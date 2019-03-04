void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is hitterBlob)
	{
		return damage;
	}

	Sound::Play("Hit.ogg", this.getPosition());
	

	return damage;
}
