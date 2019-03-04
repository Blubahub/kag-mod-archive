void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
	{
		return;
	}
	
	CBlob@ blob = this.getBlob();
	if (blob is null)
	{
		return;
	}
	
	CPlayer@ player = blob.getPlayer();
	if (player is null)
	{
		return;
	}
	
	if (!player.hasTag("help menu"))
	{
		return;
	}
	
	Vec2f pos = blob.getInterpolatedScreenPos() + Vec2f(0.0f, -50.0f);
	GUI::SetFont("main");
	GUI::DrawPane(Vec2f(pos.x - 167, pos.y - 35), Vec2f(pos.x + 167, pos.y + 60), SColor(255,175,175,175));
	GUI::DrawText("Players drop coins when hit. Pick them up to get coins!", Vec2f(pos.x - 162, pos.y - 30), Vec2f(pos.x + 162, pos.y - 30), SColor(255, 255, 255, 255), true, true);
	GUI::DrawText("The team with the most coins among all players wins at the end!", Vec2f(pos.x - 162, pos.y - 15), Vec2f(pos.x + 162, pos.y - 15), SColor(255, 255, 255, 255), true, true);
	GUI::DrawText("The higher your % number, the more knockback you take.", Vec2f(pos.x - 162, pos.y), Vec2f(pos.x + 162, pos.y), SColor(255, 255, 255, 255), true, true);
	GUI::DrawText("Knights can double jump, and shielding reflects knockback.", Vec2f(pos.x - 162, pos.y + 15), Vec2f(pos.x + 162, pos.y + 15), SColor(255, 255, 255, 255), true, true);
	GUI::DrawText("Archers have a coin magnet.", Vec2f(pos.x - 162, pos.y + 30), Vec2f(pos.x + 162, pos.y + 30), SColor(255, 255, 255, 255), true, true);
	GUI::DrawText("Press H to hide this message.", Vec2f(pos.x - 162, pos.y + 45), Vec2f(pos.x + 162, pos.y + 45), SColor(255, 255, 255, 255), true, true);
}