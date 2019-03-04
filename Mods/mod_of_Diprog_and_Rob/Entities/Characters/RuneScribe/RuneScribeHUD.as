//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "ActorHUDStartPos.as";
#include "RuneNames.as";

void renderFrontStone(CBlob@ blob, Vec2f farside)
{
	int width = blob.get_string("scroll").length();
	
	GUI::DrawIcon("ChatTexture.png", 0, Vec2f(16, 16), farside + Vec2f(-16, 0), 1.0f);
	GUI::DrawIcon("ChatTexture.png", 12, Vec2f(16, 16), farside + Vec2f(-16, 16), 1.0f);
	
	for (int step = 0; step < width; step += 1)
	{
		GUI::DrawIcon("ChatTexture.png", 1, Vec2f(16, 16), farside + Vec2f(step*32, 0), 1.0f);
		GUI::DrawIcon("ChatTexture.png", 2, Vec2f(16, 16), farside + Vec2f(step*32+16, 0), 1.0f);
		
		GUI::DrawIcon("ChatTexture.png", 13, Vec2f(16, 16), farside + Vec2f(step*32, 16), 1.0f);
		GUI::DrawIcon("ChatTexture.png", 14, Vec2f(16, 16), farside + Vec2f(step*32+16, 16), 1.0f);
		
		GUI::DrawIcon("RuneSymbols.png", getRuneFromLetter(blob.get_string("scroll").substr(step,1)), Vec2f(8, 8), farside + Vec2f(step*32+4, 8), 2.0f);
	}
	
	GUI::DrawIcon("ChatTexture.png", 3, Vec2f(16, 16), farside + Vec2f(width*32, 0), 1.0f);
	GUI::DrawIcon("ChatTexture.png", 15, Vec2f(16, 16), farside + Vec2f(width*32, 16), 1.0f);
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f ul(HUD_X - 180, HUD_Y - 96);
	renderFrontStone(blob, ul);
}
