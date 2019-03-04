#include "States.as"
#include "ActionCommon.as"

namespace Brain
{
	namespace Location
	{
		void AddLocationStates( State@ state, BOOL_ACTION_CALLBACK@ _isInterrupted )
		{
			CMap@ map = state.map;
			//map.ResetHighLevelNodes();
			CHighMapNode@[] nodes;
			if (map.getHighLevelNodes( state.me.pos, 1, nodes ))
			{
				for (uint i=0; i < nodes.length; i++)
				{
					CHighMapNode@ node = nodes[i];
					if (node !is state.me.node && state.funcs.IsNodeReachable( state.me.node, node ) )
					{
						Brain::Location::AddState( state, node.getWorldPosition(), _isInterrupted );
					}
				}
			}
		}

		State@ AddState( State@ state, Vec2f pos, BOOL_ACTION_CALLBACK@ _isInterrupted )
		{
			// add state
			State@ newstate = Brain::AddState( state.o.brain, Brain::StateFlag::LOCATION, "location[" + pos.x + "," + pos.y +"]", pos );
			Inherit( newstate, state );

			// change my location
			newstate.me.pos = pos;
			@newstate.me.node = state.map.getHighLevelNode( pos );

			if (newstate.funcs.FlagState !is null){
				newstate.funcs.FlagState( newstate );
			}
			else {warn("FlagState is null");}

			AddAction( state, newstate, _isInterrupted );
			return newstate;
		}

		void AddAction( State@ state, State@ newstate, BOOL_ACTION_CALLBACK@ _isInterrupted )
		{
			Brain::Action action;
			@action.current = state;
			@action.next = newstate;
			@action.onStart = onStart;
			@action.onEnd = onEnd;
			@action.onFail = onFail;
			@action.onTick = onTick;
			@action.hasFailed = hasFailed;
			@action.isExpected = isExpected;
			@action.isInterrupted = _isInterrupted;
			action.time = 90;
			if (state.o.pos.y > newstate.o.pos.y)
				action.cost = newstate.o.highlevelnode.getDistanceFromGround() * newstate.o.highlevelnode.getCost() / 10.0f;
			else
				action.cost = newstate.o.highlevelnode.getCost() / 10.0f;
			//action.cost = 1.0f;

			state.actions.set( ""+newstate.hashcode, action );
		}

		void onStart( Action@ this )
		{
			CBrain@ brain = this.current.o.brain;
			brain.ResetLowLevelPath(); // clear the current low level path so we dont end action immediately
		}

		void onEnd( Action@ this )
		{
			debug("Location: end [" + this.next.o.pos.x + "," + this.next.o.pos.y+"]");
		}

		void onFail( Action@ this )
		{
			debug("Location: fail");
		}

		bool isExpected( Action@ this )
		{
			CBlob@ blob = this.current.o.blob;
			CBrain@ brain = this.current.o.brain;
			Vec2f pos = blob.getPosition();

			if (brain.getState() == CBrain::has_path)
			{
				const uint size = brain.getPathSize();
				if (size == 0)
					return false;
				Vec2f pathpos = brain.getPathPosition();
				Vec2f endpos = brain.getPathPositionAtIndex( size-1 );
				f32 dist = (pos - endpos).getLength();
			//	if (pathpos == endpos)
				//	printf("dist "  + dist + "/" + this.lastDist );

				if (pathpos == endpos && (dist <= 6.0f && this.lastDist <= dist)){
					//printf("at pos " + this.next.type);
					return true;
				}
				this.lastDist = dist;
			}
			else{
				Vec2f nextpos = this.next.o.pos;
				if ((pos - nextpos).getLength() <= 8.0f){
					//printf("at pos 2");
					return true;
				}
			}

			return false;
		}

		bool hasFailed( Action@ this )
		{
			return this.time <= 0 ||
				(this.current.o.blob.getPosition() - this.next.o.pos).getLength() > 100.0f;
		}

		bool defaultIsInterrupted( Action@ this )
		{
			CBlob@ blob = this.current.o.blob;
			// check if path has suddenly become too costly
			const f32 currentCost = this.current.funcs.GetCost( this.current, this.next );
			const f32 diff = currentCost - this.initialCost;
			if (diff > 15.0f){
				//printf("defaultIsInterrupted diff " + diff );
				return true;
			}

			return false;
		}

		void onTick( Action@ this )
		{
			CBrain@ brain = this.current.o.brain;
			CBlob@ blob = this.current.o.blob;
			Vec2f nextpos = this.next.o.pos;

			LowLevelMoveAlong( blob, nextpos );
		}
	} // Location



	// input functions


	void LowLevelRepath( CBrain@ this, Vec2f start, Vec2f end )
	{
		if ((this.getVars().lastPathPos - start).getLength() > 16.0f ||
			(this.getVars().lastPathPos2 - end).getLength() > 16.0f)
		{				
			this.SetLowLevelPath( start, end );
			this.getVars().lastPathPos = start;
			this.getVars().lastPathPos2 = end;
		}
	}

	bool LowLevelMoveAlong( CBlob@ blob, Vec2f targetPos )
	{
		CBrain@ brain = blob.getBrain();
		Vec2f myPos = blob.getPosition();
		Vec2f targetVector = targetPos - myPos;
		f32 targetDistance = targetVector.Length();
		Vec2f startPos = brain.getPathSize() > 0 ? brain.getPathPositionAtIndex( brain.getPathSize()-1 ) : myPos;
		// check if we have a clear area to the target

		if ((targetPos - myPos).getLengthSquared() < 8.0f){
			return true;
		}

		// // repath if no clear path after going at it
		// if ((brain.getVars().lastPathPos - targetPos).getLength() > 35.0f ||
		// 	(brain.getVars().lastPathPos2 - startPos).getLength() > 35.0f)
		// {
		// 	LowLevelRepath( brain, startPos, targetPos );
		// }

		const CBrain::BrainState state = brain.getState();

		//printf("getStateString " + brain.getStateString() + " path " + brain.getPathSize() );

		switch (state)
		{
		case CBrain::has_path:
			LowLevelPathKeys( blob );  // set walk keys here
			break;

		case CBrain::idle:
			LowLevelRepath( brain, startPos, targetPos );
			break;

		case CBrain::searching:
	   	    if (brain.getPathSize() > 0) {
				LowLevelPathKeys( blob );  // set walk keys here
		    }
			break;

		case CBrain::stuck:
			LowLevelRepath( brain, startPos, targetPos );
			break;

		case CBrain::wrong_path:
			LowLevelRepath( brain, startPos, targetPos );
			break;
		}

		return state == CBrain::has_path;
	}

	bool LowLevelPathKeys( CBlob@ blob )
	{
		CMap@ map = getMap();
		CBrain@ brain = blob.getBrain();
	    Vec2f mypos = blob.getPosition();

		const int pathSize = brain.getPathSize();
		if (pathSize == 0)
			return false;
	    Vec2f pathpos = brain.getPathPosition();
	    Vec2f nextpos = brain.getNextPathPosition();
	    Vec2f endpos = brain.getPathPositionAtIndex( pathSize-1 );
	    const f32 radius = blob.getRadius();
	    Vec2f vector = nextpos - pathpos;
	    if (endpos == nextpos && pathSize > 2){
	    	vector = pathpos - brain.getPathPositionAtIndex( pathSize-2 );
	    //	printf("End[ps " + vector.x + " " + pathSize);
	    }

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
	    }

	    return true;
	}
	
	
}