//trap block script for devious builders

void onInit(CBlob@ this)
{
	this.getShape().getConsts().waterPasses = false;
	this.getShape().SetRotationsAllowed( true );
    this.getSprite().getConsts().accurateLighting = true;
    this.server_SetTimeToDie(60 + XORRandom(60));
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}
