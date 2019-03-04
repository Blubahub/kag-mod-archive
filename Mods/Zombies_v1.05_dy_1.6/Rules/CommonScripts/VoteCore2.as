
//voting generic update and render
#include "VoteCommon2.as"

//extended vote functionality

/**
 * get the rectangle for clicking, the votes will be on either side of this
 */
void getClickRectangle(Vec2f &out top, Vec2f &out bottom)
{
	float x = getScreenWidth()*0.45f - _vis_width*0.5f;
	float y = getScreenHeight()-170;
		
	Vec2f _top(x, y - (Maths::Sin(getGameTime() / 10.0f) + 1.0f) * 4.0f );
	Vec2f _bottom = _top + Vec2f( _vis_width, 100 );
	
	top = _top + Vec2f(15,-70);
	bottom = top + Vec2f(_vis_width-30,100);
}

const float _vis_width = 740.0f;
void RenderVote(VoteObject2@ vote)
{
	bool isVoteKick = false;
	int gamestart = getRules().get_s32("gamestart");
	int day_cycle = getRules().daycycle_speed * 60;
	int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
	s32 mapRecord = getRules().get_s32("mapRecord");
	//string tVoteType;
	//CBitStream params;
	//params.saferead_string(tVoteType);
	string tVoteType = vote.voteReason;
	if(vote.timeremaining2 > 0)
	{
		float x = getScreenWidth()*0.45f - _vis_width*0.5f;
		float y = getScreenHeight()-270;
		
		Vec2f top(x, y - (Maths::Sin(getGameTime() / 10.0f) + 1.0f) * 4.0f );
		Vec2f bottom = top + Vec2f( _vis_width, 100 );
		
		if(!CanPlayerVote(vote,getLocalPlayer()))
		{
			top.x += _vis_width*0.2f;
			bottom.x -= _vis_width*0.2f;
			top.y += 80;
			
			GUI::DrawButtonPressed( top - Vec2f(10,10), bottom + Vec2f(10,10) );
			GUI::DrawText( " Voting In Progress...   ("+Maths::Ceil(vote.timeremaining2/30.0f) +"s)\n" ,
				top+Vec2f(10,0), bottom, color_white, true, true, false );
		}
		else if(!g_have_voted)
		{
			if (tVoteType != "")
			{
				string[] kick_reason_string2 = { "Griefer", "Hacker", "Teamkiller", "Spammer", "AFK" };
				for (uint i = 0; i < kick_reason_string2.length; i++)
				{
					if (kick_reason_string2[i] == tVoteType)
						isVoteKick = true;
				}
			}
			//build vote display
			GUI::DrawButtonPressed( top - Vec2f(10,10), bottom + Vec2f(10,10) );
			
			int _modtime = getGameTime() % 100;
			
			if(_modtime <= 50)
			{
				
				if (dayNumber >= mapRecord && !isVoteKick)
				{
					
					GUI::DrawText( "****** You Can Still Set New Map Survival Records! ******" ,
						top + Vec2f(_vis_width*0.3f,0), bottom, color_black, true, true, false );
				}
				else if (dayNumber < mapRecord && !isVoteKick)
				{
					
					GUI::DrawText( "****** MAP SURVIVAL RECORD HAS NOT BEEN BEAT! ******" ,
						top + Vec2f(_vis_width*0.3f,0), bottom, color_black, true, true, false );
				}
				else
				GUI::DrawText( "!! Vote In Progress !!" ,
						top + Vec2f(_vis_width*0.34f,0), bottom, color_white, true, true, false );
			}
			else
			{
				if (dayNumber >= mapRecord && !isVoteKick)
				{
					
					GUI::DrawText( "###### You Can Still Set New Map Survival Record! ######" ,
						top + Vec2f(_vis_width*0.3f,0), bottom, color_white, true, true, false );
				}
				else if (dayNumber < mapRecord && !isVoteKick)
				{
					
					GUI::DrawText( "###### MAP SURVIVAL RECORD HAS NOT BEEN BEAT! ######" ,
						top + Vec2f(_vis_width*0.3f,0), bottom, color_white, true, true, false );
				}
				else
				GUI::DrawText( "!! Click To Vote !!" ,
						top + Vec2f(_vis_width*0.34f,0), bottom, color_white, true, true, false );
				
			}
			
			GUI::DrawText( "Cast by: " + vote.byuser2 ,
				top + Vec2f(_vis_width*0.5f,80), bottom, color_white, true, true, false );
			
			GUI::DrawText( "Time Remaining: " +  Maths::Ceil(vote.timeremaining2/30.0f) +"s.",
				top + Vec2f(0,80), bottom, color_white, true, true, false );
			
			
			Vec2f _top, _bottom;
			getClickRectangle(_top, _bottom);
			
			{
				_top.x -= 7.0f;
				_bottom = _top + Vec2f(_vis_width*0.5f-15,30);
				GUI::DrawButton( _top - Vec2f(10,10), _bottom + Vec2f(10,10) );
				GUI::DrawText( vote.succeedaction2 ,
					_top, _bottom, color_white, true, true, false );
			}
			
			{
				_top.x += 15.0f;
				_top = _top + Vec2f(_vis_width*0.5f,0);
				_bottom = _top + Vec2f(_vis_width*0.5f-30,30);
				GUI::DrawButton( _top - Vec2f(10,10), _bottom + Vec2f(10,10) );
				GUI::DrawText( vote.failaction2 ,
					_top, _bottom, color_white, true, true, false );
			}
		}
		else
		{
			top.x += _vis_width*0.2f;
			bottom.x -= _vis_width*0.2f;
			top.y += 80;
			
			s32 move_down = (getGameTime() - g_vote_timevar) / 3;
			
			top.y += move_down;
			bottom.y += move_down;
			
			if(bottom.y < getScreenHeight())
			{
				GUI::DrawButtonPressed( top - Vec2f(10,10), bottom + Vec2f(10,10) );
				GUI::DrawText( " Thanks For Voting!   ("+Maths::Ceil(vote.timeremaining2/30.0f) +"s)\n" ,
					top+Vec2f(10,0), bottom, color_white, true, true, false );
			}
		}
	}
}


void UpdateVote(VoteObject2@ vote)
{
	if(vote.timeremaining2 > 0)
	{
		vote.timeremaining2--;
		
		CRules@ rules = getRules();
		
		CalculateVoteThresholds(vote);
		
		if(getNet().isServer() && (
			//time up
			(vote.timeremaining2 == 0) ||
			//decision made
			Vote_Conclusive(vote) ) )
		{
			PassVote(vote); //pass it serverside
			
			CBitStream params;
			rules.SendCommand(rules.getCommandID(voteend_id), params);
		}
		
		CPlayer@ localplayer = getLocalPlayer();
		
		if (getNet().isClient() && CanPlayerVote(vote, localplayer) && !g_have_voted)
		{
			u16 id = 0xffff;
			if(localplayer !is null)
				id = getLocalPlayer().getNetworkID();
			
			bool voted = false;
			bool favour = true;
			
			CControls@ controls = getControls();
			if(controls !is null)
			{
				/*if( controls.isKeyJustPressed(KEY_F11) )
				{
					voted = true;
					favour = false;
				}
				else if (controls.isKeyJustPressed(KEY_F12))
				{
					voted = true;
					favour = true;
				}*/
				
				if( controls.mousePressed1 )
				{
					Vec2f _top, _bottom;
					getClickRectangle(_top, _bottom);
					
					Vec2f mousepos = controls.getMouseScreenPos();
					
					if(mousepos.x > _top.x && mousepos.y > _top.y &&
						mousepos.x < _bottom.x && mousepos.y < _bottom.y)
					{
						voted = true;
						if(mousepos.x > (_top.x + _bottom.x)*0.5f)
						{
							favour = false;
						}
					}
				}
			}
			
			if(voted)
			{
				CBitStream params;
				params.write_u16(id);
				rules.SendCommand(rules.getCommandID(favour ? voteyes_id : voteno_id), params);
				
				g_have_voted = true;
				g_vote_timevar = getGameTime();
			}
		}
	}
}


//hooks

void onRender( CRules@ this )
{
	if(Rules_AlreadyHasVote(this))
	{
		VoteObject2@ vote = Rules_getVote(this);
		RenderVote(vote);
	}
}

bool g_have_voted = false;
s32 g_vote_timevar = 0;

void onTick( CRules@ this )
{
	if(Rules_AlreadyHasVote(this))
	{
		UpdateVote(Rules_getVote(this));
	}
	else
	{
		g_have_voted = false;
		g_vote_timevar = getGameTime();
	}
}

const string voteyes_id = "_vote: yes";		//client "yes" vote
const string voteno_id = "_vote: no";		//client "no" vote
const string voteend_id = "_vote: ended";	//server "vote over"

void onInit(CRules@ this)
{
	this.addCommandID(voteyes_id);
	this.addCommandID(voteno_id);
	this.addCommandID(voteend_id);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	//always allow passing the vote, even if its expired
	if(cmd == this.getCommandID(voteend_id))
	{
		PassVote(Rules_getVote(this));
	}
	
	if(!Rules_AlreadyHasVote(this)) return;
	
	VoteObject2@ vote = Rules_getVote(this);
	u16 id;
	
	if(cmd == this.getCommandID(voteyes_id))
	{
		if(!params.saferead_u16(id))
			return;
		
		CPlayer@ player = getPlayerByNetworkId(id);
		if(CanPlayerVote(vote, player ))
		{
			Vote(vote, player, true);
		}
	}
	else if(cmd == this.getCommandID(voteno_id))
	{
		if(!params.saferead_u16(id))
			return;
		
		CPlayer@ player = getPlayerByNetworkId(id);
		if(CanPlayerVote(vote, player ))
		{
			Vote(vote, player, false);
		}
	}
}
