// character was placed in crate

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	this.doTickScripts = true; // run scripts while in crate
    this.getMovement().server_SetActive( true );
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (this.hasTag("dead") )    { // when dead, collide only if its moving and some time has passed after death
		bool slow = (this.getShape().vellen < 1.5f);
        return !slow;
    } else if ( ( this.isOnWall() && this.getAirTime() > 30 ) || ( blob.isOnWall() && blob.getAirTime() > 30 ) )
		return true;
    else if (blob.hasTag("migrant") || (blob.hasTag("player") && this.getTeamNum() == blob.getTeamNum()))
		return false;
    
    return true;
}

