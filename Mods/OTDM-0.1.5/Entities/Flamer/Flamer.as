
void onInit(CBlob@ this)
{
	this.Tag("no falldamage");
	this.set_u32("ammunition", 250);
	this.set_u32("reloadgun", 2);
	this.set_u32("round", 1);
	this.getShape().getConsts().collideWhenAttached = true;

	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1);
	this.getCurrentScript().runFlags |= Script::tick_attached;

}

void onTick(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	if(holder is null) return;

	Vec2f ray = holder.getAimPos() - this.getPosition();
	ray.Normalize();

	f32 angle = ray.Angle();
	angle -= 0;
	if (this.isFacingLeft())
	{
		this.setAngleDegrees((-angle)-180);
	}
	if (!this.isFacingLeft())
	{
		this.setAngleDegrees(-angle);
	}

	u32 round = this.get_u32("round");
	u32 ammunition = this.get_u32("ammunition");
	u32 reloadgun = this.get_u32("reloadgun");

	if(reloadgun > 0 && round <= 0)
	{
		reloadgun = (reloadgun - 1);
	}	

	if(reloadgun <= 0&& round <= 0)
	{
		round = 1;
		reloadgun = 2;
	}

	bool pressed_a1 = point.isKeyPressed(key_action1);
	if (ammunition < 1)
	{
		this.server_Die();
	}
	if (pressed_a1 && round > 0 && ammunition > 0)

	{	
    	this.getSprite().SetAnimation("default");
    	this.getSprite().SetAnimation("fire");

		//print(""+round);
		if (this !is null)
		{
			round = (round -1);
			Vec2f pos = this.getPosition();
			//Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));

			CBlob@ bullet = server_CreateBlob("flame", this.getTeamNum(), this.getPosition());
			CBlob@ bullet2 = server_CreateBlob("flame", this.getTeamNum(), this.getPosition());
			CBlob@ bullet3 = server_CreateBlob("flame", this.getTeamNum(), this.getPosition());
			CBlob@ bullet4 = server_CreateBlob("flame", this.getTeamNum(), this.getPosition());
			CBlob@ bullet5 = server_CreateBlob("flame", this.getTeamNum(), this.getPosition());

			ammunition = (ammunition-1);
			if (bullet !is null && point !is null && holder !is null)
			{
				bullet.server_SetTimeToDie(1.5);
				CSprite@ sprite = this.getSprite();
				if (sprite !is null)
				{
					//print("yees");
					//sprite.PlaySound("Shotgun.ogg");
				}
				bullet.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				bullet.setVelocity(norm * (6.0f+XORRandom(5)));
				//holder.AddForce(norm *(-180.0f));
				bullet.setAngleDegrees(XORRandom(360));
				
			}			
			if (bullet2 !is null && point !is null && holder !is null)
			{
				bullet2.server_SetTimeToDie(1.5);
				bullet2.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(4), Vec2f());
				bullet2.setVelocity(norm * (6.0f+XORRandom(5)));
				bullet2.setAngleDegrees(XORRandom(360));
				
			}			
			if (bullet3 !is null && point !is null && holder !is null)
			{
				bullet3.server_SetTimeToDie(1.5);
				bullet3.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(6), Vec2f());
				bullet3.setVelocity(norm * (6.0f+XORRandom(5)));
				bullet3.setAngleDegrees(XORRandom(360));
				
			}			
			if (bullet4 !is null && point !is null && holder !is null)
			{
				bullet4.server_SetTimeToDie(1.5);
				bullet4.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(-4), Vec2f());
				bullet4.setVelocity(norm * (6.0f+XORRandom(5)));
				bullet4.setAngleDegrees(XORRandom(360));
				
			}
			if (bullet5 !is null && point !is null && holder !is null)
			{
				bullet5.server_SetTimeToDie(1.5);
				bullet5.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(-6), Vec2f());
				bullet5.setVelocity(norm * (6.0f+XORRandom(5)));
				bullet5.setAngleDegrees(XORRandom(360));
				
			}
		}
	}
	this.set_u32("round", round);
	this.set_u32("reloadgun", reloadgun);
	this.set_u32("ammunition", ammunition);
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}