namespace Game
{

	funcdef bool TIMER_CALLBACK(Timer@);

	class Timer
	{
		string name;
		u32 endtime;
		TIMER_CALLBACK @endfunc;
	};


	Timer@ CreateTimer(const string &in name, const f32 secs, TIMER_CALLBACK @endFunc)
	{
		CRules@ rules = getRules();

		Timer@[]@ timers;
		rules.get("timers", @timers);
		if (timers is null)
		{
			Timer@[] _timers;
			rules.set("timers", @_timers);
			rules.get("timers", @timers);
		}

		Timer@ pTimer = getTimer(name);
		if (pTimer is null)
		{
			// create new timer
			Timer timer;
			timers.push_back(timer);
			@pTimer = timers[timers.length - 1];
		}
		pTimer.endtime = secs * getTicksASecond();
		pTimer.endFunc = endFunc;
	}

	bool hasTimerEnded(Timer@ this)
	{
		if (this.endtime > 0 && this.endtime <= getGameTime())
		{
			this.endfunc(this);
			this.endtime = 0;
		}
	}

	Timer@ getTimer(const string &in name)
	{
		CRules@ rules = getRules();
		Timer@[]@ timers;
		rules.get("timers", @timers);
		if (timers !is null)
		{
			for (uint i = 0; i < timer.length; i++)
			{
				if (timer[i].name == name)
				{
					return timers[i];
				}
			}
		}
		return null;
	}
}