#define SERVER_ONLY

void onDie(CBlob@ this)
{
	int team = this.getTeamNum();
	Vec2f pos = this.getPosition();
	string cfg = this.getConfig();
	CBlob@ drop;
	
    if (cfg == "hunter")
        @drop = server_CreateBlob("longbow", team, pos);
    else if (cfg == "crossbowman")
        @drop = server_CreateBlob("crossbow", team, pos);
    else if (cfg == "heavyknight")
        @drop = server_CreateBlob("armorkit", team, pos);
    else if (cfg == "druid")
        @drop = server_CreateBlob("weak_soulstone", team, pos);
	else if (cfg == "brainswitcher")
        @drop = server_CreateBlob("weak_soulstone", team, pos);
    else if (cfg == "Necromancer")
        @drop = server_CreateBlob("medium_soulstone", team, pos);
}