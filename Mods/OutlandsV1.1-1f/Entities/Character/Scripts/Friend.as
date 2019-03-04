
void ResetFriends( CRules@ this, int team1 )
{
	for(uint team2 = 0; team2 < this.getTeamsCount(); team2++)
	{
		if (team1 != team2)
		{
	   		this.set_u8("friend_" + team2 + "|" + team1, 0);
			
			if (getNet().isServer())
			{
		    	this.Sync("friend_" + team2 + "|" + team1, true);
			}
		}
	}
}

void addFriend( CRules@ rules, int team1, int team2)
{
    if (rules !is null)
	{
	    // SET
	    rules.set_u8("friend_" + team2 + "|" + team1, 1);
		
		// SYNC
		if (getNet().isServer())
		{
			rules.Sync("friend_" + team2 + "|" + team1, true);
		}
	}
}

int isFriend( CRules@ rules, int team1, int team2 )
{
    if(team1 == team2)
	    return 1;
	
    u8 isfriend = rules.get_u8("friend_" + team1 + "|" + team2);
	
	return isfriend;
}

bool isFriendly( u8 team1, u8 team2 )
{
    return team1 == team2 || isFriend(getRules(), team1, team2) == 1;
}