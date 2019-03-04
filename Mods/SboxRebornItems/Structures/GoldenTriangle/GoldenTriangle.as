//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
    this.getShape().SetOffset(Vec2f(-1.25, 1.25));
	this.getShape().getConsts().waterPasses = true;
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;
    this.server_setTeamNum(-1); //allow anyone to break them  
    //this.Tag("place norotate");
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	
	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;		 
}



void MakeDamageFrame( CBlob@ this )
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ( (hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}




bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		break;
	case Hitters::saw:
		dmg *= 0.25;
		break;
	case Hitters::bomb:
	case Hitters::keg:
	case Hitters::arrow:
	case Hitters::cata_stones:
	default:
		dmg=0;
		break;
	}	
	return dmg;
}
