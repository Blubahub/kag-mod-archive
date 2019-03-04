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
    }
    else // collide only if not a player or other team member, or crouching
    {
		
		if (blob.hasTag("migrant") || (blob.hasTag("player") && this.getTeamNum() == blob.getTeamNum()))
			return false;

		const bool still = (this.getShape().vellen < 0.01f);
		if (this.isKeyPressed(key_down) && 
				this.isOnGround() && still &&
				!blob.hasTag("ignore crouch"))
			return false;
			
    }
    
    return true;
}

