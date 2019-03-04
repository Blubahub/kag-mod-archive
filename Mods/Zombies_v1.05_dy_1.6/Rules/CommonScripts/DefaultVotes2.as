
#include "VoteCommon2.as"

//votekick and vote nextmap

const string votekick_id2 = "vote: kick";
const string votenextmap_id2 = "vote: nextmap";

s32 g_lastVoteCounter2 = 0;
bool g_haveStartedVote2 = false;
const s32 _required_minutes2 = 4;
const s32 _required_time2 = 120*getTicksASecond()*_required_minutes2;

const s32 VoteKickTime2 = 30*60; //seconds

//kicking related globals and enums
enum kick_reason2 {
	kick_reason_griefer = 0,
	kick_reason_hacker,
	kick_reason_teamkiller,
	kick_reason_spammer,
	kick_reason_afk,
	kick_reason_count,
};
string[] kick_reason_string2 = { "Griefer", "Hacker", "Teamkiller", "Spammer", "AFK" };

string g_kick_reason2 = kick_reason_string2[kick_reason_griefer]; //default

//kicking related globals and enums
enum nextmap_reason2 {
	nextmap_reason_ruined = 0,
	nextmap_reason_stalemate,
	nextmap_reason_bugged,
	nextmap_reason_count = 2,
};

string[] nextmap_reason_string2 = { "SKIP BEATING/EXTENDING MAP SURVIVAL RECORD", "Dont care about map survival record"};
		//int gamestart = rules.get_s32("gamestart");
		//int day_cycle = getRules().daycycle_speed * 60;
		//int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
		//s32 mapRecord = rules.get_s32("mapRecord");
//set up the ids

void onInit(CRules@ this)
{
	this.addCommandID(votekick_id2);
	this.addCommandID(votenextmap_id2);
}

void onTick(CRules@ this)
{
	if(g_lastVoteCounter2 < _required_time2)
		g_lastVoteCounter2++;
}

//VOTE KICK --------------------------------------------------------------------
//function to actually start a votekick

void StartVoteKick(CPlayer@ player, CPlayer@ byplayer, string reason)
{
	if(getSecurity().checkAccess_Feature( player, "kick_immunity" ))
		return;

	CRules@ rules = getRules();
	
	CBitStream params;
	
	params.write_u16(player.getNetworkID());
	params.write_u16(byplayer.getNetworkID());
	params.write_string(reason);
	
	rules.SendCommand(rules.getCommandID(votekick_id2), params);
}

//votekick functor

class VoteKickFunctor : VoteFunctor2 {
	VoteKickFunctor() {} //dont use this
	VoteKickFunctor(u16 _playerid, u16 _byid)
	{
		playerid = _playerid;
		byid = _byid;
	}
	
	u16 playerid, byid;
	
	void Pass(bool outcome2)
	{
		CPlayer@ kickplayer = getPlayerByNetworkId(playerid);
		CPlayer@ byplayer = getPlayerByNetworkId(byid);
		
		if(kickplayer is null || byplayer is null) return;
		
		if(outcome2)
		{
			client_AddToChat( "Vote Kick Passed! "+kickplayer.getUsername()+" will be kicked out.", vote_message_colour2() );
		}
		else
		{
			client_AddToChat( "Vote Kick Failed! "+byplayer.getUsername()+" will be kicked out.", vote_message_colour2() );
		}
		
		if(getNet().isServer())
		{
			BanPlayer(outcome2 ? kickplayer : byplayer, VoteKickTime2); //30 minutes ban
		}
	}
};

class VoteKickCheckFunctor : VoteCheckFunctor2 {
	VoteKickCheckFunctor() {}
	VoteKickCheckFunctor(u16 _playerid, u16 _byid)
	{
		playerid = _playerid;
		byid = _byid;
	}
	
	u16 playerid, byid;
	
	bool PlayerCanVote2(CPlayer@ player)
	{
		u16 id = player.getNetworkID();
		return (id != playerid && id != byid);
	}
	
};

//setting up a votekick object
VoteObject2@ Create_Votekick(CPlayer@ player, CPlayer@ byplayer, string reason)
{
	VoteObject2 vote;
	
	{
		VoteKickFunctor f(player.getNetworkID(), byplayer.getNetworkID());
		@vote.onvotepassed2 = f;
	}
	{
		VoteKickCheckFunctor f(player.getNetworkID(), byplayer.getNetworkID());
		@vote.canvote2 = f;
	}
	
	vote.succeedaction2 = "Kick "+ player.getUsername() +"\n(accused "+reason+")";
	vote.failaction2 = "Kick "+ byplayer.getUsername() +"\n(started votekick)";
	vote.byuser2 = byplayer.getUsername();
	
	//vote.required_kick_percent = 0.5f;

	CalculateVoteKickThresholds(vote);
	//vote.timeremaining = 600;
	vote.voteReason = reason;
	return vote;
}

//VOTE NEXT MAP ----------------------------------------------------------------
//function to actually start a votekick

void StartVoteNextMap(CPlayer@ byplayer, string reason)
{
	CRules@ rules = getRules();
	
	CBitStream params;
	
	params.write_u16(byplayer.getNetworkID());
	params.write_string(reason);
	
	rules.SendCommand(rules.getCommandID(votenextmap_id2), params);
}

//nextmap functor

class VoteNextmapFunctor : VoteFunctor2 {
	VoteNextmapFunctor() {} //dont use this
	VoteNextmapFunctor(CPlayer@ player, string _reason)
	{
		playername = player.getUsername();
		reason = _reason;
	}
	
	string playername;
	string reason;
	void Pass(bool outcome2)
	{
		if(outcome2)
		{
			client_AddToChat( "Vote Next Map Passed!", vote_message_colour2() );
		}
		else
		{
			client_AddToChat( "Vote Next Map Failed! ", vote_message_colour2() );
			client_AddToChat( playername+" needs to take a spoonful of cement! (Play on!)", vote_message_colour2() );
		}
		
		if(getNet().isServer())
		{
			if(outcome2)
			{
				LoadNextMap();
			}
		}
	}
};


//setting up a vote next map object
VoteObject2@ Create_VoteNextmap(CPlayer@ byplayer, string reason)
{
	VoteObject2 vote;
	
	{
		VoteNextmapFunctor f(byplayer, reason);
		@vote.onvotepassed2 = f;
	}
	
	vote.succeedaction2 = "Reason: "+reason+"\nSkip to next map.";
	vote.failaction2 = "Stay and beat/extend map record and do NOT skip to next map";
	
	vote.byuser2 = byplayer.getUsername();
	
	//vote.required_percent = 0.7f;
	CalculateVoteThresholds(vote);
	vote.voteReason = reason;
	
	//vote.timeremaining = 600;
	
	return vote;
}


//actually setting up the votes
void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(Rules_AlreadyHasVote(this))
		return;
	
	if (cmd == this.getCommandID(votekick_id2))
	{
		u16 playerid, byplayerid;
		string reason;
		
		if(!params.saferead_u16(playerid)) return;
		if(!params.saferead_u16(byplayerid)) return;
		if(!params.saferead_string(reason)) return;
		
		CPlayer@ player = getPlayerByNetworkId(playerid);
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);
		
		if(player !is null && byplayer !is null)
		{
			VoteObject2@ votekick = Create_Votekick(player, byplayer, reason);
			
			Rules_SetVote(this, votekick);
		}
	}
	else if(cmd == this.getCommandID(votenextmap_id2))
	{
		u16 byplayerid;
		string reason;
		
		if(!params.saferead_u16(byplayerid)) return;
		if(!params.saferead_string(reason)) return;
		
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);
		
		if(byplayer !is null)
		{
			VoteObject2@ vote = Create_VoteNextmap(byplayer, reason);
			
			Rules_SetVote(this, vote);
		}
	}
	
}

//create the votes

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	//get our player first - if there isn't one, move on
	CPlayer@ p = getLocalPlayer();
	if(p is null) return;
	
	int p_team = p.getTeamNum();
	
	CRules@ rules = getRules();
	
	if(Rules_AlreadyHasVote(rules))
	{
		Menu::addContextItem(menu, "(Vote already in progress)", "DefaultVotes2.as", "void _CloseMenu()");
		Menu::addSeparator(menu);
		
		return;
	}
	
	//not in game long enough
	if(g_lastVoteCounter2 < _required_time2 &&
		!(getLocalPlayer() !is null && (getLocalPlayer().isMod() ||
			getSecurity().checkAccess_Feature( getLocalPlayer(), "skip_votewait") )) )
	{
		if(!g_haveStartedVote2)
		{
			Menu::addInfoBox(menu, "Can't Start Vote Yet", "Voting is only available after\n"+
															"at least "+_required_minutes2+" min of play to\n"+
															"prevent spamming/abuse.\n");
		}
		else
		{
			Menu::addInfoBox(menu, "Can't Start Vote", "Voting requires a wait\n"+
														"after each casted vote to\n"+
														"prevent spamming/abuse.\n");	
		}
		Menu::addSeparator(menu);
		
		return;
	}
	
	//and advance context menu when clicked
	CContextMenu@ votemenu = Menu::addContextMenu(menu, "Vote");
	
	//add separator afterwards
	Menu::addSeparator(menu);
	
	//vote options menu
	
	CContextMenu@ kickmenu = Menu::addContextMenu(votemenu, "Kick");
	CContextMenu@ mapmenu = Menu::addContextMenu(votemenu, "Next Map");
	Menu::addSeparator(votemenu); //before the back button
	
	//kick menu
	Menu::addInfoBox(kickmenu, "Vote Kick", "Vote to kick a player on your team\nout of the game.\n\n"+
											"- use responsibly\n"+
											"- report any abuse of this feature.\n"+
											"\nTo Use:\n\n"+
											"- select a reason from the\n     list (default is griefing).\n"+
											"- select a name from the list.\n"+
											"- everyone votes.\n"+
											"- be careful, if your vote\n     fails conclusively,\n     YOU WILL BE KICKED.");
	
	Menu::addSeparator(kickmenu);
	
	//reasons
	for(uint i = 0 ; i < kick_reason_count; ++i)
	{
		CBitStream params;
		params.write_u8(i);
		Menu::addContextItemWithParams(kickmenu, kick_reason_string2[i], "DefaultVotes2.as", "Callback_KickReason", params);
	}
	
	Menu::addSeparator(kickmenu);
	
	//write all players on our team
	int playerscount = getPlayersCount();
	int SPECTATOR_TEAM = this.getSpectatorTeamNum();
	bool added = false;
	for(int i = 0; i < playerscount; ++i)
	{
		CPlayer@ _player = getPlayer(i);
		
		if(_player is p) continue; //don't display ourself for kicking
		
		int _player_team = _player.getTeamNum();
		if( ( _player_team == p_team || _player_team == SPECTATOR_TEAM ) &&
			( !getSecurity().checkAccess_Feature( _player, "kick_immunity" ) ) ) //TODO: check seclevs properly
		{
			string descriptor = _player.getCharacterName();

			if( _player.getUsername() != _player.getCharacterName() )
			{
				descriptor += " ("+_player.getUsername()+")";
			}

			string item = "Kick "+descriptor;

			CContextMenu@ _usermenu = Menu::addContextMenu(kickmenu, item);

			Menu::addInfoBox(_usermenu, "Kicking "+descriptor, "Make sure you're voting to kick\nthe person you meant.\n");

			Menu::addSeparator(_usermenu);

			CBitStream params;
			params.write_u16(_player.getNetworkID());

			Menu::addContextItemWithParams(_usermenu, "Yes, I'm sure", "DefaultVotes2.as", "Callback_Kick", params);
			added = true;

			Menu::addSeparator(_usermenu);
		}
	}
	
	if(!added)
	{
		Menu::addContextItem(kickmenu, "(No-one available)", "DefaultVotes2.as", "void _CloseMenu()");
	}
	
	Menu::addSeparator(kickmenu);
	
	//nextmap menu
	
	Menu::addInfoBox(mapmenu, "Vote Next Map", "Vote to change the map\nto the next in cycle.\n\n"+
											"- report any abuse of this feature.\n"+
											"\nTo Use:\n\n"+
											"- select a reason from the list.\n"+
											"- everyone votes.\n");
	
	Menu::addSeparator(mapmenu);
	//reasons
	for(uint i = 0 ; i < nextmap_reason_count; ++i)
	{
		CBitStream params;
		params.write_u8(i);
		Menu::addContextItemWithParams(mapmenu, nextmap_reason_string2[i], "DefaultVotes2.as", "Callback_NextMap", params);
	}
	
	Menu::addSeparator(mapmenu);
}

void _CloseMenu()
{
	Menu::CloseAllMenus();
}

void onPlayerStartedVote()
{
	g_lastVoteCounter2 /= 2;
	g_haveStartedVote2 = true;
}

void Callback_KickReason(CBitStream@ params)
{
	u8 id; if(!params.saferead_u8(id)) return;
	
	if(id < kick_reason_count)
	{
		g_kick_reason2 = kick_reason_string2[id];
	}
}

void Callback_Kick(CBitStream@ params)
{
	_CloseMenu(); //definitely close the menu
	
	CPlayer@ p = getLocalPlayer();
	if(p is null) return;
	
	u16 id; if(!params.saferead_u16(id)) return;
	
	CPlayer@ other_player = getPlayerByNetworkId(id);
	
	if(other_player is null) return;
	
	StartVoteKick(other_player, p, g_kick_reason2);
	onPlayerStartedVote();
}


void Callback_NextMap(CBitStream@ params)
{
	_CloseMenu(); //definitely close the menu
	
	CPlayer@ p = getLocalPlayer();
	if(p is null) return;
	
	u8 id; if(!params.saferead_u8(id)) return;
	
	string reason = "";
	if(id < nextmap_reason_count)
	{
		reason = nextmap_reason_string2[id];
	}
	
	StartVoteNextMap(p, reason);
	onPlayerStartedVote();
}

//ban a player if they leave
void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	if(Rules_AlreadyHasVote(this)) //vote is still going
	{
		VoteObject2@ vote = Rules_getVote(this);	

		//is it a votekick functor?
		{
			VoteKickFunctor@ f = cast<VoteKickFunctor@>(vote.onvotepassed2);
			if(f !is null)
			{
				CPlayer@ kickplayer = getPlayerByNetworkId(f.playerid);
				if(kickplayer is player)
				{
					client_AddToChat( kickplayer.getUsername()+" left early, acting as if they were kicked.", vote_message_colour2() );
					BanPlayer(player, VoteKickTime2);
				}
			}
		}
	}
}

