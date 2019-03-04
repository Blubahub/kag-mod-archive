// Old Ladders, Rocks

void onInit( CBlob@ this )
{
    this.getShape().SetRotationsAllowed( false );
    this.getShape().getVars().waterDragScale = 10.0f;
	this.getShape().getConsts().collideWhenAttached = true;
    this.server_setTeamNum(-1);
    
    this.Tag("ignore blocking actors");
    
	CSprite @sprite = this.getSprite();
	sprite.SetZ(-20.0f);
	
	this.getShape().getConsts().waterPasses = true;

	this.getCurrentScript().tickFrequency = 1;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
