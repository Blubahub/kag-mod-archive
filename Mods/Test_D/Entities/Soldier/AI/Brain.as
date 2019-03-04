#define SERVER_ONLY
#include "States.as"
#include "BrainCommon.as"
#include "StatesHooks.as"
#include "PathFinding.as"
#include "SoldierCommon.as"
#include "Memory.as"
#include "ActionCommon.as"

const int DEFAULT_PLANNER_STEPS = 5;
const int DEFAULT_PLANNER_MAX_STEPS = 200;

bool _INIT_HIGHLEVEL = false;

void onInit( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	Brain::InitMemory( blob );
	Brain::InitPlanner( blob );

	this.plannerMaxSteps = DEFAULT_PLANNER_MAX_STEPS;
	this.plannerSearchSteps = DEFAULT_PLANNER_STEPS;
	this.lowLevelSteps = 30;
	this.lowLevelMaxSteps = 91;
	this.failtime_end = 150;

	if (!_INIT_HIGHLEVEL){
		this.SetHighLevelPath(Vec2f_zero, Vec2f(10,0)); //hack!
		_INIT_HIGHLEVEL = true;
	}
}

void onTick( CBrain@ this )
{
    CBlob @blob = this.getBlob();
	Brain::Planner@ planner = Brain::getPlanner( blob );
	const u32 time = getGameTime();

	// TEMP!
	if (getRules().getCurrentState() != GAME){
		return;
	}
	if (blob.hasTag("dead"))
		return;

	if (!this.StatePathStep())
	{
		if (time > planner.waitTime + 15 && (blob.isOnGround() || blob.isOnLadder())
		    && planner.plan.length == 0){
			Plan( this, blob, planner );
		}
	}

	// execute plan
	if (planner.plan.length > 0)
	{
		ExecutePlan( this, blob, planner );
	}
}

void Plan( CBrain@ this, CBlob@ blob, Brain::Planner@ planner )
{
	planner.waitTime = getGameTime();

	Brain::BlobMemory[]@ memory = Brain::getMemory( blob );
	Brain::UpdateMemory( blob, memory );

	// start state

	Brain::State@ start = Brain::AddState( this, Brain::StateFlag::START, "start", blob.getPosition() );
	@start.funcs.IsGoal = planner.funcs.IsGoal;
	@start.funcs.GetSuccessors = planner.funcs.GetSuccessors;
	@start.funcs.GetCost = planner.funcs.GetCost;
	@start.funcs.GoalDistance = planner.funcs.GoalDistance;
	@start.funcs.IsSameState = planner.funcs.IsSameState;
	@start.funcs.IsNodeReachable = planner.funcs.IsNodeReachable;
	@start.funcs.FlagState = planner.funcs.FlagState;
	Brain::CopyMemory( start.memory, memory );
	@start.me = Brain::getMemoryOfBlob( blob, start.memory );
	start.funcs.FlagState( start );

	// end state

	Brain::State@ end = Brain::AddState( this, Brain::StateFlag::END, "end" );
	Brain::Inherit( end, start );

	// plan

	CMap@ map = getMap();
	map.ResetHighLevelNodes();

	if (!this.PlanStatePath( start.o, end.o ))
	{
		warn("Planner path failed");
		onPlanFailure( blob );
	}
}

void ExecutePlan( CBrain@ this, CBlob@ blob, Brain::Planner@ planner )
{
	if (planner.planIndex >= 0 && planner.planIndex < planner.plan.length-1)
	{
		Brain::State@ state = planner.plan[ planner.planIndex ];
		Brain::State@ nextstate = planner.plan[ planner.planIndex+1 ];

		// find action for nextstate
		Brain::Action@ action = Brain::getAction( state, nextstate );
		if (action !is null)
		{
			if (!action.hasStarted){
				if (action.onStart !is null) action.onStart( action );
				action.hasStarted = true;
			}

			if (action.isExpected !is null && action.isExpected( action )){
				if (action.onEnd !is null) action.onEnd( action );
				planner.planIndex++;
				onPlanNext( blob );
				if (planner.planIndex == planner.plan.length-1){
					onPlanEnd( blob );
				}
			}
			else if (action.hasFailed !is null && action.hasFailed( action )){
				if (action.onFail !is null) action.onFail( action );
				onPlanFailure( blob );
			}
			else{
				if (action.onTick !is null) action.onTick( action );
				action.time--;

				if (CheckPlanChanges( this, blob, planner, action))
					return;
			}
		}
		else{
			warn("action not found for nextstate");
			onPlanFailure( blob );
		}
	}
	else{
		onPlanFailure( blob );
	}
}

bool CheckPlanChanges( CBrain@ this, CBlob@ blob, Brain::Planner@ planner, Brain::Action@ action )
{
	for (uint i=planner.planIndex; i < planner.plan.length-1; i++){
		Brain::State@ itstate = planner.plan[ i ];
		Brain::State@ itnextstate = planner.plan[ i+1 ];
		Brain::Action@ itaction = Brain::getAction( itstate, itnextstate );
		if (itaction.isInterrupted is null)
			continue;

		const u16 targetId = itaction.target !is null ? itaction.target.id : 0;
		itstate.me.update = false; // don't update ourselves, cause we use position predictions

		Brain::UpdateMemory( blob, itstate.memory ); // update = false = predictions

		// restore or null target if was removed in update
		if (targetId > 0){
			@itaction.target = Brain::getMemoryOfBlob( targetId, itstate.memory );
		}
		itstate.funcs.FlagState( itstate );

		if (itaction.isInterrupted( itaction )){
			debug("plan interrupted");
			planner.waitTime = 0; // immediate replan
			action.onEnd( action );
			onPlanEnd( blob );
			this.plannerSearchSteps = DEFAULT_PLANNER_STEPS * 4; // we need to plan this fast
			this.plannerMaxSteps = DEFAULT_PLANNER_MAX_STEPS / 2;
			return true;
		}
	}
	return false;
}


void onPlannerSolution( CBrain@ this )
{
	CBlob@ blob = this.getBlob();

	PlannerState@[] solution;
	if (this.getPlannerSolution( solution ))
	{
		Brain::Planner@ planner = Brain::getPlanner( blob );

		for (uint i=0; i < solution.length; i++)
		{
			PlannerState@ plannerstate = solution[i];
			Brain::State@ state = Brain::getState( plannerstate );
			@state.o = plannerstate; // fix pointer cause old one was deleted

			// check if this path isnt wrong (goes through start)
			// if (i > 0 && state.type == Brain::StateFlag::LOCATION)
			// {
			// 	for (uint j=0; j < i; j++)
			// 		if (i != j)
			// 		{
			// 			Brain::State@ state2 = Brain::getState( solution[j] );
			// 			if (state2.type == Brain::StateFlag::BLOB) // stop checking for silly path if an action is present
			// 				break;
			// 			if (state2.type == Brain::StateFlag::LOCATION && plannerstate.highlevelnode is solution[j].highlevelnode){
			// 				printf("silly path " + j +":" + state2.o.name + " " + i + ":" + state.o.name );
			// 				return;
			// 			}
			// 		}
			// }

			planner.plan.push_back( state );
			//printf("getDistanceFromGround " + state.o.highlevelnode.getDistanceFromGround() );
			debug("["+i+"]"+" " + plannerstate.name);
		}
	}

	Brain::Planner@ planner = Brain::getPlanner( blob );
	planner.planIndex = 0;
	onPlanStart( blob );

}

void onPlanStart( CBlob@ blob )
{
	CBrain@ brain = blob.getBrain();
	brain.getVars().lastPathPos	= Vec2f_zero;
	brain.getVars().lastPathPos2 = Vec2f_zero;
}

void onPlanEnd( CBlob@ blob )
{
	debug("plan end");
	Brain::Planner@ planner = Brain::getPlanner( blob );
	planner.planIndex = -1;
	planner.plan.clear();
	blob.getBrain().plannerSearchSteps = DEFAULT_PLANNER_STEPS; // default plan speed
}

void onPlanNext( CBlob@ blob )
{
	onPlanStart( blob );
}

void onPlanFailure( CBlob@ blob )
{
	debug("plan failed");
	onPlanEnd( blob );
}



// CSPRITE RENDER

void DrawPlan( CBrain@ this, CBlob@ blob, Brain::Planner@ planner )
{
	if (planner !is null && planner.planIndex >= 0 && planner.planIndex < planner.plan.length-1)
	{
		Brain::State@ state = planner.plan[ planner.planIndex ];
		Brain::State@ nextstate = planner.plan[ planner.planIndex+1 ];

		Brain::Action@ action = Brain::getAction( state, nextstate );
		if (action !is null && action.hasStarted)
		{
			CBlob@ target = Brain::getBlob( action.target );
			if (target !is null){
				GUI::DrawArrow(state.me.pos, target.getPosition(), SColor(255,255, 40, 50));
			}
		}
	}
}

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	CBrain@ brain = blob.getBrain();

	if (!brain.isActive())
		return;

	if (g_debug > 0)
	{
		Vec2f pos = blob.getPosition();
		const f32 yoffset = 130.0f;

		GUI::SetFont("irrlicht");

		PlannerState@[] plannerStates;
		if (g_debug > 1 && brain.getPlannerStates( plannerStates ))
		{
			for (uint i=0; i < plannerStates.size(); i++)
			{
				PlannerState@ ps = plannerStates[i];
				Brain::State@ state = Brain::getState( ps );

				Vec2f pos2d = getDriver().getScreenPosFromWorldPos( ps.pos );

				//if (!ps.solution)
					//continue;
//				if (state.type != Brain::StateType::LOCATION) continue;
					//if (ps.name != "enemy dead") continue;


				GUI::DrawLine( ps.pos, ps.pos + Vec2f(0,15), SColor(0x35626d22) );
				GUI::DrawRectangle( pos2d + Vec2f(-40, yoffset - 10.0f), pos2d +Vec2f( 60, yoffset + (state.memory.length + 2)*10 ), ps.solution ? SColor(0xa5526d22) : SColor(0x75323d32) );

				GUI::DrawText( ps.name + " " + (ps.highlevelnode !is null ? ps.highlevelnode.getDistanceFromGround() : -1), pos2d + Vec2f(-10.0f, yoffset - 10.0f) , 
					ps.solution ? SColor(255, 19,229,99) : SColor(255, 214,219,19) );

				f32 more = 0.0f;
				for (uint i=0; i < state.memory.length; i++) {
					Brain::BlobMemory@ bm = state.memory[i];
					Brain::RenderMemory( bm, pos2d + Vec2f(-40.0f, yoffset + i*10.0f + more), ps.blob.getNetworkID() == bm.id, ps.team == bm.team );
					more += bm.debugtext.length * 10.0f;
				}
			}
		}

		PlannerState@[] solution;
		if (brain.getPlannerSolution( solution ))
		{
		//	GUI::DrawArrow( pos, solution[0].pos, SColor(255,245,175,95));
			//printf("solution[0].pos " + solution[0].name + " " + solution[0].pos.x + " " + solution[0].pos.y );
			for (uint i=0; i < solution.size()-1; i++)
			{
				PlannerState@ state = solution[i];
				PlannerState@ nextstate = solution[i+1];
				GUI::DrawArrow(state.pos, nextstate.pos, SColor(255,255-10*i,175-10*i,115-10*i));
			}
		}

		DrawPlan( brain, blob, Brain::getPlanner( blob ) );
	}

}
