#include "Hitters.as";
#include "BlockParticle.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(200);
	this.Tag("blocks water");
	this.getShape().SetRotationsAllowed( false );
	this.getSprite().getConsts().accurateLighting = true;
	this.Tag("place norotate");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onTick(CBlob@ this)
{
	this.getSprite().SetZ(200);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){

	
	const f32 vellen = velocity.Length();
	if (!this.isAttached())
	{
		Particle (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage), 37, 12, 5);
		if (this.getHealth() > 0.2) Sound::Play( "/FarmingBlockHit.ogg", worldPoint );	
	}
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
	if (!this.isAttached())
	{
		Sound::Play( "/FarmingBlockDestroy.ogg", this.getPosition() );	
		DieParticle (this.getPosition(), 37, 12, 5);
	}
}