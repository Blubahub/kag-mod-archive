// character was placed in crate

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true; // run scripts while in crate
	this.getMovement().server_SetActive(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// when dead, collide only if its moving and some time has passed after death
	
	if(this.hasTag("ghost") || blob.hasTag("ghost"))return false;
	
	CShape@ oShape = blob.getShape();
	
	if (this.hasTag("dead"))
	{
        
		bool slow = (this.getShape().vellen < 1.5f);
        //static && collidable should be doors/platform etc             fast vel + static and !player = other entities for a little bit (land on the top of ballistas).
		return (oShape.isStatic() && oShape.getConsts().collidable) || (!slow && oShape.isStatic() && !blob.hasTag("player"));
	}
	else // collide only if not a player or other team member, or crouching
	{
		if(blob.hasTag("vehicle"))return true;
		if(blob.hasTag("player_collide"))return true;
		
		if(oShape.isStatic() && oShape.getConsts().collidable)return true;

		if(!this.hasTag("shielding") && !blob.hasTag("shielding"))return false;

	}

	return true;
}
