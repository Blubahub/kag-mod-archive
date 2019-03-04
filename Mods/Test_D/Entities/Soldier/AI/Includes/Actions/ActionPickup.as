#include "States.as"
#include "ActionCommon.as"
#include "SoldierCommon.as"
#include "Consts.as"
#include "ActionDrops.as"
#include "CommonStates.as"

namespace Brain
{
	namespace Pickup
	{
			void AddState( State@ state, const string &in name, const uint memIndex )
			{
				State@ newstate = Brain::AddState( state.o.brain, Brain::StateFlag::BLOB, name, state.o.pos );
				Inherit( newstate, state );
				
				BlobMemory@ bm = state.memory[memIndex];// pickup this blob
				BlobMemory@ targetbm = newstate.memory[memIndex];

				// TEMP: full supply
				newstate.me.health = 1.0f;
				newstate.me.ammo = 1.0f;
				newstate.me.grenades = 1.0f;
				CommonFlagMemory( newstate, newstate.me );

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
				action.time = 120;
				@action.target = targetbm;
				action.cost = 1.0f;

				@action.onTick = onTick;

				state.actions.set( ""+newstate.hashcode, action );
			}


			void onStart( Action@ this )
			{
				printf("Pickup: start ");
			}

			void onEnd( Action@ this )
			{
				printf("Pickup: end ");
			}

			void onFail( Action@ this )
			{
				printf("Pickup: fail ");
			}

			bool isExpected( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				Soldier::Data@ data = Soldier::getData( blob );
				if (blob.getHealth() >= blob.getInitialHealth() 
					&& data.ammo == data.initialAmmo
					&& data.grenades == data.initialGrenades)
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
				if (diff > 70.0f){
					return true;
				}

				return false;
			}

			void onTick( Action@ this )
			{
				CBlob@ blob = this.current.o.blob;
				CBlob@ target = getBlob( this.target );
				Vec2f targetpos = target.getPosition();
	 			
				JustGo( blob, targetpos );
			}
	}
}