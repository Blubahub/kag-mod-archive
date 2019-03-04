//TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.getSprite().getConsts().accurateLighting = true;
	this.set_bool("open", false);

	this.Tag("place norotate");
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.set_TileType("background tile", CMap::tile_castle_back);

	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (!isOpen(this))
	{
		MakeDamageFrame(this);
	}
}

void MakeDamageFrame( CBlob@ this )
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ( (hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open)
{
	CSprite@ sprite = this.getSprite();
	this.getShape().checkCollisionsAgain = true;

	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.animation.frame = 3;
		this.getShape().getConsts().collidable = false;

		// drop boulder on trap blocks
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			CBlob@ blob = this.getTouchingByIndex(step);
			blob.getShape().checkCollisionsAgain= true;
		}
	}
	else
	{
		sprite.SetZ(100.0f);
		MakeDamageFrame(this);
		this.getShape().getConsts().collidable = true;
	}

	//TODO: fix flags sync and hitting
	//SetSolidFlag(this, !open);

	if (this.getTouchingCount() <= 1 && openRecursion < 5)
	{
		SetBlockAbove( this, open );
		openRecursion++;
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (isOpen(this))
	{
		return false;
	}
	else if (blob.getTeamNum() == this.getTeamNum())
	{
		return true;
	}
	else if (opensThis(this, blob))
	{
		return false;
	}
	return true;
}

bool opensThis(CBlob@ this, CBlob@ blob)
{
	return blob.getTeamNum() != this.getTeamNum() && !isOpen(this) && blob.isCollidable() && (blob.hasTag("player") || blob.hasTag("vehicle")) && blob.getPosition().y < this.getPosition().y;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (opensThis(this,blob))
		{
			openRecursion = 0;
			setOpen(this, true);

			/* simple check
			// this is lumped into opensThis
			Vec2f pos = this.getPosition();
			Vec2f b_pos = blob.getPosition();
			if (b_pos.y < pos.y)
			{
				openRecursion = 0;
				setOpen(this, true);
			}
			*/

			/* advanced check, this might not be necessary
			CMap@ map = getMap();
			if (map !is null)
			{
				Vec2f offset = this.getPosition() + Vec2f(0, -8);
				CBlob@[] triggering;
				map.getBlobsAtPosition(offset, @triggering);
				for (uint i = 0; i < triggering.length; i++)
				{
					CBlob@ t_blob = triggering[i];
					if (t_blob.getNetworkID() == blob.getNetworkID())
					{
						openRecursion = 0;
						setOpen(this, true);
						break;
					}
				}
			}
			*/
		}
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		bool touching = false;
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			CBlob@ blob = this.getTouchingByIndex(step);
			if (blob.isCollidable())
			{
				touching = true;
				break;
			}
		}

		if (!touching)
		{
			setOpen(this, false);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder)
	{
		damage *= 2;
	}
	return damage;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void SetBlockAbove(CBlob@ this, const bool open)
{
	CBlob@ blobAbove = getMap().getBlobAtPosition(this.getPosition() + Vec2f(0.0f, -8.0f));
	if (blobAbove !is null && blobAbove.getName() == "trap_block")
	{
		setOpen(blobAbove, open);
	}
}