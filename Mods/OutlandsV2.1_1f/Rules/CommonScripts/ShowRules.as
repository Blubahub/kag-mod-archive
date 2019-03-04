#define CLIENT_ONLY

bool isShowing = true;
const Vec2f size(480.0f, 240.0f); //window size
const string txt = 
"\n                                  == Welcome to Outlands ==" +
"\n\n                               Its an roleplay server!" +
"\n       Rules: Dont Kill / Grief / Annoy peoples without RP reason!" +
"\n                                 or else you will get banned (:" +
"\n\n                                     To team up with someone" +
"\n                   you'r friend need to make key in builder shop," +
"\n                  key will allow you to open your friend doors" +
"\n                 and his spikes and trapdoors wont affect you." +
"\n                You can now have multiple friends at same time!" +
"\n                                  If you die, you lost all keys." +
"\n\n                                           Have a nice stay!" +
"\n\n     Also, we need some maps right now, if you wanna make one," +
"\n                                contact GoldenGuy on forum!" +
"\n\n                                           Press H to close";


void onTick(CRules@ this)
{
	CControls@ cls = getControls();
	if (cls.isKeyJustPressed(KEY_KEY_H))
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
