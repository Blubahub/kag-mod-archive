#define CLIENT_ONLY

bool isShowing = true;
const Vec2f size(406.0f,118.0f); //window size
/*"const string txt = 
The creators are Diprog (coder), RaptorAnton(artist), RichardSTF (artist)\n" +
"\nRULES:" +
"\n1. Team killing\n" +
"Don't kill your teammates\n" +
"punishment - Ban for a day\n" +
"\n2. Griefing\n" +
"Don't grief your own team\n" +
"punishment - Permanent ban\n" +
"\n3. Bug abusing\n" +
"Don't abuse bugs\n" +
"punishment - Ban for a day\n" +
"\n4. Chat spaming\n" +
"Don't spam in chat\n" +
"punishment - Mute for hour\n" +
"\n5. Map voting spaming\n" +
"Don't spam map voting\n" +
"punishment - Kick\n" +
"\n6. Being rude\n" +
"Don't be rude\n" +
"punishment - Mute for 10 mins\n" +
"\n7. Trying to play or playing sandbox\n" +
"Don't play sandbox\n" +
"punishment - Ban for a day\n\n" +
"Press X to close";*/
const string txt =
"Diprog's and Rob's mod is a combination of\nDiprog's FUN mod and Rob's mod.\n\n" +
"FUN mod devs:\nDiprog (coder), RaptorAnton(artist), RichardSTF(artist)\n\n" +
"Robs's mod devs:\nPirate-Rob(coder), TFlippy,(artist), Sylw(artist)\n\n" +
"Press X to close";

void onTick(CRules@ this)
{
	CControls@ cls = getControls();
	if (cls.isKeyJustPressed(KEY_KEY_X))
	{
		isShowing = !isShowing;
	}
}

void onRender(CRules@ this)
{
	Vec2f mid(getScreenWidth()/2.0f, getScreenHeight()/2.0f);

	if(isShowing)
	{
		GUI::SetFont("menu");
		GUI::DrawWindow(Vec2f(mid.x - 10.0f - size.x/2, mid.y - 10.0f - size.y/2), Vec2f(mid.x + size.x/2 , mid.y + size.y/2));
		//GUI::DrawText( txt, Vec2f(mid.x - 185.0f, mid.y - 200.0f), Vec2f(mid.x + 220.0f, mid.y - 10.0f), color_black, true, true, true );
		GUI::DrawText(txt, Vec2f(mid.x - size.x/2, mid.y - size.y/2), color_black);
	}
}
