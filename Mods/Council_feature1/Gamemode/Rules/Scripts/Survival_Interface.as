//#include "TDM_Structs.as";
#include "ScoreboardCommon.as";

const string kagdevs = "geti;mm;flieslikeabrick;furai;jrgp;";
const string devs = "pirate-rob;";
const string council = "an_obamanation;joshua12131415;asger75;SJD360;BarsukEughen555;Olimarrex;jimmyzoudcba;JackMcDaniels;AgentHightower;";

void onRenderScoreboard(CRules@ this)
{
	//sort players
	CPlayer@[] sortedplayers;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		int team = p.getTeamNum();
		bool inserted = false;
		for (u32 j = 0; j < sortedplayers.length; j++)
		{
			if (sortedplayers[j].getTeamNum() < team)
			{
				sortedplayers.insert(j, p);
				inserted = true;
				break;
			}
		}
		if (!inserted)
			sortedplayers.push_back(p);
	}

	//draw board

    drawServerInfo(40);

	f32 stepheight = 16;
	Vec2f topleft(100, 150);
	Vec2f bottomright(getScreenWidth() - 100, topleft.y + (sortedplayers.length + 3.5) * stepheight);
	GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));
	
	//offset border

	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	//draw player table header

	GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	GUI::DrawText("User Name", Vec2f(topleft.x + 300, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Ping", Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Title", Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 0.5f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	CSecurity@ security = getSecurity();
	
	//draw players
	for (u32 i = 0; i < sortedplayers.length; i++)
	{
		CPlayer@ p = sortedplayers[i];

        bool playerHover = mousePos.y > topleft.y && mousePos.y < topleft.y + 15;
        
        if(p is null)
        	continue;

		topleft.y += stepheight;
		bottomright.y = topleft.y + stepheight;

		Vec2f lineoffset = Vec2f(0, -2);

		u32[] teamcolours = {0xff6666ff, 0xffff6666, 0xff33660d, 0xff621a83, 0xff844715, 0xff2b5353, 0xff2a3084, 0xff647160};
		u32 playercolour = teamcolours[p.getTeamNum() % teamcolours.length];

		if(p.getTeamNum() >= 100)
		{
			playercolour = 0xffbfbfbf;
		}
		if(playerHover)
        {
            playercolour = 0xffffffff;
        }

		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xff404040));
		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

		string tex = "";
		u16 frame = 0;
		Vec2f framesize;
		if (p.isMyPlayer())
		{
			tex = "ScoreboardIcons.png";
			frame = 4;
			framesize.Set(16, 16);
		}
		else
		{
			tex = p.getScoreboardTexture();
			frame = p.getScoreboardFrame();
			framesize = p.getScoreboardFrameSize();
		}
		if (tex != "") GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());

		string playername = (p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName();
		string username = p.getUsername();
		s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);

		GUI::DrawText((p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName(), topleft + Vec2f(20, 0), playercolour);
		GUI::DrawText(p.getUsername(), topleft + Vec2f(300, 0), playercolour);

		GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + getRank(p), Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));
	}
}

string getRank(CPlayer@ p)
{
	string username = p.getUsername().toLower() + ";";
	string seclev = getSecurity().getPlayerSeclev(p).getName();
	
	if (kagdevs.find(username) != -1) return "KAG Developer";
	else if (devs.find(username) != -1) return "Coder";
	else if (council.find(username) != -1) return "Council Member";
	else if (username == "vamist;") return "Glorious Server Host";
	else if (seclev != "Normal") seclev;
	
	return "";
}

string getStatus(CPlayer@ p)
{
	CBlob @blob = p.getBlob();
	
	if(blob is null)return "";
	
	if(blob.getName() == "humanoid")return "Alive";
	else return "Dead";
	
	return "";
}