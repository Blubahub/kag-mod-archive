#include "Hitters.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
    switch(customData)
    {
    case Hitters::builder:
        dmg *= 1.5f;
        break;
	case Hitters::sword:
		dmg *= 0.0f;
		break;
    case Hitters::bomb:
        dmg *= 0.0f;
        break;
    case Hitters::burn:
		dmg *= 0.0f;
		break;
    case Hitters::explosion:
        dmg *= 0.2f;
        break;
    case Hitters::bomb_arrow:
		dmg *= 0.1f;
		break;
	case Hitters::stab:
		dmg *= 0.0f;
		break;
	case Hitters::cata_stones:
		dmg *= 0.8f;
		break;
	case Hitters::crush:
		dmg *= 0.0f;
		break;		 
	case Hitters::flying:
		dmg *= 0.0f;
		break;
	case Hitters::saw:
		dmg *= 0.0f;
		break;
	case Hitters::bite:
		dmg *= 0.0f;
		break;
	case Hitters::arrow:
		dmg *= 0.0f;
		break;
    }
	if(dmg>(this.getHealth()+0.4))
	this.getSprite().PlaySound( "/destroy_gold" );
	else
	this.getSprite().PlaySound( "/dig_stone" );
    return dmg;
	
}