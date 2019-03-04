// Made by TFlippy

#include "Hitters.as";
#include "Explosion.as";
#include "ParticleSparks.as";
#include "MakeDustParticle.as";

const Vec2f[] dir =
{
	Vec2f(8, 0),
	Vec2f(-8, 0),
	Vec2f(0, 8),
	Vec2f(0, -8),
};

void onInit(CBlob@ this)
{
	this.getShape().getConsts().collideWhenAttached = false;
	this.getCurrentScript().tickFrequency = 2;
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() < 2 || !this.hasTag("fired")) return;
	
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	
	CMap@ map = getMap();
	
	f32 magnitude = Maths::Sqrt(vel.x * vel.x + vel.y * vel.y);
	
	if (magnitude > 1)
	{
		TileType tile = map.getTile(pos).type;
		map.server_DestroyTile(pos, 1.0f);
		
		CBlob@[] blobs;
		map.getBlobsInRadius(pos, 8, @blobs);
		
		for (int i = 0; i < blobs.length; i++) 
		{
			if (blobs[i].getName() != "cannonball") this.server_Hit(blobs[i], pos, Vec2f_zero, magnitude * 3, Hitters::cata_boulder, true);
			// print("Damage:" + magnitude * 3);
		}
	}
	else
	{
		this.Untag("fired");
		// print("Untagged");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this.getTickSinceCreated() < 2 || !this.hasTag("fired")) return;

	CMap@ map = getMap();
	
	Vec2f vel = this.getVelocity();
	
	f32 magnitude = Maths::Sqrt(vel.x * vel.x + vel.y * vel.y);
	
	for (int j = 0; j < 4 + XORRandom(2); j++)
	{	
		Vec2f offset = Vec2f((XORRandom(4) - 2) * 8,(XORRandom(2) - 1) * 8) + this.getPosition();
	
		for (int i = 0; i < dir.length; i++)
		{
			TileType tile = map.getTile(offset + dir[i]).type;
			map.server_DestroyTile(offset + dir[i], magnitude);
			// print("Tile damage: " +  magnitude);
		}
	}
}