namespace Brain
{
	// Planner

	shared class Planner
	{
		State@[] plan;
		int planIndex;
		StateFunctions funcs;
		u32 waitTime;

		// class cache
		Vec2f[] sniperspots;
	};

	Planner@ InitPlanner( CBlob@ this)
	{
		Planner planner;
		planner.waitTime = 0;
		this.set("planner", @planner );
		return getPlanner( this );
	}

	Planner@ getPlanner( CBlob@ this )
	{
		Planner@ planner;
		this.get( "planner", @planner );
		return planner;
	}

	void SetupFunctions( Planner @planner, BOOL_TWOSTATE_CALLBACK @IsGoal,
										   VOID_ONESTATE_CALLBACK @GetSuccessors,
										   FLOAT_TWOSTATE_CALLBACK @GetCost,
										   FLOAT_ONESTATE_CALLBACK @GoalDistance,
										   BOOL_TWOSTATE_CALLBACK @IsSameState,
										   BOOL_TWONODE_CALLBACK @IsNodeReachable,
										   VOID_ONESTATE_CALLBACK @FlagState )
	{
		@planner.funcs.IsGoal = IsGoal;
		@planner.funcs.GetSuccessors = GetSuccessors;
		@planner.funcs.GetCost = GetCost;
		@planner.funcs.GoalDistance = GoalDistance;
		@planner.funcs.IsSameState = IsSameState;
		@planner.funcs.IsNodeReachable = IsNodeReachable;
		@planner.funcs.FlagState = FlagState;
	}


	// Action

	funcdef void VOID_ACTION_CALLBACK( Action@ this );
	funcdef bool BOOL_ACTION_CALLBACK( Action@ this );

	shared class Action
	{
		State@ current;
		State@ next;

		int time;
		f32 cost;
		f32 initialCost;

		VOID_ACTION_CALLBACK@ onStart;
		VOID_ACTION_CALLBACK@ onEnd;
		VOID_ACTION_CALLBACK@ onFail;
		VOID_ACTION_CALLBACK@ onTick;
		BOOL_ACTION_CALLBACK@ isExpected;
		BOOL_ACTION_CALLBACK@ hasFailed;
		BOOL_ACTION_CALLBACK@ isInterrupted;

		bool hasStarted;

		f32 lastDist;

		// for action

		BlobMemory@ target;

		Action(){
			hasStarted = false;
			time = 30;
			cost = initialCost = 0.0f;
			lastDist = 0.0f;
		}
	};

	// BlobMemory

	shared class BlobMemory
	{
		u16 id;
		Vec2f pos;
		Vec2f velocity;
		f32 health;
		u32 time;
		u8 team;
		CHighMapNode@ node;
		f32 ammo;
		f32 grenades;

		// flags

		u32 flags;
		string[] debugtext;

		bool update;

		BlobMemory@ opAssign(const BlobMemory &in other)
	    {
	    	id = other.id;
	    	pos = other.pos;
	    	velocity = other.velocity;
	    	health = other.health;
	    	time = other.time;
	    	team = other.team;
	    	@node = other.node;
	    	flags = other.flags;
	    	update = other.update;
	    	ammo = other.ammo;
	    	grenades = other.grenades;
		    return this;
	    }

	    BlobMemory()
	    {
	    	flags = 0;
	    	update = true;
	    }
	};

	BlobMemory[]@ InitMemory( CBlob@ this )
	{
		BlobMemory[] memory;
		this.set("memory", @memory );
		return getMemory( this );
	}

	BlobMemory[]@ getMemory( CBlob@ this )
	{
		BlobMemory[]@ memory;
		this.get( "memory", @memory );
		return memory;
	}

	bool hasFlag( BlobMemory@ bm, const u32 flag )
	{
		return ((bm.flags & flag) != 0);
	}

	void AddFlag( BlobMemory@ bm, const u32 flag )
	{
		bm.flags &= ~flag;
		bm.flags |= flag;
	}

	void RemoveFlag( BlobMemory@ bm, const u32 flag )
	{
		bm.flags &= ~flag;
	}

	CBlob@ getBlob( BlobMemory@ bm ){
		return bm !is null ? getBlobByNetworkID( bm.id ) : null;
	}

	BlobMemory@ getMemoryOfBlob( CBlob@ blob, BlobMemory[]@ memory )
	{
		return getMemoryOfBlob( blob.getNetworkID(), memory );
	}

	BlobMemory@ getMemoryOfBlob( const u16 netid, BlobMemory[]@ memory )
	{
		for (uint i=0; i < memory.length; i++){
			if (memory[i].id == netid) {
				return memory[i];
			}
		}
		return null;
	}

	// State

	funcdef void VOID_ONESTATE_CALLBACK( State@ state );
	funcdef bool BOOL_ONESTATE_CALLBACK( State@ state );
	funcdef float FLOAT_ONESTATE_CALLBACK( State@ state );
	funcdef bool BOOL_TWOSTATE_CALLBACK( State@ state1, State@ state2 );
	funcdef float FLOAT_TWOSTATE_CALLBACK( State@ state1, State@ state2 );
	funcdef bool BOOL_TWONODE_CALLBACK( CHighMapNode@ node1, CHighMapNode@ node2 );

	shared class StateFunctions
	{
		BOOL_TWOSTATE_CALLBACK @IsGoal;
		VOID_ONESTATE_CALLBACK @GetSuccessors;
		FLOAT_TWOSTATE_CALLBACK @GetCost;
		FLOAT_ONESTATE_CALLBACK @GoalDistance;
		BOOL_TWOSTATE_CALLBACK @IsSameState;
		BOOL_TWONODE_CALLBACK @IsNodeReachable;
		VOID_ONESTATE_CALLBACK @FlagState;
	};

	namespace StateFlag
	{
		shared enum stateflag
		{
			LOCATION = 1,
			BLOB = 2,
			START = 3,
			END = 4,
			DEBUG = 5
		}
	}

	shared class State
	{
		Brain::StateFlag::stateflag type;
		u32 hashcode;

		// owner ptrs

		PlannerState@ o;
		CMap@ map;

		// callbacks

		StateFunctions funcs;

		// state working memory

		BlobMemory[] memory;
		BlobMemory@ me;

		// actions to successors

		dictionary actions;

		// flags
		u32 flags;
		string[] debugtext;
	};

	State@ InitState( PlannerState@ this )
	{
		State state;
		this.set("state", @state);
		return getState( this );
	}

	State@ getState( PlannerState@ this )
	{
		State@ state;
		this.get( "state", @state );
		return state;
	}

	State@ AddState( CBrain@ this, Brain::StateFlag::stateflag type, const string &in name, Vec2f pos = Vec2f_zero )
	{
		PlannerState@ plannerstate = this.AddPlannerState( name );
		State@ state = InitState( plannerstate );
		@state.o = plannerstate;
		@plannerstate.blob = plannerstate.blob;
		@plannerstate.brain = plannerstate.brain;
		@state.map = plannerstate.blob.getMap();
		plannerstate.pos = pos;
		@plannerstate.highlevelnode = state.map.getHighLevelNode( plannerstate.pos );
		if (plannerstate.highlevelnode is null){
			warn("AddState: plannerstate.highlevelnode is null");
		}
		state.type = type;
		state.hashcode = plannerstate.getHashCode();
		return state;
	}

	void Inherit( State@ state, State@ parent )
	{
		@state.funcs.IsGoal = parent.funcs.IsGoal;
		@state.funcs.GetSuccessors = parent.funcs.GetSuccessors;
		@state.funcs.GetCost = parent.funcs.GetCost;
		@state.funcs.GoalDistance = parent.funcs.GoalDistance;
		@state.funcs.IsSameState = parent.funcs.IsSameState;
		@state.funcs.IsNodeReachable = parent.funcs.IsNodeReachable;
		@state.funcs.FlagState = parent.funcs.FlagState;
		state.memory = parent.memory;
		if (parent.memory.length != state.memory.length)
			error("memory copy failed");

		@state.me = getMemoryOfBlob( state.o.blob, state.memory );
		state.flags = parent.flags;
	}

	bool hasFlag( State@ state, const u32 flag )
	{
		return ((state.flags & flag) != 0);
	}

	void AddFlag( State@ state, const u32 flag )
	{
		state.flags &= ~flag;
		state.flags |= flag;
	}

	void RemoveFlag( State@ state, const u32 flag )
	{
		state.flags &= ~flag;
	}

	Action@ getAction( State@ state, State@ nextstate )
	{
		Brain::Action@ action;
		state.actions.get( ""+nextstate.hashcode, @action );
		return action;
	}

}