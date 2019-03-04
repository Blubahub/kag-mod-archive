
void onInit(CBlob@ this)
{	
	//this.Tag("invincible");
	this.Tag("volleyball");
	this.getShape().SetRotationsAllowed(true);
	//this.getShape().getConsts().net_threshold_multiplier = 2.0f;
    this.getShape().SetGravityScale(0.65f);
    //this.getShape().getConsts().collideWhenAttached = false;
}

void onDie(CBlob@ this)
{
	const Vec2f position = this.getPosition();

	for(u8 i = 0; i < 10; i++)
	{
		int timeout = 5+XORRandom(10);
		ParticlePixel(position, getRandomVelocity(90, 10, 360), color_white, true, timeout);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	CRules@ rules = getRules();

	if (detached is null && !rules.isGameOver())
	{
		//if (!detached.isKeyJustReleased(key_pickup))
		{

			if (rules.get_u8("servingTeam") == 0)
			{
				rules.set_u8("servingTeam", 1);
			}
			else
			{
				rules.set_u8("servingTeam", 0);
			}
			rules.set_u8("serve delay", 2*30);
			this.server_Die();
		}
	}
	else
	{
		getRules().set_bool("Wants New Serve", false);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{	
	if (this.isAttached() || !solid || getRules().isGameOver())
	{
		return;
	}

	if ( blob is null && !getRules().get_bool("Wants New Serve"))
	{
		Sound::Play("Whistle1.ogg");
		//this.server_HitMap(Vec2f_zero, Vec2f_zero, 0.0f, 0);
	}
}

//void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
//{
//	
//}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{	
	return !blob.hasTag("player");	
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}