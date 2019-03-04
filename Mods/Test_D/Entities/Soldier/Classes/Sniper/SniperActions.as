#include "States.as"
#include "ActionCommon.as"
#include "SoldierCommon.as"
#include "Consts.as"
#include "CommonStates.as"

namespace Brain
{
	namespace Sniper
	{
		namespace Snipe
		{
			void AddState( State@ state, const string &in name, const uint memIndex )
			{
				State@ newstate = Brain::AddState( state.o.brain, Brain::StateFlag::BLOB, name, state.o.pos );
				Inherit( newstate, state );
				
				BlobMemory@ bm = state.memory[memIndex]; // fire at this blob
				BlobMemory@ targetbm = newstate.memory[memIndex];

				AddAction( state, newstate );
			}

			void AddAction( State@ state, State@ newstate )
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
				action.cost = 1.0f;
				@action.onTick = onTick;

				state.actions.set( ""+newstate.hashcode, action );
			}


			void onStart( Action@ this )
			{
				printf("Snipe: start ");
			}

			void onEnd( Action@ this )
			{
				printf("Snipe: end ");
			}

			void onFail( Action@ this )
			{
				printf("Snipe: fail ");
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

			void onTick( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Soldier::Data@ data = Soldier::getData( blob );
				Vec2f pos = blob.getPosition();
			}

		} // Snipe	


	}
}