// BF_DoorSwing script

#include "Hitters.as"
#include "FireCommon.as"
#include "MapFlags.as"

void onInit( CBlob@ this )
{
    this.getShape().SetRotationsAllowed( false );
    this.getShape().getConsts().waterPasses = true;
    this.getSprite().getConsts().accurateLighting = true;
    this.set_s16( burn_duration , 300 );
    this.Tag(spread_fire_tag);
    this.Tag("door");
    this.getCurrentScript().tickFrequency = 0;
}

bool isOpen( CBlob@ this )
{
    return !this.getShape().getConsts().collidable;
}

void setOpen( CBlob@ this, bool open, bool faceLeft = false )
{
    CSprite@ sprite = this.getSprite();
    if (open)
    {
        sprite.SetZ(-100.0f);
        sprite.SetAnimation( "open" );
        this.getShape().getConsts().collidable = false;
        this.getCurrentScript().tickFrequency = 3;
        sprite.SetFacingLeft( faceLeft ); // swing left or right
        Sound::Play( "/DoorOpen.ogg", this.getPosition() );
    }
    else
    {
        sprite.SetZ(100.0f);
        sprite.SetAnimation( "close" );
        this.getShape().getConsts().collidable = true;
        this.getCurrentScript().tickFrequency = 0;
        Sound::Play( "/DoorClose.ogg", this.getPosition() );
    }
}

void onTick(CBlob@ this)
{
    const uint count = this.getTouchingCount();
    for (uint step = 0; step < count; ++step)
    {
        CBlob@ blob = this.getTouchingByIndex(step);
        if(blob is null) continue;

        if (canOpenDoor(this, blob) && !isOpen(this))
        {
            Vec2f pos = this.getPosition();
            Vec2f other_pos = blob.getPosition();
            Vec2f direction = Vec2f(1,0);
            direction.RotateBy(this.getAngleDegrees());
            setOpen(this, true, ( (pos - other_pos) * direction ) < 0.0f );
        }
    }
	// close it
	if (isOpen(this) && canClose( this ))
	{
		setOpen(this, false);
	}
}


bool canClose( CBlob@ this )
{
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			collided++;
		}
	}
	return collided == 0;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    if (blob !is null)
    {
        this.getCurrentScript().tickFrequency = 3;
    }
}

void onEndCollision( CBlob@ this, CBlob@ blob )
{
    if (blob !is null)
    {
        if (canClose(this))
        {
			if (isOpen( this ))
			{
				setOpen(this, false);
			}
			this.getCurrentScript().tickFrequency = 0;
        }
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

bool canOpenDoor( CBlob@ this, CBlob@ blob )
{
    if ((blob.getShape().getConsts().collidable) && //solid				 // vvv lets see
        (blob.getRadius() > 2.0f) && //large
		(this.getTeamNum() == 255 || this.getTeamNum() == blob.getTeamNum() ) &&
		(blob.hasTag("player") || blob.hasTag("vehicle"))) //tags that can open doors
    {
        Vec2f direction = Vec2f(0,-1);
		direction.RotateBy(this.getAngleDegrees());

		Vec2f blobPress;
		if (blob.getControls() !is null)
		{
			if (blob.isKeyPressed(key_left )) blobPress.x -= 1.0f;
			if (blob.isKeyPressed(key_right)) blobPress.x += 1.0f;
			if (blob.isKeyPressed(key_up   )) blobPress.y -= 1.0f;
			if (blob.isKeyPressed(key_down )) blobPress.y += 1.0f;
		}
		else
		{
			blobPress = blob.getVelocity();
		}

		blobPress.Normalize();

		if (Maths::Abs(blobPress * direction) < 0.9f )
		{
			Vec2f displacement = this.getPosition() - blob.getPosition();
			if (blobPress * displacement > 0.8f)
			{
				return true;
			}
		}

    }
    return false;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (isOpen(this))
		return false;

	if (canOpenDoor(this, blob))
	{
		Vec2f pos = this.getPosition();
		Vec2f other_pos = blob.getPosition();
		Vec2f direction = Vec2f(1,0);
		direction.RotateBy(this.getAngleDegrees());
		setOpen(this, true, ( (pos - other_pos) * direction ) < 0.0f );
		return false;
	}
	return true;
}