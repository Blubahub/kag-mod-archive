#define CLIENT_ONLY

int TIME = 10 * 30;
int showTime = TIME;
bool showtut = false;
Vec2f vibro = Vec2f(0, 1.0f);
f32 vibroModifier = 1.2f;
void Reset(CRules@ this)
{
	showTime = TIME;
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	CControls@ cls = getControls();
	if (cls.isKeyJustPressed(KEY_KEY_X))
	{
		showtut = !showtut;
	}
}

void onRender(CRules@ this)
{
	const string credits = "Thanks for playing on this server!\nMod created by Diprog and RaptorAnton\n\nDiprog - programmer\nRaptorAnton - artist\nGo to the tiny.cc/funservers for more information\n\n";
	//const string restart = "Mod has been updated. Server will restart at the end of this round. We recommend you to reload the game before rejoining server.";
	const string help = "!!!Press X for tutorial; Press V to select new heads!!!";
	Vec2f middle;
	Vec2f middleTut(getScreenWidth()/2.0f, getScreenHeight()/2.0f);
	//########## TUTORIAL ##########
	const string tutorial_image = "GUI/Tutorial/FUNTutorialPg1.png";

	if(showtut)
	{
		GUI::DrawIcon(tutorial_image, Vec2f(middleTut.x - (720/2) ,0), 0.5f);
	}

	//########## CREDITS ##########
	int screenWidth = getScreenWidth();
	if (vibro.y >= 0.0f)
	{
		showTime--;
		vibro.y+=vibroModifier;
		if (showTime > 0)
		{
			if (vibro.y >= 30.0f)
				vibroModifier=-0.4f;
			else if (vibro.y <= 20.0f)
				vibroModifier=0.4f;
		}
		else
			vibroModifier-=0.4;
		GUI::DrawText( credits + help, Vec2f(screenWidth - 190.0f, vibro.y), Vec2f(screenWidth + 180.0f, vibro.y), color_black, true, true, true );
	}
	
}
