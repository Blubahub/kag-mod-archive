
void onDie(CBlob@ this)
{
	if(this.hasTag("switch class"))return;
	if(getNet().isServer()){
		CBlob@ blob = server_CreateBlob("ectoplasm", this.getTeamNum(), this.getPosition());
		if (blob !is null)
		{
			blob.server_SetQuantity(XORRandom(10)+1);
		}
	}
}