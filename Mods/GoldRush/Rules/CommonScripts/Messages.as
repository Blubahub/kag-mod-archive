const int resetDefaultTime = 240 * 30; //every 4 minutes
int timeToReset = resetDefaultTime; 
bool showChatMessage = false;

void onRestart( CRules@ this )
{
	this.set_bool("show restart message", false);
}

void onRender( CRules@ this )
{
	const string chatMessage = "Mod is created by Diprog(scripter) and Inferdy(artist).\nHave fun!";
	Vec2f middle2(getScreenWidth()/2.0f, getScreenHeight()/2.0f);
	
	if (timeToReset > 0)
	{
		timeToReset --;
		
		if (showChatMessage)
		{
			client_AddToChat(chatMessage, SColor(255, 255, 0, 0));
			showChatMessage = false;
		}
	}
	else if (timeToReset <= 0)
	{
		showChatMessage = true;
		timeToReset = resetDefaultTime;
	}
}
