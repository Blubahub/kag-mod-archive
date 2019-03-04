#include "Consts.as"
#include "States.as"
#include "BrainCommon.as"
#include "SoldierCommon.as"
#include "ClassesCommon.as"

namespace Brain
{
	namespace BlobFlag
	{
		enum blobflag
		{
			DEAD = 1,
			_RESERVED = 2, 
			ON_GROUND = 4,
			CROUCHING = 8,
			VISIBLE = 16,
			LOW_HEALTH = 32,
			DANGER = 128,
			FRIEND = 256,
			ENEMY = 512,
			LOW_AMMO = 1024,
			THROW_SPOT = 2048,
			// assault
			CAN_SHOOT_ME = 4096,
			IN_LINE_OF_FIRE = 8192,
			COVERED_SHOT = 16384,
			SHIELDED = 32768
		}
	}

	bool isDefaultGoal( State@ state )
	{
		BOOL_ONESTATE_CALLBACK@ goalFunc;
		getRules().get("default goal", @goalFunc );
		if (goalFunc !is null){
			return goalFunc( state );
		}
			warn("Default rules goal function not found");
		return false;
	}

	f32 getDefaultGoalDistance( State@ state )
	{
		FLOAT_ONESTATE_CALLBACK@ func;
		getRules().get("default distance", @func );
		if (func !is null){
			return func( state );
		}
			warn("Default rules distance function not found");
		return 0.0f;
	}

	bool isDangerGoal( State@ state, const u32 dangerFlag, bool &out goal )
	{
		Vec2f blobPos = state.o.blob.getPosition();
		goal = false;
		for (uint m_it=0; m_it < state.memory.length; m_it++)
		{
			BlobMemory@ bm = state.memory[m_it];

			if (hasFlag( bm, dangerFlag))
			{
				// never find a goal on a node with a grenade!
				if (bm.node is state.me.node){
					return true;
				}

				if ((bm.pos - blobPos).getLength() < Consts::EXPLOSIVE_DISTANCE)
				{
					// don't run through the explosive
					goal = ( (blobPos.x > bm.pos.x && state.me.pos.x > bm.pos.x) || (blobPos.x < bm.pos.x && state.me.pos.x < bm.pos.x) )
					         && (state.me.pos - bm.pos).getLength() > Consts::EXPLOSIVE_DISTANCE;

					return true;
				}
			}
		}

		return false;
	}

	f32 getActionCost( State@ current, State@ successor, const f32 addCost, const f32 multiplyCost )
	{
		Action@ action = getAction( current, successor );
		if (action !is null){
			const f32 cost = (action.cost + addCost) * multiplyCost;
			// only update first time on pathing, not later during cost update
			if (action.initialCost == 0.0f){
				action.initialCost = cost;
			}
			return cost;
		}

		printf("no action: getcost: " + current.o.name );
		return multiplyCost * (addCost + 1.0f);
	}

	// default reach

	bool CommonIsNodeReachable( CHighMapNode@ node1, CHighMapNode@ node2 )
	{
		CMap@ map = getMap();
		Vec2f pos1 = node1.getWorldPosition();
		Vec2f pos2 = node2.getWorldPosition();
		const bool mapTileRight = map.isTileSolid(map.getTile(pos2 + Vec2f(map.tilesize,0.0f)));
		const bool mapTileLeft = map.isTileSolid(map.getTile(pos2 + Vec2f(-map.tilesize,0.0f)));
		const int add = (mapTileRight || mapTileLeft) ? 1 : 0; // can jump higher if node near wall
		if (pos2.y >= pos1.y - map.tilesize * (4 + add))
		{
			if (pos2.y > pos1.y+8.0f 
				|| (node1.getDistanceFromGround() <= 1)
				|| (node2.getDistanceFromGround() <= 1))
				return true;
		}
		return false;
	}

	// common flags

	bool CommonFlagMemory( State@ state, BlobMemory@ bm )
	{
		CBlob@ blob = getBlob( bm );
		if (blob is null){
			bm.flags = 0;
			return false;
		}
		if (state.o is null || state.o.highlevelnode is null){
			//warn("state node not found");
			return false;
		}
		if (state.o.blob is null){
			//warn("state blob not found");
			return false;
		}
		if (state.me is null || state.me.node is null){
			//warn("state.me.node not found");
			return false;
		}
		if (bm.node is null){ //frequent!
			//warn("bm.node not found");
			return false;
		}

		if (bm.health <= 0.0f){
			AddFlag( bm, Brain::BlobFlag::DEAD );
		}
		else{
			RemoveFlag( bm, Brain::BlobFlag::CROUCHING );
		}

		// classes

		if (blob.hasTag("player")) 
		{
			AddFlag( bm, (bm.team != state.me.team) ? Brain::BlobFlag::ENEMY : Brain::BlobFlag::FRIEND );

			if (blob.hasTag("crouching")){
				AddFlag( bm, Brain::BlobFlag::CROUCHING );
			}
			else
				RemoveFlag( bm, Brain::BlobFlag::CROUCHING );
		}
		else{
			if (blob.hasTag("explosive") && blob.getShape().vellen < 10.0f) {
				AddFlag( bm, Brain::BlobFlag::DANGER );
			}
		}

		const bool onGround = state.o.highlevelnode.getDistanceFromGround() <= 2;
		if (onGround){
			AddFlag( bm, Brain::BlobFlag::ON_GROUND );
		}
		else
			RemoveFlag( bm, Brain::BlobFlag::ON_GROUND );

		const bool enemy = hasFlag( bm, Brain::BlobFlag::ENEMY );
		const bool friend = hasFlag( bm, Brain::BlobFlag::FRIEND );

		if (state.o.blob !is blob) // not me
		{
			// visible from this spot
			const bool crouching = hasFlag( bm, Brain::BlobFlag::CROUCHING );
			const bool meCrouching = hasFlag( state.me, Brain::BlobFlag::CROUCHING );
			const bool onScreen = isScreenDistance( state.me.pos, bm.pos );
			const bool visible = (onScreen
			    && !isObstacleInFrontOfTarget( state.me.pos, meCrouching, bm.pos, crouching, blob.getRadius() ));
			if (visible){
				AddFlag( bm, Brain::BlobFlag::VISIBLE );
			}
			else{
				RemoveFlag( bm, Brain::BlobFlag::VISIBLE );
			}

			// check if soldier can shoot us
			if (enemy && bm.health > 0.0f)
			{
				RemoveFlag( bm, Brain::BlobFlag::CAN_SHOOT_ME );
				if (onScreen){
					Soldier::Data@ data = Soldier::getData( blob );
					if (data.type == Soldier::ASSAULT){
						if (data.ammo > 0 && Brain::isInLineOfFire( state.me.pos, bm.pos )){
							AddFlag( bm, Brain::BlobFlag::CAN_SHOOT_ME );
						}
					}
					else if (data.type == Soldier::SNIPER){
						if (data.ammo > 0 && visible){
							AddFlag( bm, Brain::BlobFlag::CAN_SHOOT_ME );
						}
					}
				}
			}
		}

		if (bm.health < 1.0f){
			AddFlag( bm, Brain::BlobFlag::LOW_HEALTH );
		}
		else{
			RemoveFlag( bm, Brain::BlobFlag::LOW_HEALTH );
		}

		if (bm.ammo < 0.5f || bm.grenades < 0.5f){
			AddFlag( bm, Brain::BlobFlag::LOW_AMMO );
		}
		else{
			RemoveFlag( bm, Brain::BlobFlag::LOW_AMMO );
		}

		// debug display

		if (g_debug > 0) {
			bm.debugtext.clear();
			if (hasFlag( bm, Brain::BlobFlag::FRIEND ))
				bm.debugtext.push_back("FRIEND");
			if (hasFlag( bm, Brain::BlobFlag::ENEMY ))
				bm.debugtext.push_back("ENEMY");
			if (hasFlag( bm, Brain::BlobFlag::CROUCHING ))
				bm.debugtext.push_back("CROUCHING");
			if (hasFlag( bm, Brain::BlobFlag::VISIBLE ))
				bm.debugtext.push_back("VISIBLE");
			if (hasFlag( bm, Brain::BlobFlag::LOW_HEALTH ))
				bm.debugtext.push_back("LOW_HEALTH");
			if (hasFlag( bm, Brain::BlobFlag::LOW_AMMO ))
				bm.debugtext.push_back("LOW_AMMO");
			if (hasFlag( bm, Brain::BlobFlag::DANGER ))
				bm.debugtext.push_back("DANGER");
			if (hasFlag( bm, Brain::BlobFlag::DEAD ))
				bm.debugtext.push_back("DEAD");
		}

		return true;
	}

}
