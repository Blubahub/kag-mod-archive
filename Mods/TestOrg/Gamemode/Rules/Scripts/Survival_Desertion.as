void onRender(CRules@ this)
{	
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) return;

	CBlob@ b = p.getBlob();
	if (b !is null)
	{
		u32 teamkick_time = p.get_u32("teamkick_time");
		
		// print("" + teamkick_time);
		
		if (getGameTime() > teamkick_time)
		{
			p.set_u32("teamkick_time", 0);
		}
		else if (getGameTime() < teamkick_time)
		{
			u32 secs = ((teamkick_time - 1 - getGameTime()) / getTicksASecond()) + 1;
			
			f32 offset = -30;
			
			string units = ((secs != 1) ? "seconds" : "second");
			GUI::SetFont("menu");
			GUI::DrawText("You have deserted your former faction!",
				Vec2f(getScreenWidth() / 2 - 160.0f, getScreenHeight() / 3 + offset + 0.0f + Maths::Sin(getGameTime() / 5.0f) * 5.0f),
			    SColor(255, 255, 55, 55));
				
			GUI::DrawText("Therefore, you are unable to join another faction for " + secs + " " + units + "." ,
				Vec2f(getScreenWidth() / 2 - 220.0f, getScreenHeight() / 3 + offset + 20.0f + Maths::Sin(getGameTime() / 5.0f) * 5.0f),
			    SColor(255, 255, 55, 55));
		}
	}
}