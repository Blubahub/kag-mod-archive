#include "MapFlags.as"
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.getShape().getConsts().mapCollisions = false;
    this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().RotateBy(XORRandom(4) * 90, Vec2f(0, 0));
	this.getSprite().SetZ(-50); //background

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.server_setTeamNum(-1);
	
	this.Tag("builder always hit");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && blob.hasTag("flesh"))
	{
		this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 0.125;
			break;

		case Hitters::bomb:
			dmg *= 0.25f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 0.25f;
			break;

		case Hitters::bomb_arrow:
			dmg *= 0.25f;
			break;

		case Hitters::cata_stones:
			dmg *= 0.25f;
			break;
		case Hitters::crush:
			dmg *= 32.0f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 32.0f;
			break;
			
		case Hitters::builder: // boat ram
			dmg *= 4.0f;
			break;
			
		// case Hitters::bullet:
			// dmg = 0.0f;
			// break;
	}

	if (hitterBlob !is null)
	{
		this.server_Hit(hitterBlob, hitterBlob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, false);
	}
	
	return dmg;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}