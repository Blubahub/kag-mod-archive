// FallOnNoSupport.as

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
}

// TODO: make this on an event
void onTick(CBlob@ this)
{
	if (!getNet().isServer()) return;

	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	if (!map.isTileSolid(map.getTile(pos+Vec2f(0,map.tilesize))))
	{
		this.server_Die();
	}
}