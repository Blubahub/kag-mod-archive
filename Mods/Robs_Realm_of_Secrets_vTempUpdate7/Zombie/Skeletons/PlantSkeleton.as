

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(!map.isTileBackground(map.getTile(this.getPosition())))if(XORRandom(30) == 0){
		this.server_Heal(0.5);
	}
}