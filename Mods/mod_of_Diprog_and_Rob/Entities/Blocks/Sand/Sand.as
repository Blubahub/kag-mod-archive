#include "Hitters.as";
#include "BlockParticle.as";

void onInit(CBlob@ this)
{
	this.Tag("blocks water");
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;
    this.Tag("place norotate");
	this.getSprite().SetZ(100);
	this.getShape().getConsts().mapCollisions = true;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){

	Sound::Play( "/SandHit.ogg", worldPoint );	
	const f32 vellen = velocity.Length();
	Particle (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage), 255, 178, 107);
		
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
		dmg = 0.0f;
		break;

    case Hitters::explosion:
        dmg *= 2.0f;
        break;
    
    case Hitters::bomb_arrow:
		dmg *= 4.0f;
		break;

	case Hitters::arrow:
	case Hitters::stab:
		dmg *= 0.1f;
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
	Sound::Play( "/DestroySand.ogg", this.getPosition() );	
}