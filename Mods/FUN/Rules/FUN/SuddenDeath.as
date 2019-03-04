u32 start_time_minutes = 45;
u32 more_time_minutes = 1;
u32 start_time = start_time_minutes * 60 * 30;
u32 more_time = more_time_minutes * 60 * 30;
bool game_started = false;
bool sudden_death_started = false;
u32 tickets_per_player = 6;
void initAfterWarmup(CRules@ this)
{
	this.set_s32("sudden_death_time", getGameTime() + start_time);
	this.set_u8("sudden_death_power", 0);
	this.Sync("sudden_death_time", true);
	this.Sync("sudden_death_power", true);
}

void onTick(CRules@ this)
{
	if (!getNet().isServer() || !this.isMatchRunning())
		return;
	if (!this.isWarmup() && !game_started)
	{
		initAfterWarmup(this);
		game_started = true;
	}

	s32 starts_in = this.get_s32("sudden_death_time") - getGameTime();
	/*u8 power = this.get_u8("sudden_death_power");
	if (starts_in <= 0)
	{
		this.set_u8("sudden_death_power", power + 1);
		this.set_s32("sudden_death_time", getGameTime() + more_time);
		this.Sync("sudden_death_time", true);
		this.Sync("sudden_death_power", true);
	}*/
	if (starts_in < 0 && !sudden_death_started)
	{
		u32 tickets = getPlayersCount() * tickets_per_player;
		this.set_u32("blue_tickets", tickets);
		this.set_u32("red_tickets", tickets);
		this.Sync("blue_tickets", true);
		this.Sync("red_tickets", true);
		sudden_death_started = true;
	}
}

void onRender(CRules@ this)
{
	//if (!this.exists("sudden_death_time")) drawRulesFont("NOT SET", SColor(255, 255, 255, 255), Vec2f(10, 140), Vec2f(getScreenWidth() - 20, 180), true, false);
	if (!this.isMatchRunning() || !this.exists("sudden_death_time")) return;
	s32 starts_in = this.get_s32("sudden_death_time") - getGameTime();
	u8 power = this.get_u8("sudden_death_power");
	if (starts_in > 0)
	{
		s32 seconds = starts_in / 30;
		s32 minutes = starts_in / 30 / 60;
		s32 seconds_left = seconds - (minutes*60);
		SColor color = SColor(255, 255, 255, 255);
		string text = "";
		if (power == 0)
			text = "Time before Sudden Death: " + minutes + ":" + seconds_left;
		else
			text = "Sudden Death step #" + (power+1) + " in: " + minutes + ":" + seconds_left;
		drawRulesFont(text, color, Vec2f(10, 140), Vec2f(getScreenWidth() - 20, 180), true, false);
	}
	else
	{
		SColor color = SColor(255, 255, 0, 0);
		u32 blue_tickets = this.get_u32("blue_tickets");
		u32 red_tickets = this.get_u32("red_tickets");
		string text = "Blue: " + blue_tickets + "/ Red: " + red_tickets;
		drawRulesFont(text, color, Vec2f(10, 140), Vec2f(getScreenWidth() - 20, 180), true, false);
	}
}

void onRestart(CRules@ this)
{
	game_started = false;
	sudden_death_started = false;
}

void onRulesRestart( CMap@ this, CRules@ rules )
{
	game_started = false;
	sudden_death_started = false;
}

void onReload( CRules@ this )
{
	game_started = false;
	sudden_death_started = false;
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (!getNet().isServer()) return;

	if (victim !is null && attacker !is null)
	{
		if (victim.getTeamNum() == attacker.getTeamNum())
			return;
		//printf("KILLED");
		s32 starts_in = this.get_s32("sudden_death_time") - getGameTime();
		//printf("" + starts_in);
		if (starts_in <= 0)
		{
			u32 blue_tickets = this.get_u32("blue_tickets");
			u32 red_tickets = this.get_u32("red_tickets");
			//printf("" + blue_tickets);
			//printf("" + red_tickets);
			int team = victim.getTeamNum();
			//printf("" + team);
			if (team == 0)
			{
				if (blue_tickets - 1 == 0) 
				{
					this.SetTeamWon(1);
					this.SetCurrentState(GAME_OVER);
					this.SetGlobalMessage("Red Team wins the game!");
				}
				this.set_u32("blue_tickets", blue_tickets - 1);
				this.Sync("blue_tickets", true);
			}
			else if (team == 1)
			{
				if (red_tickets - 1 == 0) 
				{
					this.SetTeamWon(0);
					this.SetCurrentState(GAME_OVER);
					this.SetGlobalMessage("Blue Team wins the game!");
				}
				this.set_u32("red_tickets", red_tickets - 1);
				this.Sync("red_tickets", true);
			}
		}
	}
}