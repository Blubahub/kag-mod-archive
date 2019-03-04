//was bombphsyics.as

void onTick(CBlob@ this, CShape@ p)
{
	Vec2f vel = this.getVelocity();
	const f32 maxVel = 2.0f;

	if (vel.x > maxVel)
	{
		vel.x = maxVel;
	}

	if (vel.x < -maxVel)
	{
		vel.x = -maxVel;
	}

	if (this.isOnGround() || this.isOnCeiling())
	{
		vel.x *= 0.8;
	}

	if (vel.y > maxVel)
	{
		vel.y = maxVel;
	}

	if (vel.y < -maxVel)
	{
		vel.y = -maxVel;
	}

	this.setVelocity(vel);
}
