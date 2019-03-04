// TrapBlock.as

//#include "Hitters.as";
//#include "MapFlags.as";

//int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	//this.set_bool("open", false);
	this.Tag("place norotate");
	this.getSprite().SetZ(400);
	//this.getShape().SetOffset(Vec2f(0, 3));

	//block knight sword
	//this.Tag("blocks sword");
	//this.Tag("blocks water");

	//this.set_TileType("background tile", CMap::tile_castle_back);
/*
	if (getNet().isServer())
	{
		dictionary harvest;
		harvest.set('mat_stone', 4);
		this.set('harvest', harvest);
	}
*/
	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

//TODO: fix flags sync and hitting
/*void onDie( CBlob@ this )
{
	SetSolidFlag(this, false);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}*/

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	MakeDamageFrame(this);
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = 0;
	if(hp > full_hp*0.75)
		frame = XORRandom(3);
	else if(hp > full_hp*0.5)
		frame = 3;
	else if(hp > full_hp*0.25)
		frame = 4;
	else if(hp <= full_hp*0.25)
		frame = 5;
	this.getSprite().animation.frame = frame;
}
/*
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.getTeamNum() == this.getTeamNum())
	{
		return !isOpen(this);
	}
	else
	{
		return !opensThis(this, blob) && !isOpen(this);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (opensThis(this, blob))
	{
		openRecursion = 0;
		setOpen(this, true);
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob is null) return;

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
*/
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}