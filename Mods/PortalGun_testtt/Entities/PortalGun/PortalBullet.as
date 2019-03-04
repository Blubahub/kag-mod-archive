
void onInit( CBlob@ this )
{
	this.SetLight(true);	
	this.SetLightColor(SColor(255, 255, 255, 255));
	this.SetLightRadius(16.0f);

	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;
	consts.bullet = true;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");
}

void onTick( CBlob@ this )
{
    Pierce( this );
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		HitMap(this, end, this.getOldVelocity(), 0.5f);
	}
}

void HitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage)
{
	f32 radius = this.getRadius();
	CMap@ map = this.getMap();

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.5f * radius);

	Vec2f tp = worldPoint-norm;
	tp = map.getTileSpacePosition(tp);
	Vec2f lock = map.getTileWorldPosition(tp);

	this.setVelocity(Vec2f(0, 0));
	this.setPosition(lock+Vec2f(4.0f,4.0f));
	Vec2f pos = this.getPosition();
	f32 angle = 0;
	
	const f32 ts = map.tilesize;

	Vec2f left = Vec2f(pos + Vec2f(-ts, 0));
	Vec2f right = Vec2f(pos + Vec2f(ts, 0));
	Vec2f down = Vec2f(pos + Vec2f(0, ts));
	Vec2f up = Vec2f(pos + Vec2f(0, -ts));

	bool surface_left = map.isTileSolid(left);
	bool surface_right = map.isTileSolid(right);
	bool surface_above = map.isTileSolid(up);
	bool surface_below = map.isTileSolid(down);

	if (surface_right && (!surface_left || !surface_below || !surface_above))
	{
		angle = 180;
	}
	else if (surface_left && (!surface_below || !surface_right || !surface_above))	
	{
		angle = 0;
	}
	else if (surface_above && (!surface_left || !surface_right || !surface_below))	
	{
		angle = 90;
	}
	else if (surface_below && (!surface_left || !surface_right || !surface_above))	
	{
		angle = 270;
	}
	else 
	{
		this.server_Die();
	}

	Vec2f upperoff = Vec2f(pos + Vec2f(-ts, -ts).RotateBy(angle));
	Vec2f loweroff = Vec2f(pos + Vec2f(-ts, ts).RotateBy(angle));
	Vec2f uppermid = Vec2f(pos + Vec2f(0, -ts).RotateBy(angle));
	Vec2f lowermid = Vec2f(pos + Vec2f(0, ts).RotateBy(angle));

	bool othersurfaces = map.isTileSolid(upperoff) && map.isTileSolid(loweroff) && !map.isTileSolid(uppermid) && !map.isTileSolid(lowermid)
						&& !supportedblobs(this, pos, map, ts, uppermid, lowermid, angle); // things blocking portal placement.
	
	if (othersurfaces)
	{			
		
			CMap@ map = this.getMap();
			const u16 mapWidth = map.tilemapwidth * map.tilesize;
			const u16 mapHeight = map.tilemapheight * map.tilesize;
			Vec2f br = Vec2f(mapWidth,mapHeight);
			CBlob@[] blobs;
			map.getBlobsInBox(Vec2f_zero, br, @blobs);
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				
				if (blob.getName() == "portal" && blob.getTeamNum() == this.getTeamNum()  && blob.get_u16( "ownerID") == this.get_u16( "ownerID"))
				{
					blob.server_Die();
				}
			}

	        CBlob@ portal = server_CreateBlobNoInit( "portal");
	        if (portal !is null)
	        {           
	        	portal.server_setTeamNum(this.getTeamNum());
	        	portal.setPosition(pos); 
	        	
	        	portal.set_f32("pangle", angle); 
	            portal.set_u16( "ownerID", this.get_u16( "ownerID" ) ); 

	            portal.Init();

	        }	
	}
	this.server_Die();	
}

bool supportedblobs(CBlob@ this, Vec2f pos, CMap@ map, f32 ts, Vec2f uppermid, Vec2f lowermid, f32 angle)
{	
	CBlob@[] blobs;
	if(map.getBlobsAtPosition(uppermid, @blobs) || map.getBlobsAtPosition(lowermid, @blobs) || map.getBlobsAtPosition(pos, @blobs))
	{
		for(u32 i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if(blob !is null)
			{
				//string bname = blob.getName();
				if(blob.getShape().getConsts().support > 0 || map.getSectorAtPosition(pos, "no build") !is null ||
				   map.getSectorAtPosition(uppermid, "no build") !is null || map.getSectorAtPosition(lowermid, "no build") !is null) // probs put sectors somewhere else..
				{
					return true;
				}
			}
		}
	}
	CBlob@[] pblobs;
	if(map.getBlobsAtPosition(pos, @pblobs))
	{
		for(u32 i = 0; i < pblobs.length; i++)
		{
			CBlob@ pblob = pblobs[i];
			if(pblob !is null)
			{
				if(pblob.getName() == "portal") // only check center position for portals
				{
					return true;
				}
			}
		}
	}
	return false;
}
