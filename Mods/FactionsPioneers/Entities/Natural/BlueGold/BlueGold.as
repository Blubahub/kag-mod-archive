#include "Hitters.as"
#include "MakeMat.as"

void onInit(CBlob@ this)
{
	this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
	this.Tag("place norotate");
	this.Tag("stone");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.getSprite().PlaySound( "/dig_stone" );
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		break;
	default:
		dmg=0;
		break;
	}		
	return dmg;
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound( "/destroy_gold" );
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}