#define SERVER_ONLY

#include "ParachuteCommon.as"

Random _r;
int _supply_rotator = 0;

void onRestart(CRules@ this)
{
	_supply_rotator = _r.NextRanged(2);
}

void onTick(CRules@ this)
{
	if (!this.isMatchRunning() || getGameTime() % (getTicksASecond() * 5) != 0)
		return;

	CBlob@[] supplies;
	getBlobsByName("supply", @supplies);
	if (supplies.length >= 4)
		return;

	CMap@ map = getMap();

	Vec2f pos = Vec2f(((map.tilemapwidth / 6.0f / 2.0f) + _r.NextRanged(map.tilemapwidth * 5.0f / 6.0f) + 0.5f) * map.tilesize, 0.0f);
	Vec2f vel = Vec2f((_r.NextFloat() * 2.0f - 1.0f) * 2.0f, 0.0f);

	CBlob@ supply = server_CreateBlobNoInit("supply");
	if (supply !is null)
	{
		supply.setPosition(pos);
		supply.setVelocity(vel);
		supply.set_u8("supply type", (_supply_rotator++) % 2);
		supply.server_setTeamNum(255);
		supply.Init();
		AddParachute(supply);
	}

}