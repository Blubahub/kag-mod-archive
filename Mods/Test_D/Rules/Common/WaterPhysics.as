void onTick( CRules@ this )
{
	CMap@ map = getMap();
	CBlob@[] blobs;
	if (getBlobs( blobs ))
	{
		for (uint i=0; i < blobs.length; i++)
		{	
			CBlob@ blob = blobs[i];	
			ShapeVars@ vars = blob.getShape().getVars();
			vars.old_inwater = vars.inwater;
			vars.inwater = map.isInWater(vars.pos);
			if (blob.isInWater() && !blob.hasTag("doesn't float")){
				const f32 m = blob.getMass() * blob.getShape().getConsts().buoyancy;
				blob.AddForce( blob.getVelocity() * -0.1f * m );
				blob.AddForce( Vec2f( 0.0f, -0.041f*m * blob.getRadius() ) );
			}
		}
	}
}