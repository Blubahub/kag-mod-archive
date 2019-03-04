
void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders

}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	PickupOverlap(this);
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer())
	{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && 
			(blob.getName() == "mat_sand" || blob.getName() == "mat_metal" 
			|| blob.getName() == "mat_wood" || blob.getName() == "mat_stone"
			|| blob.getName() == "mat_glass" || blob.getName() == "mat_metalbars"
			|| blob.getName() == "mat_coal" || blob.getName() == "mat_gold"
			|| blob.getName() == "mat_bombs" || blob.getName() == "mat_hemp"
			|| blob.getName() == "mat_waterbombs" || blob.getName() == "keg"))
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}