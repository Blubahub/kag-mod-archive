#define CLIENT_ONLY

bool canShow = true;
u32 timer = 1800;

string rules = "JailBreak rules:\n\n"
+ "Guards: Give commands to prisoners, keep order in the prison, don't kill prisoners without reason\n"
+ "Prisoners: (Do not)Listen to guards\n"
+ "Have fun!\n\n\n"
+ "Possible reasons to kill a prisoner:\n" + "1. The prisoner has killed a guard\n" + "2. The prisoner is attacking you or other guard\n"
+ "3. The prisoner is destroying the prison\n" + "4. The prisoner is trying to escape the prison\n"
+ "5. The prisoner is not executing your commands\n" + "6. The prisoner is afk\n\n\n"
+ "This message will disappear automatically after 60 seconds. If you want to show or hide that message type !rules in chat";

void renderRules()
{
	s32 scrw = getScreenWidth();
	s32 scrh = getScreenHeight();

	s32 w = 800;
	s32 h = 232;

	Vec2f tl(scrw / 2 - w / 2, 120);
	Vec2f br(scrw / 2 + w / 2, 120 + h);
	
	GUI::DrawButton(tl, br);
	GUI::DrawText(rules, tl + Vec2f(10, 10), br - Vec2f(10, 10), color_white, true, true, false);
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(text_in == "!rules" && !getNet().isServer() && getLocalPlayer().getUsername() == player.getUsername())
	{
		if(timer > 0)
		{
			canShow = false;
			timer = 0;
		}
		else
		{
			canShow = true;
			timer = 1800;
		}
	}

	return true;
}

void onTick(CRules@ this)
{
	if(timer > 0)
	{
		timer--;
	}
	
	canShow = (timer > 0);
}

void onRender(CRules@ this)
{
	if(canShow)
	{
		renderRules();
	}
}