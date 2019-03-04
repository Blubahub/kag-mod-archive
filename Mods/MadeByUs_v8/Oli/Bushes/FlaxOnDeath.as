void onDie(CBlob@ this)
{
	if (getNet().isServer() && XORRandom(4) == 0)
	{
		server_CreateBlob("flax", this.getTeamNum(), this.getPosition());
	}
}