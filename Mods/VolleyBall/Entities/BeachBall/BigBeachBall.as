
void onInit(CBlob@ this)
{	
	this.Tag("invincible");
	this.getShape().SetRotationsAllowed(true);
    this.getShape().SetGravityScale(0.45f);
}

void onDie(CBlob@ this)
{
	const Vec2f position = this.getPosition();

	for(u8 i = 0; i < 10; i++)
	{
		int timeout = 5+XORRandom(10);
		ParticlePixel(position, getRandomVelocity(90, 10, 360), color_white, true, timeout);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}