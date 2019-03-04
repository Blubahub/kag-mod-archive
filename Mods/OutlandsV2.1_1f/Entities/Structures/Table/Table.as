#include "Hitters.as";
#include "FireCommon.as";

void onInit(CBlob@ this)
{
    //this.getShape().SetOffset(Vec2f(-0.0, 0.0));
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetRelativeZ(-10.0f);
	this.getShape().getConsts().waterPasses = true;

	this.Tag("place norotate");

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 70, false);
	shape.SetRotationsAllowed(false);

	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

}

void onDie(CBlob@ this)
{	
	//print(""+ (getNet.isServer() ? "serverside" : "not server"));
	CMap@ map = getMap();

	CBlob@[] blobsInRadius;
	Vec2f pos = this.getPosition();
	this.Tag("dead");
	if (map.getBlobsInRadius( pos, 32.0, @blobsInRadius )) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null &&b.getName() == this.getName())
			{
				//b.server_Die();
				Update(b, false);
				//print("smoothing..");
			}
		}
	}
}

void Update(CBlob@ blob, bool again)
{
	CSprite@ sprite = blob.getSprite();
	Vec2f pos = blob.getPosition();
	CMap@ map = getMap();
	bool lefttaken = false;
	bool righttaken = false;
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius( pos, 32.0, @blobsInRadius )) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			bool dead = b.hasTag("dead");
			if (b !is null && b.getName() == blob.getName())
			{
				if(again)
				{
					Update(b, false);
				}
				if(b.getPosition().x == blob.getPosition().x-8 && b.getPosition().y == blob.getPosition().y && !dead)
				{
					lefttaken = true;
				}				

				if(b.getPosition().x == blob.getPosition().x+8 && b.getPosition().y == blob.getPosition().y && !dead)
				{
					righttaken = true;
				}
			}
		}
	}
	if (lefttaken && righttaken)
	{
		sprite.SetFrame(2);
		sprite.SetFacingLeft(false);
	}
	else if (!lefttaken && righttaken)
	{
		sprite.SetFrame(1);
		sprite.SetFacingLeft(false);
	}
	else if (lefttaken && !righttaken)
	{
		sprite.SetFrame(3);
		sprite.SetFacingLeft(false);
	}
	else if (!lefttaken && !righttaken)
	{
		sprite.SetFrame(0);
		sprite.SetFacingLeft(false);
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	Update(this, true);
	this.getSprite().PlaySound("/build_wood.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}