void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_CreateBlob("flax", this.getTeamNum(), this.getPosition());
	}
}