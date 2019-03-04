namespace SimpleBrain
{
	funcdef void PRIORITIZE_CALLBACK(CBlob@, State@);
	funcdef void DO_CALLBACK(CBlob@, State@);

	shared class State
	{
		string type;
		f32 priority;
		DO_CALLBACK@ doFunc;
		PRIORITIZE_CALLBACK@ prioritizeFunc;
		dictionary vars;

		State(string _type, PRIORITIZE_CALLBACK@ _prioritizeFunc, DO_CALLBACK@ _doFunc)
		{
			type = _type;
			priority = 0.0f;
			@doFunc = _doFunc;
			@prioritizeFunc = _prioritizeFunc;
		}

		int opCmp (const State &in other) const { 
			return (other.priority < priority) ? 1 : -1;
		}		
	}

	shared class States
	{
		State@[] available;
		State@[] possible;

		int searchState;
		int stateTime;				

		State@ getCurrent()
		{
			if (possible.length > 0)
				return possible[0];
			return null;
		}

		States()
		{
			searchState = 0;
			stateTime = 0;			
		}
	}

	States@ InitStates( CBlob@ this )
	{
		States states;	  
		this.set("states", @states);	
		return getStates( this );
	}

	States@ getStates( CBlob@ this )
	{
		States@ states;
		this.get( "states", @states );
		return states;
	}

	void SortStates( States@ states )
	{
		states.possible.sortDesc();
	}

}