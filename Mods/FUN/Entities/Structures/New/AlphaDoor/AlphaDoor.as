const int ticksToClose = 1 * 30; //1 sec

void onInit(CBlob@ this)
{
	this.set_u32("ticks to close", ticksToClose);
	this.set_bool("sound", false);
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	bool overlaps = this.get_bool("overlaps");
	CBlob@[] blobsInRadius;
	const int team = this.getTeamNum();
	if (map.getBlobsInRadius( this.getPosition(), this.getRadius() * 2.0f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null && b.hasTag("player") && (b.isKeyPressed(key_left) || b.isKeyPressed(key_right)))
			{
				if (b.getTeamNum() == team && this.isOverlapping(b))
				{
					this.set_bool("overlaps", true);
					this.getSprite().SetAnimation("hidden");
					if (b.isKeyPressed(key_left) || b.isKeyPressed(key_right)) 
						Open(this);
				}
				else if (!this.isOverlapping(b))
					this.set_bool("overlaps", false);
			}
		}
	}
	if (this.hasTag("opened") && !overlaps)
	{
		int ticks = this.get_u32("ticks to close");
		if (ticks >= 0)
		{
			ticks--;
			this.set_u32("ticks to close", ticks);
		}
		else
		{
			this.Untag("opened");
			this.set_u32("ticks to close", ticksToClose);
			Close(this);
		}
	}
	
	CBlob@ upBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(0.0f, -8.0f) ) ;
	CBlob@ downBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(0.0f, 8.0f) ) ;
	CBlob@ rightBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(8.0f, 0.0f) ) ;
	CBlob@ leftBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(-8.0f, 0.0f) ) ;
	if (!overlaps && this.getHealth() > 0)
	{
		if (downBlob !is null && downBlob.getName() == "alpha_door" && !downBlob.get_bool("overlaps"))
		{
			downBlob.getSprite().SetAnimation("down");
		}
	}
}

void Open(CBlob@ this)
{
	bool playSound = this.get_bool("sound");
	this.getShape().getConsts().collidable = false;
	this.getSprite().SetZ(-50);
	this.getSprite().SetAnimation("hidden");
	this.Tag("opened");
	
	CBlob@ upBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(0.0f, -8.0f) ) ;
	CBlob@ downBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(0.0f, 8.0f) ) ;
	CBlob@ rightBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(8.0f, 0.0f) ) ;
	CBlob@ leftBlob = getMap().getBlobAtPosition( this.getPosition() + Vec2f(-8.0f, 0.0f) ) ;
	CBlob@[] blobs = {upBlob, downBlob, rightBlob, leftBlob};
	for (int i = 0; i < blobs.length; i++)
	{
		if (blobs[i] !is null && isDoor(blobs[i]))
		{
			blobs[i].set_u32("ticks to close", ticksToClose);
		}
	}
}

void Close(CBlob@ this)
{
	this.getShape().getConsts().collidable = true;
	this.getSprite().SetZ(100); 
	this.getSprite().SetAnimation("default");
	this.Untag("opened");
}

bool isDoor(CBlob@ blob)
{
	if (blob.getConfig() == "alpha_door")
		return true;
	else return false;
}

