//Made by Vamist
//Level UI
//Client only (server does not render stuff)
const bool AlphaRelease = true;
const string AlphaText = "Alpha test, please read me\nTo level up use the tent second button\nThis will change the classes available\nThats all for now (report all bugs pls)";

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	//print("Hello world from level up UI");
	//Coming soon
}


void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer())
		return;

	if(p.getBlob() !is null)
	{
		GUI::SetFont("");//sets it to normal font
		GUI::DrawText("Debug UI", Vec2f(85,20), SColor(255,40,200,200));
		GUI::DrawPane(Vec2f(85,35), Vec2f(300,180), SColor(200,50,50,50));
		GUI::DrawText("Team 0 level : " + this.get_u8("0TL"), Vec2f(90,40), SColor(255,255,255,255));
		GUI::DrawText("Team 1 level : " + this.get_u8("1TL"), Vec2f(90,60), SColor(255,255,255,255));
		GUI::DrawText("Blob name : " + p.getBlob().getName(), Vec2f(90,80), SColor(255,255,255,255));
		GUI::DrawText("Game time : " + (getGameTime() / 30) + "s ("+getGameTime()+")", Vec2f(90,100), SColor(255,255,255,255));
		if(AlphaRelease)
		{
			GUI::DrawText(AlphaText,Vec2f(90,120),SColor(255,255,255,255));
		}

		CControls@ c = getControls();

	}
}