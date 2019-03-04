namespace Brain
{
	funcdef Vec2f OFFSET_CALLBACK( CBlob@, const bool );

	bool CheckDrop( CBlob@ blob, Vec2f pos, Vec2f targetPos, const bool isFacingLeft, OFFSET_CALLBACK@ callback, Vec2f &out offset, 
		const f32 maxThrow, const f32 goodDist, const bool checkTooClose )
	{
		CMap@ map = blob.getMap();
		Vec2f col;

		Vec2f throwOffset;// = callback( blob, isFacingLeft );

		if (callback !is null)
			throwOffset = callback( blob, isFacingLeft );
		else 
		{
			throwOffset = (targetPos - pos) * 0.75f;
			throwOffset.y -= Maths::Abs( throwOffset.x ) * 0.5f;

			throwOffset.x = (isFacingLeft ? -1.0f : 1.0f) * Maths::Max( Maths::Abs(throwOffset.x), 10.0f );
			throwOffset.y = Maths::Min( -5.0f, throwOffset.y );
		}

		//map.debugRaycasts = true;
		// map.rayCastSolid( pos, pos + throwOffset, col );
		// map.debugRaycasts = false;

		Vec2f dropPos2 = TestDropPoint( blob, pos + Vec2f(0.0f, -0.0f), throwOffset, isFacingLeft, maxThrow );
		Vec2f dropPos = TestDropPoint( blob, pos + Vec2f(0.0f, 4.0f), throwOffset, isFacingLeft, maxThrow );

	    if ((dropPos - dropPos2).getLength() < 4.0f && (dropPos - targetPos).getLength() < goodDist)
	    {
	    	if (targetPos.x > pos.x)
	    		dropPos += Vec2f(-2.0f, -2.0f );
	    	else
	    		dropPos += Vec2f(2.0f, -2.0f );

	    	// grenade sees target but doesnt see thrower?
		    	
	        if (!map.rayCastSolid( targetPos, dropPos, col ) &&
	        	(!checkTooClose || ((pos - dropPos).getLength() > goodDist * 1.5f) || map.rayCastSolid( pos, dropPos, col ))
	        	)
			{
				map.debugRaycasts = false;
				offset = throwOffset;
				return true;
			}
		}
		return false;
	}

	Vec2f TestDropPoint( CBlob@ blob, Vec2f pos, Vec2f offset, const bool isFacingLeft, const f32 maxThrow )
	{
		CMap@ map = blob.getMap();
		const f32 grenadeRadius = 0.0f;
		Vec2f current = pos + Vec2f( (isFacingLeft ? -1.0f : 1.0f) * blob.getRadius() *0.5f, -blob.getRadius() + grenadeRadius); // params.write_Vec2f( this.getPosition() + Vec2f( data.direction * data.radius *0.5f, -data.radius) );
		Vec2f vel = offset * 0.1f; // HACK : VARS FROM SOLDIER.as Grenade()
		const f32 len = vel.Normalize();
		vel *= Maths::Min( len, maxThrow );
		Vec2f col;
		int timeout = 30;
		const f32 BOX2D_SCALE = 0.025f * 2.0f;
		
		while (!map.rayCastSolid( current, current + vel, col ) && timeout > 0 && current.x > 20.0f && current.x < map.tilesize*map.tilemapwidth-20)
		{
			current += vel;
			vel.y += BOX2D_SCALE*sv_gravity;
			timeout--;
		}
		return current;
	}

	Vec2f NoOffset( CBlob@ b, const bool c ){
		return Vec2f_zero;
	}
	
}