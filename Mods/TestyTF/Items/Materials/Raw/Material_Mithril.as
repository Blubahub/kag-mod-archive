#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(24.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));
	
	this.getCurrentScript().tickFrequency = (125 / Maths::Max(1, (this.getQuantity() / 2))) * 10.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater | Script::tick_not_ininventory;
}

void onTick(CBlob@ this)
{	
	if (this.getQuantity() < 30) return;

	this.getCurrentScript().tickFrequency = (125 / Maths::Max(1, (this.getQuantity() / 2))) * 10.0f;
	
	// print("Freq: " + this.getCurrentScript().tickFrequency + "; Quantity: " + this.getQuantity());
	
	f32 radius = 256 *  this.getQuantity() / 250.0f;
	this.SetLightRadius(radius * 0.35f);
	
	if (this.getQuantity() < 60) return;
	
	if (XORRandom(100) < 30) 
	{
		if (getNet().isClient())
		{
			// I know it's unrealistic, but people kept complaining about 'random' damage. Hopefully this'll give them the idea. :v
			// ...Let's say that KAG players have a built-in Geiger counter.
			// -- TFlippy
			
			this.getSprite().PlaySound("geiger" + XORRandom(3) + ".ogg", 0.7f, 1.0f);
		}
	
		if (getNet().isServer())
		{
			this.server_SetQuantity(this.getQuantity() - 1);
		
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;
					
					f32 distMod = Maths::Max(0, (1 - ((this.getPosition() - blob.getPosition()).Length() / radius)));
					if (XORRandom(100) < 100.0f * distMod) this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::burn, true);
				}
			}
		}
	}
}