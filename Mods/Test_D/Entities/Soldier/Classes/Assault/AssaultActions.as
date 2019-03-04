#include "States.as"
#include "ActionCommon.as"
#include "SoldierCommon.as"
#include "Consts.as"
#include "ActionDrops.as"
#include "CommonStates.as"

namespace Brain
{
	namespace Assault
	{
		namespace Engage
		{
			enum Type
			{
				FIRE = 0,
				WAIT,
				GRENADE
			}

			void AddState( State@ state, const string &in name, const uint memIndex, Type type, const u32 addflags )
			{
				State@ newstate = Brain::AddState( state.o.brain, Brain::StateFlag::BLOB, name, state.o.pos );
				Inherit( newstate, state );
				
				BlobMemory@ bm = state.memory[memIndex];// fire at this blob
				BlobMemory@ targetbm = newstate.memory[memIndex];

				// target expected to be dead
				targetbm.health = 0.0f;
				CommonFlagMemory( newstate, targetbm );


				AddFlag( targetbm, addflags );
				AddAction( state, newstate, targetbm, type );
			}

			void AddAction( State@ state, State@ newstate, BlobMemory@ targetbm, Type type  )
			{
				Action action;
				@action.current = state;
				@action.next = newstate;
				@action.onStart = onStart;
				@action.onEnd = onEnd;
				@action.onFail = onFail;
				@action.hasFailed = hasFailed;
				@action.isExpected = isExpected;
				@action.isInterrupted = isInterrupted;
				action.time = 70;
				@action.target = targetbm;
				action.cost = 1.0f;

				if (type == FIRE)
				{
					@action.onTick = onTickFire;
					action.cost = 10.0f;
				}
				else if (type == WAIT)
				{
					@action.onTick = onTickWait;
					action.time = 140;
					action.cost = 5.0f;
				}
				else if (type == GRENADE) {
					@action.onTick = onTickGrenade;
					Soldier::Data@ data = Soldier::getData( state.o.blob );
					const f32 targetDist = (state.me.pos - targetbm.pos).getLength();
					action.cost = (5.0f - data.grenades*1) + 50.0f / (targetDist + 1.0f);
				}

				state.actions.set( ""+newstate.hashcode, action );
			}


			void onStart( Action@ this )
			{
				debug("Engage: start ");
			}

			void onEnd( Action@ this )
			{
				debug("Engage: end ");
			}

			void onFail( Action@ this )
			{
				debug("Engage: fail ");
			}

			bool isExpected( Action@ this )
			{
				CBrain@ brain = this.current.o.brain;
				CBlob@ target = getBlob( this.target );
				if (target is null)
					return true;

				if (target.getHealth() <= 0.0f)
					return true;

				return false;
			}

			bool hasFailed( Action@ this )
			{
				return this.time <= 0 
						|| this.target is null;
			}

			bool isInterrupted( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				// check if path has suddenly become too costly
				const f32 currentCost = this.current.funcs.GetCost( this.current, this.next );
				const f32 diff = currentCost - this.initialCost;
				if (diff > 0.0f)
					printf("action diff " + diff );
				if (diff > 50.0f){
					return true;
				}

				return false;
			}

			void onTickFire( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Vec2f targetpos = target.getPosition();

	 			Face( blob, targetpos );
				AttackBlob( blob, target );
			}

			void onTickWait( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Vec2f targetpos = target.getPosition();
	 			
				Face( blob, targetpos );
				WaitForBlob( this, blob, target, this.current.o.pos );
			}

			void onTickGrenade( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Soldier::Data@ data = Soldier::getData( blob );
				Vec2f pos = blob.getPosition();
				//printf("nade");
				bool hold = true;

				Vec2f throwPos = this.current.o.pos;
				const bool offSpot = !blob.isOnGround() || ((throwPos - pos).getLength() > 7.0f);
				
				if (data.crosshair)
				{
					if (offSpot){
						blob.setKeyPressed( key_action1, true );
						return;
					}

					Vec2f nodeposOffset = this.current.o.highlevelnode.getWorldPosition() - throwPos;
					const f32 targetDistance = (target.getPosition() - pos).getLength();
				//	printf("nodeposOffset " + nodeposOffset.x + " " + nodeposOffset.y);

					//printf("data.grenadeStep " + data.grenadeStep + "/" + data.grenadeTimeout );
					Vec2f desiredAim = pos + data.ai_grenadeOffset + nodeposOffset;
					Vec2f aim = pos + data.crosshairOffset;
					if (
						desiredAim.y < aim.y && data.grenadeStep > data.grenadeTimeout*0.65f
						&& data.grenadeStep < data.grenadeTimeout &&
						((desiredAim - aim).getLength() <= data.crosshairSpeed // this wont be achieved if target is beyond crosshair limit					
						//|| data.grenadeStep > data.grenadeTimeout*0.75f)						
						)
						){
						hold = false;
					}
					else{
						Vec2f vector = desiredAim - aim;
						const f32 len = vector.Normalize();
						//printf("ai_grenadeOffset " + data.ai_grenadeOffset.x + " " + data.ai_grenadeOffset.y );
						//printf("crosshairOffset " + data.crosshairOffset.x + " " + data.crosshairOffset.y );
						if (len > 0.0f)
							data.crosshairOffset += vector * data.crosshairSpeed * 0.05f * len;
						else
						    data.crosshairOffset += vector * data.crosshairSpeed * 0.25f;
					}
				}
				else {
					if (offSpot){
						JustGo( blob, throwPos );
						hold = false;
					}
				}

				if (hold){
					blob.setKeyPressed( key_action2, true );
				}
			}

		} // Engage


		// input

		void AttackBlob( CBlob@ blob, CBlob @target )
		{
			if (target is null)
				return;
			CMap@ map = blob.getMap();
		    Vec2f mypos = blob.getPosition();
		    Vec2f targetPos = target.getPosition();
		    Vec2f targetVector = targetPos - mypos;
		    f32 targetDistance = targetVector.Length();
		    bool fire = true;
		    bool enemyFire = areBulletsFlying( blob );
		    f32 height = Maths::Abs(targetPos.y - mypos.y);
		    const bool targetCrouching = target.hasTag("crouching");
		    const bool targetLower = targetPos.y - 4.0f > mypos.y;
		    const bool targetHigher = targetPos.y + 4.0f < mypos.y;
		    const bool onground = blob.isOnGround();
		    Soldier::Data@ data = Soldier::getData( blob );
		    
			// turn side

			bool facingleft = blob.isFacingLeft();
			if (targetPos.x > mypos.x && facingleft){
				blob.setKeyPressed( key_left, false );
				blob.setKeyPressed( key_right, true );
			}
			else if (targetPos.x < mypos.x && !facingleft){
				blob.setKeyPressed( key_right, false );
				blob.setKeyPressed( key_left, true );
			}

		    const bool tooClose = Maths::Abs(mypos.x - targetPos.x) < 1.5f*target.getRadius();
		    if (tooClose && blob.isOnGround()){
		    	if (mypos.x > targetPos.x) {
		    		blob.setKeyPressed( key_right, true );
		    		blob.setKeyPressed( key_left, false );
		    	}
		    	else{
		    		blob.setKeyPressed( key_left, true );
		    		blob.setKeyPressed( key_right, false );
		    	}
		    }

		    // enemy ducking?
		    if (onground && !tooClose && (/*targetCrouching || */targetLower || enemyFire) && data.reactionTime <= 0)
		    {
		    	//printf("lower");
				blob.setKeyPressed( key_crouch, true );
		    }
		    else if (targetHigher && !enemyFire)
		    {
		    	//printf("higher "  + height);
		    	if (height < 4.0f*map.tilesize)
					blob.setKeyPressed( key_jump, true );
				else {
					fire = false;
					//printf("too high");
				}
		    }

		    const bool crouching = blob.isKeyPressed( key_crouch ) && blob.isOnGround();
		    const bool obstacleInFront = isObstacleInFrontOfTarget( mypos, crouching, targetPos, targetCrouching, target.getRadius() );

		    if (obstacleInFront || (!crouching && targetCrouching)) {
		    	fire = false;
		    }

		    // reaction time
	    	if (data.reactionTime > 0){
	    		fire = false;
	    	}
    		data.reactionTime -= 2;

		   // printf("fire " + fire + " obstacleInFront " + obstacleInFront + " rt " + data.reactionTime);

		    // fire
			if (fire){
				blob.setKeyPressed( key_action1, true );
			}
		}

		bool isCoveredShootingSpot( Vec2f pos, Vec2f targetPos ){
			return !isObstacleInFrontOfTarget( pos, false, targetPos, false, Consts::SOLDIER_RADIUS )
					&& isObstacleInFrontOfTarget( pos, true, targetPos, false, Consts::SOLDIER_RADIUS );
		}

		bool areBulletsFlying( CBlob@ blob, const f32 distance = 250.0f )
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

		// WAIT

		void WaitForBlob( Action@ this, CBlob@ blob, CBlob @target, Vec2f pos )
		{
			if (target is null)
				return;
		    Vec2f mypos = blob.getPosition();
		    Vec2f targetPos = target.getPosition();
		    const bool targetCrouching = target.hasTag("crouching");
		    const bool visibleStanding = !isObstacleInFrontOfTarget( mypos, false, targetPos, targetCrouching, target.getRadius() );
		    const bool visibleCrouching = !isObstacleInFrontOfTarget( mypos, true, targetPos, targetCrouching, target.getRadius() );
		    //	printf("visibleStanding " + visibleStanding);
		    	//printf("visibleCrouching " + visibleCrouching);

		    // if I am in plain site just attack
		    if (visibleCrouching && Brain::isInLineOfFire( mypos, targetPos )){
		    	//printf("visible");
		    	AttackBlob( blob, target );
		    }
		    else{
		    	// if I will be invisible when crouched crouch
		    	if (visibleStanding){
		    		//printf("crocuh ");
		    		//// if at spot crouch
		    		if (!Brain::JustGo( blob, pos )){
		    			// try to attack if enemy is not shooting an moving towards us
		    			if ((this.time % 60 < 12 || target.getVelocity().getLengthSquared() > 0.1f) && !areBulletsFlying( blob )){
		    				AttackBlob( blob, target );
		    			}
		    			else{
							blob.setKeyPressed( key_crouch, true );
		    	    	}
		    		}
		    	}
		    	else {
		    		// I am alwats invisible in this spot
		    		//printf("in go ");
		    		Brain::JustGo( blob, pos );
		    	}
		    }
		}


		// grenade

		bool isGrenadeThrowSpot( CBlob@ blob, Vec2f pos, Vec2f targetPos, const bool isFacingLeft )
		{
			Soldier::Data@ data = Soldier::getData( blob );
			Vec2f lobOffset;
			if (CheckDrop( blob, pos, targetPos, isFacingLeft, null, lobOffset, Soldier::maxThrow, Consts::EXPLOSIVE_DISTANCE * 0.7f, true )){
				data.ai_grenadeOffset = lobOffset;
				return true;
			}
			return false;
		}

	}
}