// change to particles?

void onInit( CBlob@ this )
{
	ScriptData@ script = this.getCurrentScript();
	script.tickFrequency = 3;
	this.server_SetTimeToDie(20);
	if (!this.exists("countdown"))
	{
		this.set_s32("countdown", 5);
		this.Sync("countdown", true);
	}
	
	if (!this.exists("team countdown"))
	{
		this.set_s32("team countdown", 30);
		this.Sync("team countdown", true);
	}
	
	this.Tag("floor coin");
}

void onTick( CBlob@ this )
{
	int countdown = this.get_s32("countdown");
	int team_countdown = this.get_s32("team countdown");
	if (team_countdown > 0)
	{
		this.set_s32("team countdown", team_countdown - 1);
		this.Sync("team countdown", true);
	}
	if (countdown > 0)
	{
		this.set_s32("countdown", countdown - 1);
		this.Sync("countdown", true);
		return;
	}
	int team = this.getTeamNum();
	for (int i = 0; i < this.getTouchingCount(); i++)
	{
		CBlob@ touching = this.getTouchingByIndex(i);
		if (touching is null)
		{
			continue;
		}
		if (!touching.hasTag("player") || (touching.getTeamNum() == team && team_countdown > 0))
		{
			continue;
		}
		CPlayer@ player = touching.getPlayer();
		if (player is null)
		{
			continue;
		}
		Vec2f pos = player.getBlob().getPosition();
		Sound::Play("coinpick.ogg", pos, 1.2f, 1.2f);
		if (getNet().isServer())
		{
			player.server_setCoins(player.getCoins() + 1);
			this.server_Die();
		}
		return;
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}