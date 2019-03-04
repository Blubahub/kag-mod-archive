#include "Consts.as"
#include "RulesCommon.as"

namespace SimpleBrain
{
	const f32 VISIBLE_DISTANCE = 250.0f;
	const f32 SNIPER_DISTANCE = 500.0f;
	const f32 EXPLOSIVE_DISTANCE = 80.0f;

	namespace Strategy
	{
		enum type
		{
			OFFENSE = 0,
			SUPPORT,
			COVER,
			RUN,
			BUILD,
			LEASURE,
			BONUSES
		}
	}

	void InitBrain( CBrain@ this )
	{
		CBlob @blob = this.getBlob();
		blob.set_Vec2f("last pathing pos", Vec2f_zero);
		this.failtime_end = 50;
	}

	CBlob@ getClosestBlobFromArray( Vec2f pos, CBlob@[]@ sorted )
	{
		f32 closestDist = 99999.9f;
		CBlob@ closest = null;
		for (uint i = 0 ; i < sorted.length; i++)
		{
			f32 dist = (sorted[i].getPosition() - pos).getLength();
			if (dist < closestDist){
				closestDist = dist;
				@closest = sorted[i];
			}
		}
		//printf(closest is null ? " not added" : " added");
		return closest;
	}

	CBlob@ getVisibleEnemy( CBlob @blob, const f32 maxDistance )
	{
		CBlob@[] players;
		getBlobsByTag( "player", @players );
		Vec2f pos = blob.getPosition();
		CBlob@[] sorted;
		for (uint i=0; i < players.length; i++)
		{
			CBlob@ potential = players[i];
			if (potential !is blob && blob.getTeamNum() != potential.getTeamNum()
				&& !potential.hasTag("dead")
				&& ((pos - potential.getPosition()).getLength() < maxDistance)
				&& isVisible( blob, potential )
				)
			{
				sorted.push_back(potential);
			}
		}
		return getClosestBlobFromArray( blob.getPosition(), @sorted );
	}

	CBlob@ getVisibleBlobWithTag( Vec2f pos, string tag, const f32 maxDistance )
	{
		CBlob@[] blobs;
		getBlobsByTag( tag, @blobs );
		CBlob@[] sorted;
		for (uint i=0; i < blobs.length; i++)
		{
			CBlob@ potential = blobs[i];
			if (((pos - potential.getPosition()).getLength() < maxDistance)
				&& isVisible( pos, potential ))
			{
				sorted.push_back(potential);
			}
		}
		return getClosestBlobFromArray( pos, @sorted );
	}

	CBlob@ getVisibleBlobByName( Vec2f pos, string name, const f32 maxDistance )
	{
		CBlob@[] blobs;
		getBlobsByName( name, @blobs );
		CBlob@[] sorted;
		for (uint i=0; i < blobs.length; i++)
		{
			CBlob@ potential = blobs[i];
			if (((pos - potential.getPosition()).getLength() < maxDistance)
				&& isVisible( pos, potential ))
			{
				sorted.push_back(potential);
			}
		}
		return getClosestBlobFromArray( pos, @sorted );
	}	

	CBlob@ getNearbyEnemy( CBlob @blob, const f32 maxDistance )
	{
		CBlob@[] players;
		getBlobsByTag( "player", @players );
		Vec2f pos = blob.getPosition();
		CBlob@[] sorted;
		for (uint i=0; i < players.length; i++)
		{
			CBlob@ potential = players[i];
			if (potential !is blob && blob.getTeamNum() != potential.getTeamNum()
				&& !potential.hasTag("dead")
				&& ((pos - potential.getPosition()).getLength() < maxDistance)
				)
			{
				sorted.push_back(potential);
			}
		}
		return getClosestBlobFromArray( blob.getPosition(), @sorted );
	}

	CBlob@ getNearbyBlobWithTag( Vec2f pos, string tag, const f32 maxDistance )
	{
		CBlob@[] blobs;
		getBlobsByTag( tag, @blobs );
		CBlob@[] sorted;
		for (uint i=0; i < blobs.length; i++)
		{
			CBlob@ potential = blobs[i];
			if (potential.hasTag(tag) && ((pos - potential.getPosition()).getLength() < maxDistance))
			{
				sorted.push_back(potential);
			}
		}
		return getClosestBlobFromArray( pos, @sorted );
	}

	bool isVisible( CBlob@blob, CBlob@ target)
	{
		Vec2f col;
		return !getMap().rayCastSolid( blob.getPosition() + Vec2f(0.0f, -blob.getRadius()), target.getPosition() + Vec2f(0.0f, -target.getRadius()), col );
	}

	bool isVisible( CBlob@ blob, CBlob@ target, f32 &out distance)
	{
		Vec2f col;
		bool visible = !getMap().rayCastSolid( blob.getPosition() + Vec2f(0.0f, -blob.getRadius()), target.getPosition() + Vec2f(0.0f, -target.getRadius()), col );
		distance = (blob.getPosition() - col).getLength();
		return visible;
	}

	bool isVisible( Vec2f pos, CBlob@ target)
	{
		Vec2f col;
		return !getMap().rayCastSolid( pos, target.getPosition() + Vec2f(0.0f, -target.getRadius()), col );
	}

	bool isVisible( CBlob@blob, Vec2f target)
	{
		Vec2f col;
		return !getMap().rayCastSolid( blob.getPosition() + Vec2f(0.0f, -blob.getRadius()), target, col );
	}

	bool isVisible( Vec2f pos, Vec2f target)
	{
		Vec2f col;
		return !getMap().rayCastSolid( pos, target, col );
	}

	bool JustGo( CBlob@ blob, CBlob@ target )
	{
		Vec2f point = target.getPosition();
		return JustGo( blob, point );
	}

	bool JustGo( CBlob@ blob, Vec2f point, const float horiz_thresh = 0.75f )
	{
		Vec2f mypos = blob.getPosition();
		const f32 horiz_distance = Maths::Abs(point.x - mypos.x);

		if (horiz_distance > blob.getRadius()*horiz_thresh)
		{
			if (point.x < mypos.x) {
				blob.setKeyPressed( key_left, true );
			}
			else {
				blob.setKeyPressed( key_right, true );
			}

			if (point.y + getMap().tilesize*0.7f < mypos.y) {	  // dont hop with me
				blob.setKeyPressed( key_jump, true );
			}

			if (blob.isOnLadder() && point.y > mypos.y) {
				blob.setKeyPressed( key_crouch, true );
			}

			return true;
		}

		SimpleBrain::JumpOverObstacles( blob );

		return false;
	}


	void JumpOverObstacles( CBlob@ blob )
	{
		Vec2f pos = blob.getPosition();
		const f32 radius = blob.getRadius();
		CMap@ map = getMap();

		if (!map.isTileSolid( pos + Vec2f(0.0f, -radius*2.0f) ))
		{
			if (!blob.isOnLadder())
				if ( (blob.isKeyPressed( key_right ) && (map.isTileSolid( pos + Vec2f( 1.3f*radius, 0.0f*radius)*1.0f ) || blob.getShape().vellen < 0.1f) ) ||
					(blob.isKeyPressed( key_left )  && (map.isTileSolid( pos + Vec2f(-1.3f*radius, 0.0f*radius)*1.0f ) || blob.getShape().vellen < 0.1f) ) )
				{
					blob.setKeyPressed( key_jump, true );
				}
		}
	}

	bool isScreenDistance( Vec2f pos, Vec2f targetPos ){
		return ((pos - targetPos).getLength() < Consts::SCREEN_DISTANCE);
	}

	bool isFacing(CBlob@ blob, Vec2f pos)
	{
		Vec2f mypos = blob.getPosition();
		const bool facingleft = blob.isFacingLeft();
		return (pos.x < mypos.x && facingleft) || (pos.x > mypos.x && !facingleft);
	}

	bool isObstacleInFrontOfTarget( Vec2f pos, const bool crouching, Vec2f targetPos, const bool targetCrouching = true, const f32 radius = Consts::SOLDIER_RADIUS )
	{
		Vec2f col;
		Vec2f crouchOffset( 0.0f, 0.0f );
		Vec2f standOffset( 0.0f, -radius );
		return getMap().rayCastSolid( pos + (crouching ? crouchOffset : standOffset),
		 targetPos + (targetCrouching ? crouchOffset : standOffset), col );
	}

	bool isStraightVisible( Vec2f pos, Vec2f targetPos )
	{
		const f32 radius = 1.0f + 2.0f*Consts::SOLDIER_RADIUS;
		Vec2f offset = Vec2f(0.0f, -radius*0.5f);
		Vec2f col;
		CMap@ map = getMap();
		return isScreenDistance( pos, targetPos )
			   && (!map.rayCastSolid( pos, targetPos, col)
			   		|| !map.rayCastSolid( pos + offset, targetPos + offset, col));
	}

	bool areBulletsFlying( CBlob@ blob, const f32 distance = 150.0f )
	{
        CBlob@[] bullets;
        getBlobsByName( "bullet", @bullets );

        for (uint i=0; i < bullets.length; i++) {
            CBlob@ bullet = bullets[i];
            if (bullet.getTeamNum() != blob.getTeamNum()
            	&& (bullet.getPosition() - blob.getPosition()).getLength() < distance
            	){
            	return true;
            }
        }
        return false;
	}

	bool ComplexGoTowards( CBlob@ blob, Vec2f nextpos )
	{
		CMap@ map = getMap();
		CBrain@ brain = blob.getBrain();
	    Vec2f mypos = blob.getPosition();
	    const f32 radius = blob.getRadius();
	    Vec2f vector = nextpos - mypos;

	    const bool debug = false;

	    float rayDist = map.tilesize * 2.0f;
		bool upperLeft = map.rayCastSolid(mypos + Vec2f(-map.tilesize*0.4f,-radius*0.5f), mypos + Vec2f(-map.tilesize*0.4f,-rayDist) );
		bool upperRight = map.rayCastSolid(mypos + Vec2f(map.tilesize*0.4f,-radius*0.5f), mypos + Vec2f(map.tilesize*0.4f,-rayDist) );
		rayDist = map.tilesize * 2.0f;
		const f32 tfx = 0.7f;
		bool lowerLeft = map.rayCastSolid(mypos + Vec2f(-map.tilesize*tfx,radius*0.5f), mypos + Vec2f(-map.tilesize*tfx,rayDist) );
		bool lowerRight = map.rayCastSolid(mypos + Vec2f(map.tilesize*tfx,radius*0.5f), mypos + Vec2f(map.tilesize*tfx,rayDist) );

	    float dist = Maths::Abs(mypos.x - nextpos.x);
	    float height = Maths::Abs(mypos.y - nextpos.y);
	    float margin = 7.0f;

	    bool def = true;

	 //   printf("vector " + vector.x + " " + vector.y + " dist " + dist);

	 	if (blob.isOnLadder())
	 	{
			if (mypos.y > nextpos.y && height > 4.0f && dist < 6.0f) // up ladder
			{
				if (debug) printf("l up");
				blob.setKeyPressed( key_jump, true );
			}
			else if (mypos.y < nextpos.y && height > 4.0f && dist < 6.0f) // down ladder
			{
				if (debug) printf("l down");
				blob.setKeyPressed( key_crouch, true );
			}

			if (mypos.x > nextpos.x && dist >= 6.0f) // left ladder
			{
				if (debug) printf("l left");
				blob.setKeyPressed( key_left, true );
			}
			else if (mypos.x < nextpos.x && dist >= 6.0f) // right ladder
			{
				if (debug) printf("l right");
				blob.setKeyPressed( key_right, true );
			}
	 	}
	 	else
		if (mypos.y > nextpos.y && height > 4.0f && dist >= 6.0f) // up away
		{
			if (debug) printf("ua up");
			blob.setKeyPressed( key_jump, true );
		}
		else
		if (mypos.y > nextpos.y && height > 4.0f && dist < 6.0f) // straight up
		{
			if (!upperLeft && !upperRight){
				blob.setKeyPressed( key_jump, true );
				def = false;
				if (debug) printf("h4 up");
			}
			else if (upperLeft && !upperRight) {
				blob.setKeyPressed( key_right, true );
				blob.setKeyPressed( key_jump, true );
				def = false;
				if (debug) printf("h4 right");
			}
			else if (!upperLeft && upperRight) {
				blob.setKeyPressed( key_left, true );
				blob.setKeyPressed( key_jump, true );
				def = false;
				if (debug) printf("h4 left");
			}
		}
		else
		if (mypos.y < nextpos.y && vector.getLengthSquared() >= 0.0 && vector.y >= 0.0f && vector.x == 0.0f && dist < 6.0f) // heading down
		{
//			printf("vector " + vector.x + " y " + vector.y);
			if (lowerLeft && !lowerRight) {
				blob.setKeyPressed( key_right, true );
				def = false;
				if (debug) printf("d8 right");
			}
			else if (!lowerLeft && lowerRight) {
				blob.setKeyPressed( key_left, true );
				def = false;
				if (debug) printf("d8 left");
			}
			else
			if (lowerLeft && lowerRight) {
				// default
				if (debug) printf("d8 def");
				def = dist > 3.5f;
			}
			else
			if (dist < 5.5f)
			{
				if (debug) printf("d8 nothing");
				def = false;
			}
		}
		else
		if (mypos.y < nextpos.y && vector.y < 0.0f && dist > 0.0f)
		{
			if (lowerLeft && !lowerRight) {
				blob.setKeyPressed( key_left, true );
				def = false;
				if (debug) printf("y right");
			}
			else if (!lowerLeft && lowerRight) {
				blob.setKeyPressed( key_right, true );
				def = false;
				if (debug) printf("y left");
			}
			else
			if (lowerLeft && lowerRight) {
				// default
				if (debug) printf("y def");
			}
			else
			{
				if (debug) printf("y nothing");
				def = false;
			}
		}
		else
		if (mypos.y >= nextpos.y && height < 6.0f)
		{
			if ((nextpos.x > mypos.x && !lowerRight) || (nextpos.x < mypos.x && !lowerLeft))
			{
				blob.setKeyPressed( key_jump, true );
				if (debug) printf("h6 up");
			}
			else
				if (debug) printf("h6 def");
		}

	   	if (def)
	    {
	    	//printf("vector " + vector.x + " y " + vector.y);
	    	if (vector.x > 0.0f){
		        if (nextpos.x + 0.0f*vector.x > mypos.x) {
		            blob.setKeyPressed( key_right, true );
		            if (debug) printf("def right");
		        }
		        else if (nextpos.x + 4.0f*vector.x < mypos.x) {
		            blob.setKeyPressed( key_left, true );
		            if (debug) printf("def left");
		        }
		    }
		    else{
		        if (nextpos.x + 4.0f*vector.x > mypos.x) {
		            blob.setKeyPressed( key_right, true );
		            if (debug) printf("def right");
		        }
		        else if (nextpos.x + 0.0f*vector.x < mypos.x) {
		            blob.setKeyPressed( key_left, true );
		            if (debug) printf("def left");
		        }
	    	}

	    	JumpOverObstacles( blob );
	    }

	    return true;
	}
}
