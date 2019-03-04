//flower making herbs on death script
void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_CreateBlob("herb", this.getTeamNum(), this.getPosition());
	}
}