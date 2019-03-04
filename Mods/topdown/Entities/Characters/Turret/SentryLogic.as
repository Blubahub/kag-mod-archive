const int FIRE_FREQUENCY = 2;
const f32 ORB_SPEED = 2.0f;

void onInit(CBlob@ this)
{	
	if(this.getShape() !is null) this.getShape().SetOffset(Vec2f(0,-4)); 
	this.Tag("player");
	this.Tag("unit"); 

	this.set_u32("last fire", 0);
	this.set_u16("targetID", 0);
	this.set_f32("xpos", this.getPosition().x);
}
void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(this.getAngleDegrees() == 0)
	{
		this.set_Vec2f("gun offset", Vec2f(0, -18));
		print("goffset");
	}

	if(this.getAngleDegrees() == 90)
	{
		this.set_Vec2f("gun offset", Vec2f(18, 0));
	}

	if(this.getAngleDegrees() == 180)
	{
		this.set_Vec2f("gun offset", Vec2f(0, 18));
	}

	if(this.getAngleDegrees() == 270)
	{
		this.set_Vec2f("gun offset", Vec2f(-18, 0));
	}
}
void resetTarget(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
	this.set_u16("targetID", 0);
}
void onTick(CBlob@ this)
{/*
	f32 xpos = this.get_f32("xpos");
	this.setPosition(Vec2f(xpos, this.getPosition().y));*/
	//resetTarget(this);
	if (getNet().isServer())
	{
		u32 lastFireTime = this.get_u32("last fire");
		const u32 gametime = getGameTime();
		int diff = gametime - (lastFireTime + FIRE_FREQUENCY);


		if (diff > 0 || diff <= 0)
		{
			//print("sentry jii");
			Vec2f pos = this.getPosition();
			Vec2f aim = this.get_Vec2f("target position");
			u16 targetID = this.get_u16("targetID");
			CMap@ map = this.getMap();

			CBlob@ target = getBlobByNetworkID(targetID);
			if(target !is null && target.hasTag("dead")){
						getTarget(this);
						//print("target dead");
						this.set_u16("targetID", 0);
						return;
					}
			if(target is null) getTarget(this);
			if (targetID != 0xffff && targetID != 0)
			{
				//print("aint 0xffff, it is " + targetID);
				//target.server_Die();

				if (target !is null || target !is null && !target.hasTag("dead"))
				{
					//print("aint null");
					Vec2f none;
					Vec2f offset = this.get_Vec2f("gun offset");
					//offset = Vec2f(0, 32);
					pos += offset;
					if (!getMap().rayCastSolid(pos, target.getPosition(), none))
					{
						this.set_Vec2f("target position", target.getPosition());

						lastFireTime = gametime;
						this.set_u32("last fire", lastFireTime);
						CBlob@ bullet = server_CreateBlob("bullet", this.getTeamNum(), pos);// + offset);
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
				
			}
			else
			{
				getTarget(this);
				//print("getting gettarget...");
			}
			randomTarget(this);
			return;

		}
	}
}

void getTarget(CBlob@ this)
{
	//print("getting target...");
	Vec2f pos = this.getPosition();
	Vec2f aim = this.get_Vec2f("target position");
	u16 targetID = this.get_u16("targetID");
	CMap@ map = this.getMap();
	if (map !is null)
	{
		CBlob@[] targets;
		if (map.getBlobsInRadius(pos, 180.0f, @targets))
		{
			for (int i = 0; i < targets.length; i++)
			{
				CBlob@ b = targets[i];
				if (b !is null && b.getTeamNum() != this.getTeamNum() && b.hasTag("flesh") && !b.hasTag("dead"))
				{
					//print("b aint null");
					Vec2f none;
					if (!getMap().rayCastSolid(pos, b.getPosition(), none))
					{
						targetID = b.getNetworkID();
						if (targetID != 0xffff && targetID != 0)
						{
							this.set_u16("targetID", targetID);
							//print("target id set");

						}
					}
				}
			}
		}
	}

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.getTeamNum() == this.getTeamNum()) return false;
	return true;
}
void randomTarget(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 5;
	getTarget(this);

}
