void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(blob is null && solid)
	{
		touchFloor(this);
		this.getShape().SetStatic(true);
		if(getNet().isServer())
		{
			this.server_SetTimeToDie(this.getTimeToDie() + 4);
		}
	}
}
void touchFloor(CBlob@ this)
{
	CMap@ map = this.getMap();
	Vec2f vel = this.getOldVelocity();
	vel.Normalize();
	Vec2f pos = this.getPosition();
	
	for(int i = 0; i < 13; i++)
	{
		if(map.isTileSolid(pos + vel * 4))
		{
			break;
		}
		else
		{
			pos += vel;
		}
	}
	this.setPosition(pos);
}