#include "HoverMessage.as"

void AddKill(CBlob@ this, CBlob@ hitterBlob)
{
	if (!getRules().isMatchRunning())
		return;

	if (hitterBlob !is null && hitterBlob !is this)
	{
		CPlayer@ hitterPlayer = hitterBlob.getDamageOwnerPlayer();
		if (hitterPlayer !is null && hitterPlayer.getBlob() !is this && hitterPlayer !is this.getPlayer())
		{
			if (hitterPlayer.isMyPlayer())
			{
				AddScore(hitterPlayer.getBlob(), 1);
			}
			hitterPlayer.setKills(hitterPlayer.getKills() + 1);
		}
	}
	CPlayer@ player = this.getPlayer();
	if (player !is null)
	{
		player.setDeaths(player.getDeaths() + 1);
	}
}