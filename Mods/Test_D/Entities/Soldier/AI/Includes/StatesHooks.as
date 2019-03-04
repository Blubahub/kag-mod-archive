#include "States.as"

// ------ Planner Hooks -------

void onPlannerGetSuccessors( PlannerState@ current )
{
	Brain::State@ state = Brain::getState( current );
	if (state is null){
		warn("state null");
		return;
	}
	if (state.funcs.GetSuccessors is null){
		warn(state.o.name + " GetSuccessors null");
		return;
	}

	state.funcs.GetSuccessors( state );
}

f32 onPlannerGetCost( PlannerState@ current, PlannerState@ successor )
{
	Brain::State@ state = Brain::getState( current );
	if (state is null){
		warn("state null");
		return 0.0f;
	}
	if (state.funcs.GetCost is null){
		warn("GetCost null");
		return 0.0f;
	}
	Brain::State@ successorstate = Brain::getState( successor );
	if (successorstate is null){
		warn("successorstate null");
		return 0.0f;
	}

	return state.funcs.GetCost( state, successorstate );
}

f32 onPlannerGoalDistance( PlannerState@ current, PlannerState@ goal )
{
	Brain::State@ state = Brain::getState( current );
	if (state is null){
		warn("state null");
		return 0.0f;
	}
	Brain::State@ goalstate = Brain::getState( goal );
	if (goalstate is null){
		warn("goalstate null");
		return 0.0f;
	}
	if (goalstate.funcs.GoalDistance is null){
		warn(goalstate.o.name + " GoalDistance null");
		return 0.0f;
	}

	return goalstate.funcs.GoalDistance( state );
}

bool onPlannerIsSameState( PlannerState@ state1, PlannerState@ state2 )
{
	Brain::State@ bstate1 = Brain::getState( state1 );
	if (bstate1 is null){
		warn("bstate1 null");
		return true;
	}
	Brain::State@ bstate2 = Brain::getState( state2 );
	if (bstate1 is null){
		warn("bstate1 null");
		return true;
	}

	if (bstate1.funcs.IsSameState !is null)
		return bstate1.funcs.IsSameState( bstate1, bstate2 );
	else
	{
		// default
		bool same = bstate1.o.highlevelnode is bstate2.o.highlevelnode
					&& bstate1.o.name == bstate2.o.name
					&& bstate1.o.hasSameProperties( bstate2.o );
					//printf("same " + same);

		// if (same && bstate1.o.name == "start")	{
		// 	printf("Oh oh - SAME AS START" + bstate1.o.name + " - " + bstate2.o.name + " - " + same );
		// }
		return same;
	}
}

bool onPlannerIsGoal( PlannerState@ current, PlannerState@ goal )
{
	Brain::State@ state = Brain::getState( current );
	if (state is null){
		warn("state null");
		return true;
	}
	Brain::State@ goalstate = Brain::getState( goal );
	if (goalstate is null){
		warn("goalstate null");
		return true;
	}
	if (goalstate.funcs.IsGoal is null){
		warn(goalstate.o.name + " goalFunc null");
		return true;
	}
	const bool isGoal = goalstate.funcs.IsGoal(state, goalstate);
	if (isGoal){
		goal = current;
	}
	return isGoal;
}