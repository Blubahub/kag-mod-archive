#include "Hitters.as"
void onTick(CBlob@ this)
{
	if (this.hasTag("has grain"))
	{
		this.getCurrentScript().tickFrequency = 60;
		if(getNet().isServer())
		{
			CBlob@[] nearBlobs;
			this.getMap().getBlobsInRadius( this.getPosition(), 30.0f, @nearBlobs );
				
			for(int step = 0; step < nearBlobs.length; ++step)
			{
				if (nearBlobs[step] !is null)
				{
					CPlayer@ player = nearBlobs[step].getPlayer();
					if (player !is null)
					{
						nearBlobs[step].server_Heal(0.5f);
						this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.4f, Hitters::sword);
					}
					else if (nearBlobs[step].hasTag("vehicle"))
					{
						nearBlobs[step].server_Heal(0.1f);
						nearBlobs[step].server_Hit(this, this.getPosition(), Vec2f(0,0), 0.0f, Hitters::sword);
						this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.1f, Hitters::sword);
						printf("healing a blob on called: " + nearBlobs[step].getName());
					}
				}
			}
			this.server_Heal(0.2f);
		}
	}
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (this.hasTag("has grain"))
	{
		blob.setVelocity(blob.getVelocity()*1.2);
	}
}