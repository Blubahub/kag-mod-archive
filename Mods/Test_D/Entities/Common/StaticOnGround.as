void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 5;
}

void onTick( CBlob@ this )
{
	CShape@ shape = this.getShape();

	if (shape.isStatic())
	{
		CMap@ map = getMap();
		Vec2f checkPos = this.getPosition() + Vec2f(0.0f, this.getRadius() + 1.5f );
		const bool tileSolid = map.isTileSolid( map.getTile( checkPos ) );
		if (!tileSolid){
			CBlob@ sandbag = map.getBlobAtPosition( checkPos );
			if (sandbag is null){
				shape.SetStatic( false );		 // SYNC
			}
		}

	}
	else if (this.isOnGround() && shape.vellen < 0.05f && shape.getVars().angvel < 0.05f)
	{
		shape.SetStatic( true );
	}
}