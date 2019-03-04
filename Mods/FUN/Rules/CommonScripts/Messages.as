const f32 creditsTime = 300 * 30; //every 5 mins
void onRestart( CRules@ this )
{
	//######## RESTART MESSAGE ##########
	//this.set_bool("show restart message", false);
}

void onRender( CRules@ this )
{
	//######## RESTART MESSAGE ##########
	//const string restart = "Mod has been updated. Server will restart at the end of this round. We recommend you to reload the game before rejoining server.";
	//Vec2f middle2(getScreenWidth()/2.0f, getScreenHeight()/2.0f);
	
	/*if (this.get_bool("show restart message") && restartTime > 0)
	{
		restartTime --;
		
		GUI::DrawText( restart ,
			Vec2f(middle2.x - 160.0f, middle2.y), Vec2f(middle2.x + 160.0f, middle2.y), SColor(255, 255, 0,0), true, true, true );
	}
	else
	{
		this.set_bool("show restart message", false);
		restartTime = TIME2;
	}*/
	
	//######## CREDITS MESSAGE ##########
	const string chatMessage = "Join to the social forum at tiny.cc/funservers/\nPress X for rules and Press V for new heads.";
	if (getGameTime() >= this.get_f32("credits_time"))
	{
		//showing this credits message in chat
		client_AddToChat(chatMessage, SColor(255, 255, 0, 0));
		//refeshing the timer
		this.set_f32("credits_time", getGameTime() + creditsTime);
	}
}
