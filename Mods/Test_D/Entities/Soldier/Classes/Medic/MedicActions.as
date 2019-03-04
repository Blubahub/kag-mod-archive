#include "States.as"
#include "Consts.as"
#include "ActionDrops.as"
#include "CommonStates.as"
#include "SoldierCommon.as"
#include "SoldierPlace.as"
#include "ActionCommon.as"
#include "SoldierCommon.as"

namespace Brain
{
	namespace Medic
	{
		namespace Supply
		{

			void AddState( State@ state, const string &in name, const uint memIndex )
			{
				State@ newstate = Brain::AddState( state.o.brain, Brain::StateFlag::BLOB, name, state.o.pos );
				Inherit( newstate, state );
				BlobMemory@ bm = state.memory[memIndex];// fire at this blob
				BlobMemory@ targetbm = newstate.memory[memIndex];

				// target expected to be healed
				targetbm.health = 1.0f;
				targetbm.ammo = 1.0f;
				targetbm.grenades = 1.0f;
				CommonFlagMemory( newstate, targetbm );

				AddAction( state, newstate, targetbm );
			}

			void AddAction( State@ state, State@ newstate, BlobMemory@ targetbm  )
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
				action.time = 20;
				@action.target = targetbm;

				@action.onTick = onTick;
				action.cost = 1.0f;

				state.actions.set( ""+newstate.hashcode, action );
			}


			void onStart( Action@ this )
			{
				debug("Supply: start ");
				//this.current.o.blob.Chat( XORRandom(2) == 0 ? "This will help you" : "Here you go" );
			}

			void onEnd( Action@ this )
			{
				debug("Supply: end ");
			}

			void onFail( Action@ this )
			{
				debug("Supply: fail ");
			}

			bool isExpected( Action@ this )
			{
				CBrain@ brain = this.current.o.brain;
				CBlob@ target = getBlob( this.target );
				if (target is null)
					return false;

				Soldier::Data@ data = Soldier::getData( target );
				if (target.getHealth() >= target.getInitialHealth() 
					&& data.ammo == data.initialAmmo
					&& data.grenades == data.initialGrenades)
					return true;

				return false;
			}

			bool hasFailed( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				Soldier::Data@ data = Soldier::getData( blob );
				CBlob@ target = getBlob( this.target );
				return this.time <= 0 
						|| target is null						
						|| (target.getPosition() - (blob.getPosition() + data.ai_grenadeOffset)).getLength() > 50.0f;
			}

			bool isInterrupted( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				// check if path has suddenly become too costly
				const f32 currentCost = this.current.funcs.GetCost( this.current, this.next );
				const f32 diff = currentCost - this.initialCost;
				if (diff > 0.0f)
					printf("supply diff " + diff );
				if (diff > 25.0f){
					return true;
				}

				return false;
			}

			void onTick( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Vec2f targetpos = target.getPosition();
				Vec2f pos = blob.getPosition();

				Vec2f throwPos = this.current.o.pos;
				const bool targetOnLeft = targetpos.x < pos.x;
				if (targetOnLeft && pos.x > throwPos.x - 0.0f){
					blob.setKeyPressed( key_left, true );
				}
				else
				if (!targetOnLeft && pos.x < throwPos.x + 0.0f){
					blob.setKeyPressed( key_right, true );
				}
				else {
					Face( blob, targetpos );
					blob.setKeyPressed( key_action2, true );
				}
			}

			// DROP

			bool isThrowSpot( CBlob@ blob, Vec2f pos, Vec2f targetPos, const bool isFacingLeft )
			{
				Soldier::Data@ data = Soldier::getData( blob );
				Vec2f lobOffset;
				if (CheckDrop( blob, pos, targetPos, isFacingLeft, SupplyOffset, lobOffset, 1.0f, 40.0f, false )){
					data.ai_grenadeOffset = lobOffset;
					return true;
				}
				return false;
			}

			Vec2f SupplyOffset( CBlob@ blob, const bool isFacingLeft ){
				Soldier::Data@ data = Soldier::getData( blob );
				Vec2f offset = getPlaceOffset( data );
				return Vec2f( (isFacingLeft ? -1.0f : 1.0f) * Maths::Abs(offset.x), offset.y );
			}

		} // supply


		namespace Shield
		{

			void AddState( State@ state, const string &in name, const uint memIndex )
			{
				State@ newstate = Brain::AddState( state.o.brain, Brain::StateFlag::BLOB, name, state.o.pos );
				Inherit( newstate, state );
				BlobMemory@ bm = state.memory[memIndex];// fire at this blob
				BlobMemory@ targetbm = newstate.memory[memIndex];

				AddAction( state, newstate, targetbm );
			}

			void AddAction( State@ state, State@ newstate, BlobMemory@ targetbm  )
			{
				Action action;
				@action.current = state;
				@action.next = newstate;
				@action.onStart = onStart;
				@action.onEnd = onEnd;
				@action.onFail = onFail;
				@action.hasFailed = hasFailed;
				@action.isInterrupted = isInterrupted;
				action.time = 200;
				@action.target = targetbm;

				@action.onTick = onTick;
				action.cost = 1.0f;

				state.actions.set( ""+newstate.hashcode, action );
			}


			void onStart( Action@ this )
			{
				debug("Shield: start ");
			}

			void onEnd( Action@ this )
			{
				debug("Shield: end ");
			}

			void onFail( Action@ this )
			{
				debug("Shield: fail ");
			}

			bool hasFailed( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				Soldier::Data@ data = Soldier::getData( blob );
				CBlob@ target = getBlob( this.target );
				return (target is null 
					|| this.time <= 0 
					|| (target.getHealth() <= 0.0f)
					|| !hasFlag( this.target, Brain::BlobFlag::CAN_SHOOT_ME));
			}

			bool isInterrupted( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				// check if path has suddenly become too costly
				const f32 currentCost = this.current.funcs.GetCost( this.current, this.next );
				const f32 diff = currentCost - this.initialCost;
				if (diff > 45.0f){
					return true;
				}

				return false;
			}

			void onTick( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Vec2f targetpos = target.getPosition();
				Vec2f pos = blob.getPosition();

				Face( blob, targetpos );
				blob.setKeyPressed( key_action1, true );
			}

		} // 


	}
}