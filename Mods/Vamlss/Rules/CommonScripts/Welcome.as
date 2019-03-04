#define CLIENT_ONLY

bool isShowing = true;
const Vec2f size(300.0f,100.0f); //window size
const string txt =
"Server hosted by Vamist!\n\n" +
"The maker of this mod is;\nEnter name here\n\n" +
"Press Z to close";

void onTick(CRules@ this)
{
	CControls@ cls = getControls();
	if (cls.isKeyJustPressed(KEY_KEY_Z))
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
		GUI::DrawText(txt, Vec2f(mid.x - size.x/2, mid.y - size.y/2), color_black);
	}
}
