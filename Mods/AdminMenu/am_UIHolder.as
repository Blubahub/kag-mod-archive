/// UI class


const f32 SCREEN_X      = getScreenWidth();
const f32 SCREEN_Y 		= getScreenHeight();
const f32 SCREEN_X_HALF = SCREEN_X / 2;
const f32 SCREEN_Y_HALF = SCREEN_Y / 2;


class aMenu
{
	bool isUserATrialModerator  = false;
	bool isUserAModerator 		= false;
	bool isUserAAdmin 			= false;
	bool isUserATrustedAdmin    = false;
	bool isUserAOwner 			= false;
	int boxCount				= 0;


	aMenu()//onInit
	{
		print("hi");
		render();
		//check for admin
		//
	}

	void mousePos()
	{
		/*CControls@ controls = getControls();
		int mousePos = controls.getMouseScreenPos().length();
		bool mouseClicked = controls.isKeyJustPressed(KEY_LBUTTON);
		if(mouseClicked)
		{
			for(int i = 0; i < allTrailPos.length(); i++)//check to see if any buttons was clicked (store each num in array or something??)
			{
				//
			}
		}*/
	}


	void render()
	{
		//render ui once then again on switch

		print("render started");
		Render::addScript(Render::layer_posthud, "am_UIRender.as", "RenderBackground", 100.0f);//Background
		boxCount += 1;
		Render::addScript(Render::layer_posthud, "am_UIRender.as", "renderButton", 101.0f);//Background



	}

	//do something on click
	void doOnClick(int command)
	{
		print("ye");
	}

	void warning()
	{
		print("warning");
		//create a warning before doing x command (only if op)
	}

	void logToServer()
	{
		print("log");
	}
}


/*

	Vec2f botPos = getDriver().getWorldPosFromScreenPos(Vec2f(0 + 50,SCREEN_Y - 50));
	Vec2f centerPosTop = getDriver().getWorldPosFromScreenPos(Vec2f(SCREEN_X_HALF - 200,SCREEN_Y_HALF - 200));
	Vec2f centerPosBot = getDriver().getWorldPosFromScreenPos(Vec2f(SCREEN_X_HALF + 200,SCREEN_Y_HALF + 200));

*/