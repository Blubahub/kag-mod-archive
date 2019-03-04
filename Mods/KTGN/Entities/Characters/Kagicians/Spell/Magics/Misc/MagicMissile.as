void onTick(CBlob@ this)
{
	CBlob@ b = getBlobByNetworkID(this.get_u16("ownerID"));
	if(b is null)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		Vec2f vel = b.getAimPos() - this.getPosition();
		vel.Normalize();
		vel *= this.get_u16("charge") / 700.0f;
		this.setVelocity(this.getVelocity() + vel);
	}
}