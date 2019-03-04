#include "GameColours.as"
#include "Timers.as"
#include "TRChatCommon.as"
#include "RulesCommon.as"
#include "RadioCharacters.as"
#include "ClassesCommon.as"
#include "PlayerStatsCommon.as"
#include "HoverMessages.as"

string[] _positiveChats =
{
	"Go team!",
	"Together!",
	"Hurray!",
	"Yeah!",
	"We'll get em!"
};
string[] _negativeChats =
{
	"Wanker!",
	"Baddie!",
	"Stinker!",
	"Pigface!",
	"Poophead!",
	"Fartbutt!",
	"Idiot!"
};

Portrait[] _portraits;

Portrait@[] _allchats;

void onInit(CRules@ this)
{
	this.addCommandID("say_portrait");
	_allchats.clear();
}

void onStateChange(CRules@ this, const u8 oldState)
{
	const u8 state = this.getCurrentState();
	if (state == INTERMISSION)
	{
		printf("RESET STATE VIEW");
		_allchats.clear();
	}
}

void onRestart(CRules@ this)
{
	_allchats.clear();
	for (u32 i = 0; i < _portraits.length; i++)
	{
		_portraits[i].fields.clear();
	}
}

void onTick(CRules@ this)
{
	CControls@ controls = getControls();
	if (controls is null || !getNet().isClient())
		return;

	UpdatePlayerPortraits(this);

	//gamemode specific stuff
	if (this.get_string("gamemode") == "Campaign" && this.isIntermission())
	{
		for (u32 i = 0; i < _portraits.length; i++)
		{
			EnsurePresent(_portraits[i]);
		}

		CPlayer@ local = getLocalPlayer();
		Random _r(getGameTime());
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)))
		{
			SendChat(this, local.getNetworkID(), _positiveChats[_r.NextRanged(_positiveChats.length)]);
		}
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2)))
		{
			SendChat(this, local.getNetworkID(), _negativeChats[_r.NextRanged(_negativeChats.length)]);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	CPlayer@ player;
	if (getNet().isClient() && cmd == this.getCommandID("say_portrait"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		string s = params.read_string();
		if (player is null)
			return;

		if (player.isMyPlayer())
		{
			Sound::Play("buttonclick");
		}

		Portrait@ p = getPortraitOfPlayer(player, _portraits);
		if (p is null)
			return;

		//AddMessageTimed( player.getBlob(), s, 200 );

		p.lastSpoke = Time();
		p.showTimer = 1.0f;
		string[] newchats = chopChatLines(s);
		if (newchats.length > 0)
		{
			newchats[0] = '"' + newchats[0];
			for (u32 i = 1; i < newchats.length; i++)
			{
				newchats[i] = " " + newchats[i];
			}
			newchats[newchats.length - 1] = newchats[newchats.length - 1] + '"';
		}

		if (p.chat.length == 0)
		{
			p.chatTimer = timeForLine(newchats[0]);
		}
		else
		{
			newchats.insertAt(0, "");
		}

		for (u32 i = 0; i < newchats.length; i++)
		{
			p.chat.push_back(newchats[i]);
		}

		EnsurePresent(p);
	}

}

void onRender(CRules@ this)
{
	if (this.get_s16("in menu") != 0)
		return;

	Driver@ driver = getDriver();
	Vec2f screenDim = driver.getScreenDimensions();
	Vec2f screenCenter = driver.getScreenCenterPos();
	const u32 time = getGameTime();

	{
		const s32 team_width = 160;
		const s32 team_margin = 4;

		GUI::SetFont("gui");
		const f32 portraitVerticalSpace = 62;
		Vec2f team1pos(screenDim.x * 0.05f, 0.0f + portraitVerticalSpace / 2);
		Vec2f team2pos(screenDim.x * 0.95f, team1pos.y);
		for (uint i = 0; i < _allchats.length; i++)
		{
			Portrait@ p = _allchats[i];

			u32 linesize = 0;
			if(p.chat.length > 0)
			{
				linesize = p.chat[0].size();
			}

			const f32 p_bounce_amount = (p.chatTimer > 0.0f && linesize > 0) ?
							(Maths::Sin(1.0f * (time + i * 13)) * 5) * 0.5f :
							0.0f;

			// set vertical pos

			Vec2f iconpos;
			if (p.side == 0)
			{
				iconpos = team1pos;
				iconpos.x -= team_width * (1.0f - p.showTimer);
				team1pos.y += portraitVerticalSpace;
			}
			else
			{
				iconpos = team2pos;
				iconpos.x += team_width * (1.0f - p.showTimer);
				team2pos.y += portraitVerticalSpace;
			}

			// radio

			Vec2f upper = (iconpos - _portraitSize * 0.5f) + Vec2f(-team_margin, 8);
			Vec2f lower =  upper + Vec2f(team_width, _portraitSize.y);
			{
				Vec2f upper = (iconpos - _portraitSize * 0.5f) + Vec2f(-team_margin, 8);
				Vec2f lower =  upper + Vec2f(team_width, _portraitSize.y);
				if (p.side == 1)
				{
					upper.x -= team_width - _portraitSize.x - team_margin * 2;
					lower.x -= team_width - _portraitSize.x - team_margin * 2;
				}

				DrawTRGuiFrame(upper, lower);
			}

			GUI::DrawIcon(_portraits_file, p.icon, _portraitSize, iconpos - _portraitSize * 0.5f + Vec2f(0.0f, p_bounce_amount), 0.5f);

			// name

			u32 colour = Colours::WHITE;
			if(this.get_string("gamemode") == "Campaign")
			{
				colour = ((p.side == 0) ? Colours::TEAM1 : Colours::TEAM2);
			}


			if (p.side == 0)
			{
				Vec2f textpos = iconpos + Vec2f(_portraitSize.x * 0.5f, -_portraitSize.y * 0.5f + 4);
				GUI::DrawText(p.name, textpos, colour);
			}
			else
			{
				Vec2f nameDim;
				GUI::GetTextDimensions(p.name, nameDim);
				Vec2f textpos = iconpos + Vec2f(-_portraitSize.x * 0.5f - nameDim.x - 3, -_portraitSize.y * 0.5f + 4);
				GUI::DrawText(p.name, textpos, colour);
			}
			//printf("p.name " + i + " " + p.name);

			// awards

			if (p.chat.length == 0)
			{
				// awards display is a mess :(
			/*	for (uint fieldsCounter = 0; fieldsCounter < p.fields.length; fieldsCounter++)
				{
					string field = p.fields[fieldsCounter];
					Vec2f dim;
					GUI::GetTextDimensions(field, dim);
					const f32 extra_px = 4.0f;
					const f32 xd = (p.side == 0 ? _portraitSize.x + extra_px : -dim.x - extra_px);
					GUI::DrawText(field, upper + Vec2f(xd, 8.0f + i * 8.0f), Colours::WHITE);
				}*/
			}
			// chat
			else
			{
				for (u32 i = 0; i < p.chat.length && i < 3; i++)
				{
					string chat = p.chat[i];
					Vec2f nameDim;
					GUI::GetTextDimensions(chat, nameDim);
					const f32 extra_px = 4.0f;
					const f32 xd = (p.side == 0 ? _portraitSize.x + extra_px : -nameDim.x - extra_px);
					GUI::DrawText(chat, upper + Vec2f(xd, 8.0f + i * 10.0f), Colours::WHITE);
				}
			}
		}
	}
}

//helpers

void UpdatePortrait(Portrait@ p, CPlayer@ player)
{
	p.name = player.getCharacterName();
	p.team = player.getTeamNum();
	p.icon = getCharacterFor(p.team, player.getClassNum()).frame;
	p.player_id = player.getNetworkID();
	const f32 dt = 1.0f / 30.0f;

	const bool isCampaign = getRules().get_string("gamemode") == "Campaign";

	if (p.chat.length > 0)
	{
		p.chatTimer -= dt * Maths::Max(1.0f, (p.chat.length - 3.0f) * 0.5f);
		if (p.chatTimer <= 0)
		{
			if (p.chat.length > 0)
			{
				p.chat.removeAt(0);
				if (p.chat.length > 0)
				{
					p.chatTimer = timeForLine(p.chat[0]);
				}
			}
		}
	}
	else
	{
		if (isCampaign && getRules().isIntermission())
		{
			p.showTimer = 1.0f;
		}
		else
		{
			p.showTimer -= dt;
		}
	}
}

void UpdatePlayerPortraits(CRules@ this)
{
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);

		// update existing portrait

		bool portraitFound = false;
		for (uint j = 0; j < _portraits.length; j++)
		{
			Portrait@ p = _portraits[j];
			if (p.player_id == player.getNetworkID())
			{
				UpdatePortrait(p, player);
				portraitFound = true;
				break;
			}
		}

		// create new portrait if not found
		if (!portraitFound)
		{
			Portrait p;
			p.player_id = player.getNetworkID();
			UpdatePortrait(p, player);
			_portraits.push_back(p);
		}
	}

	// remove portraits if player left

	for (uint j = 0; j < _portraits.length; j++)
	{
		Portrait@ p = _portraits[j];
		bool foundPlayer = getPlayerByNetworkId(p.player_id) !is null;

		if (!foundPlayer)
		{
			//remove from allchats
			for(u32 _ac_i = 0; _ac_i < _allchats.length; _ac_i++)
			{
				if(_allchats[_ac_i].player_id == p.player_id)
				{
					_allchats.removeAt(_ac_i--);
				}
			}
			_portraits.removeAt(j--);
		}
	}
}

Portrait@ getPortraitOfPlayer(CPlayer@ player, Portrait[]@ portraits)
{
	for (uint i = 0; i < portraits.length; i++)
	{
		if (portraits[i].player_id == player.getNetworkID())
			return portraits[i];
	}
	return null;
}

f32 timeForLine(string line)
{
	//special case for spacers
	if (line.size() == 0)
		return 0.2f;

	return Maths::Max(1.0f, line.size() / 10.0f);
}

//chops into lines for consumption
string[] chopChatLines(string &in text_in)
{
	string line = text_in;
	string[] lines;

	s32 line_cutoff = 14;
	while (line.size() > 0)
	{
		if (line.size() < line_cutoff)
		{
			lines.push_back(line);
			line = "";
		}
		else
		{
			//zoom to last space + handle no spaces nicely enough
			uint position = line_cutoff;
			bool foundspace = false;
			for (uint i = 0; i < line_cutoff; i++)
			{
				if (line[i] == 0x20) //space
				{
					position = i;
					foundspace = true;
				}
			}

			lines.push_back(line.substr(0, position));
			line = line.substr(position + (foundspace ? 1 : 0));
		}
	}

	return lines;
}

//placement logic stuff
int findFreeSide(u32 preferred)
{
	u32 leftfree = 5;
	u32 rightfree = 5;
	for (u32 i = 0; i < _allchats.length; i++)
	{
		Portrait@ p = _allchats[i];
		if (p.side == 0)
			leftfree--;
		else
			rightfree--;
	}
	if (preferred == 255)
		return (leftfree >= rightfree && leftfree > 0) ? 0 : ((rightfree > 0) ? 1 : -1);
	else
		return ((preferred == 0 || rightfree == 0) && leftfree > 0) ? 0 : ((rightfree > 0) ? 1 : -1);
}

bool isPresent(Portrait@ p)
{
	for (u32 i = 0; i < _allchats.length; i++)
	{
		if (_allchats[i] is p)
			return true;
	}
	return false;
}

void EnsurePresent(Portrait@ p)
{
	if (isPresent(p))
		return;

	int sidefree = findFreeSide(p.team % 2);
	if (sidefree == -1)
	{
		//remove the last talking chat
		u32 mintime = _allchats[0].lastSpoke;
		u32 at = 0;
		for (u32 i = 1; i < _allchats.length; i++)
		{
			u32 curtime = _allchats[i].lastSpoke;
			if (curtime < mintime)
			{
				at = i;
				sidefree = _allchats[i].side;
			}
		}
		_allchats.removeAt(at);
	}

	p.showTimer = 1.0f;
	p.side = sidefree;
	_allchats.push_back(p);
}
