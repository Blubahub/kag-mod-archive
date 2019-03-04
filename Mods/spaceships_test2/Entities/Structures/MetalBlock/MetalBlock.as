#include "Hitters.as"
#include "MakeMat.as"
void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
    //this.set_TileType("background tile", CMap::tile_castle_back);
    //this.server_setTeamNum(this.getTeamNum()+100); //allow anyone to break them
	this.Tag("place norotate");
	this.Tag("place ignore facing");
	//transfer fire to underlying tiles
	this.Tag("builder always hit");
	this.Tag("stone");
	this.Tag("large");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}
/*
void onTick(CBlob@ this)
{
	if(this.hasTag("slave"))
	{
		u16 parentID = this.get_u16("parentID");
		CBlob@ parent = getBlobByNetworkID(parentID);
		if(parent !is null)
		{
			Vec2f pos = parent.getPosition();
			Vec2f offset = this.get_Vec2f("block_offset");
			f32 dir = parent.getAngleDegrees();
			//offset.RotateBy(dir);
			s16 facing = parent.isFacingLeft() ? -1 : 1;
			offset.x *=facing;
			Vec2f pos2 = pos + offset;
			pos2.RotateBy(dir, pos);
			this.setPosition(pos2);
			this.setAngleDegrees(dir);
			//print(""+ dir);
		}
	}
}*/
//update nearby blocks when destroyed
void onDie(CBlob@ this)
{	
	//print(""+ (getNet.isServer() ? "serverside" : "not server"));
	CMap@ map = getMap();

	CBlob@[] blobsInRadius;
	Vec2f pos = this.getPosition();
	if (map.getBlobsInRadius( pos, 32.0, @blobsInRadius )) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null &&b.getName() == this.getName())
			{
				//b.server_Die();
				//Smooth(b, false);
				//print("smoothing..");
			}
		}
	}
}
/*
//block smoothing logic
void Smooth(CBlob@ blob, bool again)
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
					Smooth(b, false);
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
	if (!lefttaken && righttaken && !uptaken && downtaken)
	{
			sprite.SetFrame(3);
			blob.setAngleDegrees(0);
	}

	else if (lefttaken && !righttaken && !uptaken && downtaken)
	{
			sprite.SetFrame(3);
			blob.setAngleDegrees(90);
	}

	else if (lefttaken && !righttaken && uptaken && !downtaken)
	{
			sprite.SetFrame(3);
			blob.setAngleDegrees(180);
	}

	else if (!lefttaken && righttaken && uptaken && !downtaken)
	{
			sprite.SetFrame(3);
			blob.setAngleDegrees(270);
	}
	else if (lefttaken && righttaken && uptaken && downtaken)
	{
			sprite.SetFrame(2);
			blob.setAngleDegrees(0);
	}	


	else if (lefttaken && righttaken && !uptaken && downtaken)
	{
			sprite.SetFrame(1);
			blob.setAngleDegrees(0);
	}
	else if (lefttaken && !righttaken && uptaken && downtaken)
	{
			sprite.SetFrame(1);
			blob.setAngleDegrees(90);
	}
	else if (lefttaken && righttaken && uptaken && !downtaken)
	{
			sprite.SetFrame(1);
			blob.setAngleDegrees(180);
	}
	else if (!lefttaken && righttaken && uptaken && downtaken)
	{
			sprite.SetFrame(1);
			blob.setAngleDegrees(270);
	}


	else if (!lefttaken && !righttaken && !uptaken && downtaken)
	{
			sprite.SetFrame(5);
			blob.setAngleDegrees(0);
	}
	else if (lefttaken && !righttaken && !uptaken && !downtaken)
	{
			sprite.SetFrame(5);
			blob.setAngleDegrees(90);
	}
	else if (!lefttaken && !righttaken && uptaken && !downtaken)
	{
			sprite.SetFrame(5);
			blob.setAngleDegrees(180);
	}
	else if (!lefttaken && righttaken && !uptaken && !downtaken)
	{
			sprite.SetFrame(5);
			blob.setAngleDegrees(270);
	}


	else if (!lefttaken && !righttaken && uptaken && downtaken)
	{
			sprite.SetFrame(4);
			blob.setAngleDegrees(90);
	}

	else if (lefttaken && righttaken && !uptaken && !downtaken)
	{
			sprite.SetFrame(4);
			blob.setAngleDegrees(0);
	}

}*/
void onSetStatic(CBlob@ this, const bool isStatic)
{
	this.Tag("ready");
	//Smooth(this, true);
	this.getSprite().SetFrame(0);

}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (damage>this.getHealth()) this.getSprite().PlaySound("/destroy_gold"); else this.getSprite().PlaySound("/dig_stone");
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		break;
	case Hitters::saw:
		dmg *= 1.5f;
		break;		
	case Hitters::bomb:
	case Hitters::keg:
	case Hitters::arrow:
	case Hitters::cata_stones:
	default:
		dmg=dmg;
		break;
	}		
	return dmg;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if(blob.getNetworkID() == this.get_u16("parentID")) return false;
	return true;
}