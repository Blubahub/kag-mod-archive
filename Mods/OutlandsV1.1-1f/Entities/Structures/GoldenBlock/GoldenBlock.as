#include "Hitters.as";
#include "MakeMat.as";
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.Tag("blocks water");
    this.getSprite().getConsts().accurateLighting = true;
    this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");
	this.server_setTeamNum(33);
	this.getSprite().SetZ(100);
	this.set_TileType("background tile", CMap::tile_customblockhelper);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/GBMMPixel.png", 1, Vec2f(4,4));
	this.SetMinimapRenderAlways(true);
}

/*block smoothing logic
void MapUpdate(CBlob@ blob, bool again)
{
	CSprite@ sprite = blob.getSprite();
	Vec2f pos = blob.getPosition();
	CMap@ map = getMap();
	bool uptaken = false;
	bool lefttaken = false;
	bool righttaken = false;
	bool downtaken = false;
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius( pos, 32.0, @blobsInRadius )) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null && b.getName() == blob.getName())
			{
				if(again)
				{
					MapUpdate(b, false);
				}
				if(b.getPosition().x == blob.getPosition().x-8 && b.getPosition().y == blob.getPosition().y)
				{
					lefttaken = true;
				}				

				if(b.getPosition().x == (blob.getPosition().x+8) && b.getPosition().y == blob.getPosition().y)
				{
					righttaken = true;
				}

				if(b.getPosition().x == blob.getPosition().x &&b.getPosition().y == (blob.getPosition().y-8))
				{
					uptaken = true;
				}

				if(b.getPosition().x == blob.getPosition().x &&b.getPosition().y == (blob.getPosition().y+8))
				{
					downtaken = true;
				}
			}
		}
	}
	if (lefttaken && righttaken && uptaken && downtaken)
	{
		blob.SetMinimapOutsideBehaviour(CBlob::minimap_none);
		blob.SetMinimapVars("GUI/Minimap/GBMMPixel.png", 1, Vec2f(4,4));
		blob.SetMinimapRenderAlways(true);
	}
	else
	{
		blob.SetMinimapOutsideBehaviour(CBlob::minimap_none);
		blob.SetMinimapVars("GUI/Minimap/GBMMPixel.png", 0, Vec2f(4,4));
		blob.SetMinimapRenderAlways(true);
	}
}
void onSetStatic(CBlob@ this, const bool isStatic)
{
	MapUpdate(this, true);
}*/

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
	if(dmg>(this.getHealth()+0.4)){
	this.getSprite().PlaySound( "/destroy_gold" );
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	TileType t = map.getTile(pos).type;
	map.server_SetTile(pos, 0);}
	else
	this.getSprite().PlaySound( "/dig_stone" );
	MakeMat(this, worldPoint, "mat_gold", 2 * dmg);
    return dmg;
	
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	this.getSprite().SetFacingLeft(false);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}