int bomberEatingSpeed = 1 * 10;
int subEatingSpeed = 1 * 10;
void onInit(CBlob@ this)
{
	if (this.getConfig() == "bomber")
		this.getCurrentScript().tickFrequency = bomberEatingSpeed;
	else if (this.getConfig() == "submarine")
		this.getCurrentScript().tickFrequency = subEatingSpeed;
}
void onTick( CBlob@ this )
{
	int vely = this.getVelocity().y;
	int velx = this.getVelocity().x;
	const u16 coal = this.getBlobCount("mat_coal");
	if (this.hasTag("airship"))
	{
		if (coal > 0)
		{
			this.Tag("has_fuel");
			if (!this.isOnGround())
				this.TakeBlob("mat_coal", 1);
			else if (vely < 0 || velx > 0 || velx < 0)
				this.TakeBlob("mat_coal", 1);
		}
		else if (coal <= 0)
			this.Untag("has_fuel");
	}
	else if (this.hasTag("submarine"))
	{
		if (coal > 0)
		{
			this.Tag("has_fuel");
			if (!this.isOnGround())
				this.TakeBlob("mat_coal", 1);
			else if (vely < 0 || velx > 0 || velx < 0)
				this.TakeBlob("mat_coal", 1);
		}
		else if (coal <= 0)
			this.Untag("has_fuel");
	}
}