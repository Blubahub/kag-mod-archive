void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightColor(SColor(128, 255, 255, 255));
	this.SetLightRadius(16.0f);
}

void onDie(CBlob@ this)
{
	server_CreateBlob("powerfactor",this.getTeamNum(), this.getPosition());
}