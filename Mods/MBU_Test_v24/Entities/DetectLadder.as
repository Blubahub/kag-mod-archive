// set ladder if we're on it, otherwise set false

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_not_onground;
}

void onTick(CBlob@ this)
{
	ShapeVars@ vars = this.getShape().getVars();

	//check overlapping objects
	if(vars.onladder){
		vars.onladder = false;
		
		CBlob@[] overlapping;
		if (this.getOverlapping(@overlapping))
		{
			for (uint i = 0; i < overlapping.length; i++)
			{
				CBlob@ overlap = overlapping[i];
				if (overlap.isLadder() && !overlap.isAttachedTo(this))
				{
					vars.onladder = true;
					break;
				}
			}
		}
	}
	
	// ladder sector
	if(!vars.onladder)
	if (this.getMap().getSectorAtPosition(this.getPosition(), "ladder") !is null)
	{
		vars.onladder = true;
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null)
	if(blob.isLadder() && !blob.isAttachedTo(this)){
		ShapeVars@ vars = this.getShape().getVars();
		vars.onladder = true;
	}
}