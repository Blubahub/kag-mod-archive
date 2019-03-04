#define CLIENT_ONLY

bool canShow = true;
u32 timer = 1800;

string rules = "JailBreak rules:\n\n"
+ "---How to play ---\n"
+ "As a Prisoner your goal is to escape and eliminate all the guards in a civilized manner.\n"
+ "As a Guard your goal is to prevent the Prisoners from escaping trough various means.\n"
+ "For example you can give them different kinds of work to do, or just have fun.\n"
+ "But if The Prisoners are doing something against your will, just act accordingly.\n"
+ "Take especially note to the fourth and fifth rule of the Guards. They should always warn you before eliminating you.\n"
+ "--- RULES ---\n"
+ "Guards:\n"
+ "1. Do not kill the prisoners inside cells\n"
+ "2. Do not kill the prisoners without reason\n"
+ "3. Before killing a prisoner warn him by jabbing him once\n"
+ "4. Always warn the prisoner literally in the chat before attacking\n"
+ "5. Give commands to the prisoners\n\n\n" //4
+ "Possible reasons to attack/kill the prisoner:\n"
+ "1. The prisoner has killed a guard ***\n"
+ "2. The prisoner is attacking you or other guard ***\n"
+ "3. The prisoner is destroying the prison\n"
+ "4. The prisoner is trying to escape the prison ***\n"
+ "5. The prisoner is not executing your commands ***\n"
+ "6. The prisoner is last living prisoner ***\n"
+ "7. The prisoner is AFK ***\n\n\n"
+ "*** - You can break the 1st Guard rule\n\n"
+ " - Modification Originally Created By PLDragON\n"
+ " - Remember to have fun, and report rulebreakers either to Discord or to the Adminstractors In-Game!\n"
+ "This message will disappear automatically after 60 seconds. To hide this message type !accept in the chat. Type !rules to show it again.";

void renderRules()
{
	s32 scrw = getScreenWidth();
	s32 scrh = getScreenHeight();

	s32 w = 800;
	s32 h = 400; //296

	Vec2f tl(scrw / 2 - w / 2, 120);
	Vec2f br(scrw / 2 + w / 2, 120 + h);
	
	GUI::DrawButton(tl, br);
	GUI::DrawText(rules, tl + Vec2f(10, 10), br - Vec2f(10, 10), color_white, true, true, false);
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(text_in == "!rules" && !getNet().isServer() && getLocalPlayer().getUsername() == player.getUsername())
	{
		canShow = true;
		timer = 1800;
	}
	
	if(text_in == "!accept" && !getNet().isServer() && getLocalPlayer().getUsername() == player.getUsername())
	{
		canShow = false;
		timer = 0;
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