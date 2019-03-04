
/**
 * Vote functor interface
 * override 
 */
 
shared class VoteFunctor2 {
	VoteFunctor2() {}
	void Pass(bool outcome2) { /* do your vote action in here - remember to check server/client */ }
};

shared class VoteCheckFunctor2 {
	VoteCheckFunctor2() {}
	bool PlayerCanVote2(CPlayer@ player) { return true; }
};

/**
 * The vote object
 */
shared class VoteObject2 {
	
	VoteObject2() {
		@onvotepassed2 = null;
		@canvote2 = null;
		maximum_votes2 = countrequired2 = getPlayersCount();
		current_yes2 = current_no2 = 0;
		timeremaining2 = 1200; //default 30s
		required_percent2 = 0.7f; //default 50%
		required_kick_percent = 0.5f;
		voteReason = "none";
		passed2 = false; 
	}
	
	VoteFunctor2@ onvotepassed2;
	VoteCheckFunctor2@ canvote2;
	
	string succeedaction2;
	string failaction2;
	string voteReason;
	string byuser2;
	
	u16[] players2; //id of players that have voted explicitly
	
	int countrequired2;
	int current_yes2;
	int current_no2;
	int maximum_votes2;
	
	float required_percent2;
	float required_kick_percent;
	bool passed2; //flag so its just called once
	
	int timeremaining2;
};

shared SColor vote_message_colour2() { return SColor(0xff444444); }

void Rules_SetVote(CRules@ this, VoteObject2@ vote)
{
	if(!Rules_AlreadyHasVote(this))
	{
		this.set("g_vote", vote);
		
		client_AddToChat( "--- A Vote was Started by "+vote.byuser2+" ---", vote_message_colour2() );
	}
}

VoteObject2@ Rules_getVote(CRules@ this)
{
	VoteObject2@ vote = null;
	this.get("g_vote", @vote);
	return vote;
}

bool Rules_AlreadyHasVote(CRules@ this)
{
	VoteObject2@ tempvote = Rules_getVote(this);
	if(tempvote is null) return false;
	
	return tempvote.timeremaining2 > 0;
}

//vote methods

bool Vote_Conclusive(VoteObject2@ vote)
{
	return (vote.current_yes2 >= vote.countrequired2 || 
			vote.current_no2 >= vote.countrequired2);
}

bool Vote_WillPass(VoteObject2@ vote)
{
	return (vote.current_yes2 >= vote.countrequired2);
}

void PassVote(VoteObject2@ vote)
{
	vote.timeremaining2 = 0; // so the gui hides and another vote can start
	
	if(vote.onvotepassed2 !is null && !vote.passed2)
	{
		if(Vote_Conclusive(vote))
		{
			bool outcome2 = Vote_WillPass(vote);
			
			vote.onvotepassed2.Pass(outcome2);
			
			client_AddToChat( "--- Vote "+(outcome2? "Passed " : "Failed ")+
								(vote.current_yes2)+" vs "+(vote.current_no2)+
								"  ["+vote.countrequired2+" required] ---", vote_message_colour2() );
		}
		else //inconclusive vote
		{
			client_AddToChat( "--- Vote Inconclusive "+
								(vote.current_yes2)+" vs "+(vote.current_no2)+
								"  ["+vote.countrequired2+" required] ---", vote_message_colour2() );
		}
		
		vote.passed2 = true;
	}
}

/**
 * Check if a player should be allowed to vote - note that this
 * doesn't check if they already have voted
 */

bool CanPlayerVote(VoteObject2@ vote, CPlayer@ player)
{
	if(player is null)
		return false;
	
	if(vote.canvote2 is null)
		return true;
	
	return vote.canvote2.PlayerCanVote2(player);
}

/**
 * Cast a vote from a player, in favour or against
 */
void Vote(VoteObject2@ vote, CPlayer@ p, bool favour)
{
	bool voted = false;
	
	u16 p_id = p.getNetworkID();
	for(uint i = 0; i < vote.players2.length; ++i)
	{
		if(vote.players2[i] == p_id)
		{
			voted = true;
			break;
		}
	}
	
	if(voted)
	{
		//warning about exploits
		warning("double-vote from "+p.getUsername());
	}
	else
	{
		vote.players2.push_back(p_id);
		if(favour)
		{
			vote.current_yes2++;
		}
		else
		{
			vote.current_no2++;
		}
		
		client_AddToChat( "--- "+p.getUsername()+" Voted "+(favour?"In Favour":"Against")+" ---", vote_message_colour2() );
	}
	
}

void CalculateVoteThresholds(VoteObject2@ vote)
{
	vote.maximum_votes2 = 0;
	for(int i = 0; i < getPlayersCount(); ++i)
	{
		if(CanPlayerVote(vote, getPlayer(i)))
		{
			vote.maximum_votes2++;
		}
	}
	
	vote.countrequired2 = Maths::Max(1, s32(Maths::Ceil(vote.maximum_votes2 * vote.required_percent2)) );
}

void CalculateVoteKickThresholds(VoteObject2@ vote)
{
	vote.maximum_votes2 = 0;
	for(int i = 0; i < getPlayersCount(); ++i)
	{
		if(CanPlayerVote(vote, getPlayer(i)))
		{
			vote.maximum_votes2++;
		}
	}
	
	vote.countrequired2 = Maths::Max(1, s32(Maths::Ceil(vote.maximum_votes2 * vote.required_kick_percent)) );
}