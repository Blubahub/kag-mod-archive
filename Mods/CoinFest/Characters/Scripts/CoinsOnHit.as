#include "Hitters.as"

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (this is hitterBlob)
	{
		return damage;
	}

	switch (customData)
	{
		case Hitters::fall:
		case Hitters::drown:
		case Hitters::crush:
		case Hitters::spikes:
			return damage;

		default: break;
	}

	if (damage > 0 && this.hasTag("player") && getNet().isServer())
	{
		int team = this.getTeamNum();
		Vec2f pos = this.getPosition();
		for (int i = 0; i < 5; i++)
		{
			CBlob@ coin = server_CreateBlob("floor_coin", team, pos);
			coin.setVelocity(Vec2f((XORRandom(12) - 6), -2 - XORRandom(8)));
		}
	}

	return damage;
}