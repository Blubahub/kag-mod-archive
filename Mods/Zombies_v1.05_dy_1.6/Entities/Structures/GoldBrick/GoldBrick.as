#include "Hitters.as"
#include "MakeMat.as"
void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
    //this.set_TileType("background tile", CMap::tile_castle_back);
    this.server_setTeamNum(-1); //allow anyone to break them
	this.Tag("place norotate");
	this.Tag("stone");
	this.Tag("large");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (damage>this.getHealth()) this.getSprite().PlaySound("/destroy_gold"); else this.getSprite().PlaySound("/dig_stone");
	f32 dmg_mod = 1.5f;
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		if (getNet().isServer()) MakeMat( this, hitterBlob.getPosition(), "mat_gold", 4 * damage );
		break;
	case Hitters::saw:
		if (hitterBlob.hasTag("player"))
		dmg *= 0.25;
		else
		dmg *= 3.0/dmg_mod;
		break;		
	case Hitters::sword:
        dmg = 0.0f;
        break;
    case Hitters::bomb:
        dmg *= 0.5f/dmg_mod;
        break;

    case Hitters::keg:
    case Hitters::explosion:
        dmg *= 0.75f/dmg_mod;
        break;
        
    case Hitters::bomb_arrow:
        dmg *= 4.0f/dmg_mod;
        break;

    case Hitters::arrow:
    case Hitters::stab:
        dmg = 0.0f/dmg_mod;
        break;

    case Hitters::cata_stones:
        dmg *= 2.5f/dmg_mod;
        break;
    case Hitters::crush:
        dmg *= 2.0f/dmg_mod;
        break;      

    case Hitters::flying: // boat ram
        dmg *= 0.25f/dmg_mod;
        break; 
	default:
		dmg=0;
		break;
	}		
	return dmg;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}