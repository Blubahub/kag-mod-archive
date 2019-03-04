void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = true;
    this.server_setTeamNum(-1); 
	this.Tag("place norotate");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}