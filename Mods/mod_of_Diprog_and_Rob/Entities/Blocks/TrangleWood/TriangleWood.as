//trap block script for devious builders
//bool makeFire;
#include "Hitters.as";
#include "MakeMat.as";
#include "BlockParticle.as";

void onInit(CBlob@ this)
{
	this.Tag("blocks water");
    this.getSprite().getConsts().accurateLighting = true;
	this.server_setTeamNum(-1);
	this.getSprite().SetZ(100);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick( CBlob@ this )
{
	this.getShape().SetOffset(Vec2f(-1.0,1.0));
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){

	
	const f32 vellen = velocity.Length();
	Particle (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage), 132, 71, 21);
	if (this.getHealth() > 0.2) Sound::Play( "/WoodHit.ogg", worldPoint );	
	
	f32 dmg = damage;

    switch(customData)
    {
    case Hitters::builder:
        dmg *= 1.5f;
        break;

	case Hitters::sword:
		if (dmg <= 1.0f) {
			dmg = 0.25f;
		}
		else {
			dmg *= 0.25f;
		}
		break;

    case Hitters::bomb:
        dmg *= 1.40f;
        break;
        
    case Hitters::burn:
		dmg = 0.2f;
		break;

    case Hitters::explosion:
        dmg *= 2.0f;
        break;
    
    case Hitters::bomb_arrow:
		dmg *= 4.0f;
		break;

	case Hitters::stab:
		dmg *= 0.0f;
		break;

	case Hitters::cata_stones:
		dmg *= 0.0f;
		break;
	case Hitters::crush:
		dmg *= 0.0f;
		break;		 
	case Hitters::flying: // boat ram
		dmg *= 0.0f;
		break;
    }

    return dmg;
	
}
void onDie(CBlob@ this)
{
	Sound::Play( "/WoodDestroy.ogg", this.getPosition() );	
	DieParticle (this.getPosition(), 132, 71, 21);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}