
/*
 * Auto balance teams inside a RulesCore
 * 		does a conservative job to avoid pissing off players
 * 		and to avoid forcing many implementation limitations
 * 		onto rulescore extensions so it can be used out of
 * 		the box for most gamemodes.
 */

#include "PlayerInfo.as";
#include "BaseTeamInfo.as";
#include "RulesCore.as";

#define SERVER_ONLY

const int TEAM_DIFFERENCE_THRESHOLD = 1; //max allowed diff

//TODO: store this in rules
enum BalanceType {
	NOTHING = 0,
	SWAP_BALANCE,
	SCRAMBLE,
	SCORE_SORT,
	KILLS_SORT
};

/**
 * BalanceInfo class
 * simply holds the last time we balanced someone, so we
 * don't make some poor guy angry if he's always balanced
 * 
 * we reset this time when you swap team, so that if you
 * imbalance the game, you can be swapped back swiftly
 */
 
class BalanceInfo {
	string username;
	s32 lastBalancedTime;
	
	BalanceInfo() { /*dont use this manually*/ }
	
	BalanceInfo(string _username)
	{ 
		username = _username;
		lastBalancedTime = getGameTime();
	}
};

/*
 * Methods on a global array of balance infos to make the
 * actual hooks much cleaner.
 */

// add a balance info from username
void addBalanceInfo(string username, BalanceInfo[]@ infos)
{
	//check if it's already added
	BalanceInfo@ b = getBalanceInfo(username, infos);
	if (b is null)
		infos.push_back(BalanceInfo(username));
	else 
		b.lastBalancedTime = getGameTime();
}

// get a balanceinfo from a username
BalanceInfo@ getBalanceInfo(string username, BalanceInfo[]@ infos)
{
	for (uint i = 0; i < infos.length; i++)
	{
		BalanceInfo@ b = infos[i];
		if (b.username == username)
			return b;
	}
	return null;
}

// remove a balanceinfo by username
void removeBalanceInfo(string username, BalanceInfo[]@ infos)
{
	for (uint i = 0; i < infos.length; i++)
	{
		if (infos[i].username == username)
		{
			infos.erase(i);
			return;
		}
	}
}

// get the earliest balance time
s32 getEarliestBalance(BalanceInfo[]@ infos)
{
	s32 min = getGameTime(); //not likely to be earlier ;)
	for (uint i = 0; i < infos.length; i++)
	{
		s32 t = infos[i].lastBalancedTime;
		if (t < min)
			min = t;
	}
	
	return min;
}

s32 getAverageBalance(BalanceInfo[]@ infos)
{
	s32 total = 0;
	for (uint i = 0; i < infos.length; i++)
		total += infos[i].lastBalancedTime;
	
	return total / infos.length;
}

u32 getAverageScore(int team)
{
	u32 total = 0;
	u32 count = 0;
	u32 len = getPlayerCount();
	for (uint i = 0; i < len; i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p.getTeamNum() == team)
		{
			count++;
			total += p.getScore();
		}
	}
	
	return (count == 0 ? 0 : total / count);
}

// computes median score using quickselect algorithm - O(n) complexity

u32 getMedianScore(int team)
{
	int[] list;
	int pivot, begin, end, temp;

	for (uint i = 0; i < getPlayerCount(); i++)
		if(getPlayer(i).getTeamNum() == team)
			list.push_back(i);

	begin = 0; end = list.length() - 1;

	while(true)
	{
		pivot = begin + (end - begin) / 2;
		temp = list[end]; list[end] = list[pivot]; list[pivot] = temp; //move pivot to end
		int c = begin;
		for (uint i = begin; i < end; ++i){
			if(getPlayer(list[i]).getScore() < getPlayer(list[end]).getScore())
			{
				temp = list[c]; list[c] = list[i]; list[i] = temp; //move to front
				c++;
			}}
		temp = list[c]; list[c] = list[end]; list[end] = temp; //move pivot to middle

		if(list.length() / 2 == c)
			return getPlayer(list[c]).getScore();
		if(list.length() / 2 < c)
			end = c - 1;
		else
			begin = c + 1;
	}
	return 0;
}

bool MoreKills(BalanceInfo@ a, BalanceInfo@ b)
{
	CPlayer@ first = getPlayerByUsername(a.username);
	CPlayer@ second = getPlayerByUsername(a.username);
	if (first is null || second is null) return false;
	return first.getKills() > second.getKills();
}

bool MorePoints(BalanceInfo@ a, BalanceInfo@ b)
{
	CPlayer@ first = getPlayerByUsername(a.username);
	CPlayer@ second = getPlayerByUsername(a.username);
	if (first is null || second is null) return false;
	return first.getScore() > second.getScore();
}

////////////////////////////////
// force balance all teams

void BalanceAll(CRules@ this, RulesCore@ core, BalanceInfo[]@ infos, int type = SCRAMBLE)
{
	u32 len = infos.length;
	
	switch (type)
	{
		case NOTHING: return;
		
		case SWAP_BALANCE:
			
			getNet().server_SendMsg( "This balance mode isn't programmed yet!" );
			//TODO: swap balance code
			
			break;
		
		case SCRAMBLE:
			
			getNet().server_SendMsg( "Scrambling the teams..." );

			if (len >0)
			{
				infos.insertLast(infos[0]);
				infos.removeAt(0);
			}
			/*infos = len-1
			BalanceInfo b = infos[index];
			infos[index] = infos[i];
			infos[i] = b;*/
			break;
		
		case SCORE_SORT:
		case KILLS_SORT:
			
			getNet().server_SendMsg( "Balancing the teams..." );
			
			{
				bool toggle = (type == KILLS_SORT);
				u32 sortedsect = 0;
				u32 j;
				for (u32 i = 1; i < len; i++)
				{
					j = i;
					BalanceInfo a = infos[i];
					while( (toggle ? MoreKills(infos[j-1], a) : MorePoints(infos[j-1], a)) 
							&& j > 0 )
					{
						infos[j] = infos[j-1];
						j--;
					}
					infos[j] = a;
				}
			}
			
			
			break;
	}
	
	int numTeams = this.getTeamsCount();
	int team = XORRandom(128) % numTeams;
	
	for (u32 i = 0; i < len; i++)
	{
		BalanceInfo@ b = infos[i];
		CPlayer@ p = getPlayerByUsername(b.username);
		
		if (p.getTeamNum() != this.getSpectatorTeamNum() && getTeamSize(core.teams, 1) < getRules().get_s32("max_necros"))
		{		
			b.lastBalancedTime = getGameTime();
			int tempteam = team++ % numTeams;
			core.ChangePlayerTeam(p, tempteam);
		}
		else
		{		
			b.lastBalancedTime = getGameTime();
			int tempteam = 0;
			core.ChangePlayerTeam(p, tempteam);
		}
	}
}

///////////////////////////////////////////////////
//pass stuff to the core from each of the hooks

bool haveRestarted = false;

void onInit( CRules@ this )
{
	onRestart( this );
}

void onRestart( CRules@ this )
{
	this.set_bool("managed teams", true); //core shouldn't try to manage the teams
	
	//set this here, we need to wait
	//for the other rules script to set up the core
	
	BalanceInfo[]@ infos;
	if (!this.get("autobalance infos", @infos) || infos is null)
	{
		BuildBalanceArray(this);
	}
	
	haveRestarted = true;
}

/*
 * build the balance array and store it inside the rules so it can persist
 */

void BuildBalanceArray(CRules@ this)
{
	BalanceInfo[] temp;
	
	for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
	{
		addBalanceInfo(getPlayer(player_step).getUsername(), temp);
	}
	
	this.set("autobalance infos", temp);
}

/*
 * Add a player to the balance list and set its team number
 */

string newestPlayer;

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	RulesCore@ core;
	this.get("core", @core);

	BalanceInfo[]@ infos;
	this.get("autobalance infos", @infos);

	if (core is null ) {
		warn("onNewPlayerJoin: CORE NOT FOUND " );
		return;
	}
	if (infos is null) {
		warn("onNewPlayerJoin: infos NOT FOUND " );
		return;
	}	
	
	addBalanceInfo(player.getUsername(), infos);

	
	if (player.getTeamNum() != this.getSpectatorTeamNum())
	{
		//if (getTeamSize(core.teams, 1) < getRules().get_s32("max_necros"))
		{
			core.ChangePlayerTeam(player, getSmallestTeam( core.teams ));
			newestPlayer = player.getUsername();
		}
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	BalanceInfo[]@ infos;
	this.get("autobalance infos", @infos);

	if (infos is null) return;
	
	removeBalanceInfo(player.getUsername(), infos);
	
}

void onTick(CRules@ this)
{	
	if (haveRestarted || (getGameTime() % 600 == 0) )
	{	
		//get the core and balance infos
		RulesCore@ core;
		this.get("core", @core);

		BalanceInfo[]@ infos;
		this.get("autobalance infos", @infos);

		if (core is null || infos is null) return;
			
		if(haveRestarted) //balance all on start
		{
			haveRestarted = false;
			//force all teams balanced
			int type = SCRAMBLE;

			BalanceAll(this, core, infos, type);
		}
		
		if (getTeamDifference(core.teams) > TEAM_DIFFERENCE_THRESHOLD && getTeamSize(core.teams, 1) < getRules().get_s32("max_necros"))
		{
			getNet().server_SendMsg( "Teams are way imbalanced due to players leaving..." );
			getNet().server_SendMsg( "Remember, swapping to the smaller team makes you a better person!" );
		}
	}
	if (newestPlayer != "")
	{
		RulesCore@ core;
		this.get("core", @core);
		if (getTeamSize(core.teams, 1) > getRules().get_s32("max_necros"))
			core.ChangePlayerTeam(getPlayerByUsername(newestPlayer), s32(0));
		newestPlayer = "";
	}
}

void onPlayerRequestTeamChange( CRules@ this, CPlayer@ player, u8 newTeam )
{
	RulesCore@ core;
	this.get("core", @core);
	if (core is null) return;

	int oldTeam = player.getTeamNum();
	bool spect = (oldTeam == this.getSpectatorTeamNum());
	// print("---request team change--- " + oldTeam + " -> " + newTeam);

	//if a player changes to team 255 (-1), auto-assign
	if (newTeam == 255)
	{
		newTeam = getSmallestTeam(core.teams);
	}
	//if a player changing from team 255 (-1), auto-assign
	if(oldTeam == 255)
	{
		oldTeam = getSmallestTeam(core.teams);
		newTeam = oldTeam;
	}

	int newSize = getTeamSize(core.teams, newTeam);
	int oldSize = getTeamSize(core.teams, oldTeam);

	if (spect && getTeamSize(core.teams, 1) >= getRules().get_s32("max_necros") && newTeam == 1)
	{
		getNet().server_SendMsg( "Already enough necromancers, switching to survivors team");
		core.ChangePlayerTeam(player, 0);
		return;
	}
	if (spect && getTeamSize(core.teams, 1) >= getRules().get_s32("max_necros"))
	{
		core.ChangePlayerTeam(player, 0);
		return;
	}

	if (!getSecurity().checkAccess_Feature(player, "always_change_team")
		&& (!spect && newSize + 1 > oldSize - 1 + TEAM_DIFFERENCE_THRESHOLD //changing to bigger team
		))
	{
		//awww shit, thats a SERVER_ONLY script :/
		// if(player.isMyPlayer()) 
		// 	client_AddToChat("Can't change teams now - it would imbalance them.");
		
		getNet().server_SendMsg( "Switching " + player.getUsername() + " back to " 
			+ (spect ? "spectator" : core.teams[oldTeam].name) + " - teams unbalanced");
	
		return;
	}
	if (getTeamSize(core.teams, 1) >= getRules().get_s32("max_necros") && newTeam == 1)
		return;
	
	core.ChangePlayerTeam(player, newTeam);
}

void onPlayerRequestSpawn( CRules@ this, CPlayer@ player )
{
	RulesCore@ core;
	this.get("core", @core);

	BalanceInfo[]@ infos;
	this.get("autobalance infos", @infos);
	
	if (core is null || infos is null) return;

	BalanceInfo@ b = getBalanceInfo(player.getUsername(), infos);
	if (b is null) return;

	//player is in survivors team and necros amount already reached max
	if ( player.getTeamNum() != 1 && getTeamSize(core.teams, 1) >= getRules().get_s32("max_necros") )
		return;
	
	//player is already in smallest team -> no balance
	if (player.getTeamNum() == getSmallestTeam( core.teams ))
		return;

	//difference is worth swapping for
	if (getTeamDifference(core.teams) <= TEAM_DIFFERENCE_THRESHOLD)
		return;
	
	//player swapped/joined team ages ago -> no balance
	if (b.lastBalancedTime < getAverageBalance(infos))
		return;

	//check if the player doesn't suck - dont swap top half of the team
	u32 median = getMedianScore(player.getTeamNum());
	if (player.getScore() > median)
		return;

	s32 newTeam = getSmallestTeam( core.teams );
	core.ChangePlayerTeam(player, newTeam);
	getNet().server_SendMsg( "Balancing " + b.username + " to " + core.teams[newTeam].name );
	b.lastBalancedTime = getEarliestBalance(infos) - 10; //don't balance this guy again for approximately ever

	// print("DOING BALANCE AND SETTING TEAM - requested "+ player.getTeamNum() 
	// 	+ " set " + getSmallestTeam( core.teams ));
}