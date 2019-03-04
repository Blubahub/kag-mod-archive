// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";
#include "Ally.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.set_bool("open", false);
	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.set_TileType("background tile", CMap::tile_castle_back);

	if (getNet().isServer())
	{
		dictionary harvest;
		harvest.set('mat_stone', 4);
		this.set('harvest', harvest);
	}

	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.set_u8("fake_colour",this.getTeamNum());
	this.set_u8("sprite_colour",this.getTeamNum());
}

void onTick( CBlob@ this )
{
	if(!this.isAttached())
	for(int i = 0; i < this.getTouchingCount();i++){
		CBlob @b = this.getTouchingByIndex(i);
		if(b !is null)
		if(checkAlly(this.getTeamNum(), b.getTeamNum()) == Team::Ally && b.isKeyPressed(keys::key_down)){
			if(!isOpen(this))setOpen(this, true, true);
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (!isOpen(this))
	{
		MakeDamageFrame(this);
	}
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ((hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open, bool ally)
{
	CSprite@ sprite = this.getSprite();

	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.animation.frame = 3;
		this.getShape().getConsts().collidable = false;

		const uint touching = this.getTouchingCount();
		for (uint i = 0; i < touching; i++)
		{
			CBlob@ t = this.getTouchingByIndex(i);
			if (t is null) continue;

			t.AddForce(Vec2f_zero); // forces collision checks again
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

	if(!ally)
	if (this.getTouchingCount() <= 1 && openRecursion < 5)
	{
		SetBlockAbove(this, open);
		openRecursion++;
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob !is null)
	if(blob.getShape() !is null)
	if(blob.getShape().getConsts() !is null)
	if(!blob.getShape().getConsts().mapCollisions)return false;
	
	//if (blob.getTeamNum() == this.getTeamNum())
	//{
	//	return !isOpen(this);
	//}
	//else
	{
		return !opensThis(this, blob) && !isOpen(this);
	}
}

bool opensThis(CBlob@ this, CBlob@ blob)
{
	if(blob !is null)
	if(blob.getShape() !is null)
	if(blob.getShape().getConsts() !is null)
	if(!blob.getShape().getConsts().mapCollisions)return false;
	
	bool team = false;
	
	if(checkAlly(this.getTeamNum(), blob.getTeamNum()) == Team::Ally)team = true;
	
	return ((!team || blob.isKeyPressed(keys::key_down) || isUnderGoingUp(this,blob)) &&
	        !isOpen(this) && blob.isCollidable() &&
	        (blob.hasTag("player") || blob.hasTag("vehicle")));
}

bool isUnderGoingUp(CBlob@ this, CBlob@ blob){
	Vec2f pos = this.getPosition();
	Vec2f otherpos = blob.getPosition();
	
	if(pos.y+8 < otherpos.y)return true;
	
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (opensThis(this, blob))
	{
		openRecursion = 0;
		setOpen(this, true, checkAlly(this.getTeamNum(), blob.getTeamNum()) == Team::Ally);
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
		setOpen(this, false, false);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void SetBlockAbove(CBlob@ this, const bool open)
{
	CBlob@ blobAbove = getMap().getBlobAtPosition(this.getPosition() + Vec2f(0, -8));
	if (blobAbove is null || blobAbove.getName() != "trap_block") return;

	setOpen(blobAbove, open, false);
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	if(blob is null)return;
	
	if(blob.get_u8("fake_colour") != blob.get_u8("sprite_colour")){
		this.ReloadSprites(blob.get_u8("fake_colour"), 0);
		blob.set_u8("sprite_colour",blob.get_u8("fake_colour"));
	}
}