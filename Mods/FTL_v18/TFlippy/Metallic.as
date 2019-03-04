f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.getSprite().PlaySound("room_hit_" + XORRandom(4), 1.0f, 1.0f);
	return damage;
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("no death effect")) 
	{	
		this.getSprite().PlaySound("metal_destruction_" + XORRandom(3), 1.0f, 1.0f);
		
		if (this.hasTag("room"))
		{
			CShape@ shape = this.getShape();
			u32 count = (shape.getWidth() * shape.getHeight()) / 64;

			for (int i = 0; i < count; i++)
			{
				CParticle@ particle = ParticleAnimated("RoomGibs", this.getPosition(), getRandomVelocity(0, XORRandom(100) * 0.025f, 360), XORRandom(360), 1, 0, XORRandom(4), Vec2f(16, 16), 60, 0.0f, false);
				
				if (particle !is null)
				{
					particle.timeout = 600 + XORRandom(600);
					particle.alivetime = 600 + XORRandom(600);
					particle.damping = 1;
					particle.bounce = 0.0f;
					particle.collides = true;
					particle.diesonanimate = false;
					particle.fastcollision = true;
					particle.fadeout = false;
					particle.Z = 5;
				}
			}
		}
	}
}