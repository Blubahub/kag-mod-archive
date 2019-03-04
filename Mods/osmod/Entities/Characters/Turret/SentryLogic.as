const int FIRE_FREQUENCY = 4;
const f32 ORB_SPEED = 2.0f;

void onInit(CBlob@ this)
{	
	this.Tag("player");

	this.set_u32("last fire", 0);
	this.set_u16("targetID", 0);
}

void resetTarget(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
	this.set_u16("targetID", 0);
}
void onTick(CBlob@ this)
{
	resetTarget(this);
	this.Tag("unit");
	if (getNet().isServer())
	{
		u32 lastFireTime = this.get_u32("last fire");
		const u32 gametime = getGameTime();
		int diff = gametime - (lastFireTime + FIRE_FREQUENCY);

		if (diff > 0 || diff <= 0)
		{
			Vec2f pos = this.getPosition();
			Vec2f aim = this.get_Vec2f("target position");
			u16 targetID = this.get_u16("targetID");
			CMap@ map = this.getMap();

			if (targetID != 0xffff && targetID != 0)
			{
				print("aint 0xffff, it is " + targetID);
				CBlob@ target = getBlobByNetworkID(targetID);
				target.server_Die();
				if (target !is null)
				{
					print("aint null");
					Vec2f none;
					if (!getMap().rayCastSolid(pos, target.getPosition(), none))
					{
						this.set_Vec2f("target position", target.getPosition());

						lastFireTime = gametime;
						this.set_u32("last magic fire", lastFireTime);
						
						CBlob@ bullet = server_CreateBlob("bullet", this.getTeamNum(), pos + Vec2f(0.0f, -0.5f * this.getRadius() / 2.0f));
						if (bullet !is null)
						{
							bullet.server_setTeamNum(this.getTeamNum());
							bullet.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
							CShape@ bulletshape = bullet.getShape();
							bulletshape.SetGravityScale(0.0f);
							Vec2f norm = aim - pos;
							norm.Normalize();
							bullet.setVelocity(norm * (30.0f+(XORRandom(4.0f))));
							bullet.server_SetTimeToDie(0.8f+XORRandom(0.2f));
						}
						
					}
				}
				if(target is null)
				{
					getTarget(this);
				}
				
			}
			return;

		}
	}
}

void getTarget(CBlob@ this)
{
	print("getting target...");
	Vec2f pos = this.getPosition();
	Vec2f aim = this.get_Vec2f("target position");
	u16 targetID = this.get_u16("targetID");
	CMap@ map = this.getMap();
	if (map !is null)
	{
		CBlob@[] targets;
		if (map.getBlobsInRadius(aim, 128.0f, @targets))
		{
			for (int i = 0; i < targets.length; i++)
			{
				CBlob@ b = targets[i];
				if (b !is null && b.getTeamNum() != this.getTeamNum()/*&& b.hasTag("player")*/)
				{
					print("b aint null");
					Vec2f none;
					if (!getMap().rayCastSolid(pos, b.getPosition(), none))
					{
						targetID = b.getNetworkID();
						if (targetID != 0xffff && targetID != 0)
						{
							this.set_u16("targetID", targetID);
							print("target id set");

						}
					}
				}
			}
		}
	}

}
