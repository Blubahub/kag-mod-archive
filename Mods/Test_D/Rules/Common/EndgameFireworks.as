#include "ExplosionParticles.as"

void onInit(CRules@ this)
{
	this.addCommandID("firework");
}

void onTick(CRules@ this)
{
	if (this.getCurrentState() != GAME_OVER)
		return;

	CBlob@ localblob = getLocalPlayerBlob();
	if (getNet().isClient() && localblob !is null)
	{
		if (getControls().isKeyJustPressed(getControls().getActionKeyKey(AK_ACTION1)) &&
		        canFirework(this, localblob))
		{
			CBitStream params;
			params.write_netid(localblob.getNetworkID());
			this.SendCommand(this.getCommandID("firework"), params);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	CPlayer@ player;
	if (getNet().isClient() && cmd == this.getCommandID("firework"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());

		if (!canFirework(this, blob))
			return;

		Particles::Fireworks(blob.getPosition(), 1, Vec2f(0.0f, -10.0f), 0.5f, 30, 10);
	}
}

bool canFirework(CRules@ this, CBlob@ blob)
{
	if (blob is null || this.getCurrentState() != GAME_OVER)
		return false;

	string gamemode = this.get_string("gamemode");
	if (gamemode == "Skirmish")
	{
		CPlayer@ p = blob.getPlayer();
		if (p is null)
			return false;

		if (p.getKills() < this.get_u32("score_cap"))
			return false;
	}
	else if (gamemode == "Campaign")
	{
		if (blob.getTeamNum() != this.getTeamWon())
			return false;
	}

	return true;
}
