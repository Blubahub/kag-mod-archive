//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "CaveStoryGUI.as"

void renderBackBar(Vec2f origin, f32 width, f32 scale)
{
	for (f32 step = 0.0f; step < width / scale - 64; step += 64.0f * scale)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(step * scale, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(width - 128 * scale, 0), scale);
}

void renderFrontStone(Vec2f farside, f32 width, f32 scale)
{
	for (f32 step = 0.0f; step < width / scale - 16.0f * scale * 2; step += 16.0f * scale * 2)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-step * scale - 32 * scale, 0), scale);
	}

	if (width > 16)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-width, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), farside + Vec2f(-width - 32 * scale, 0), scale);
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), farside, scale);
}

void renderHPBar(CBlob@ blob, Vec2f origin)
{
	string heartFile = "GUI/HealthBarSegments.png";
	int segmentWidth = 32;
	int healthBarOffset = 90;
	float HP = blob.getHealth();
	float initialHealth = blob.getInitialHealth();
	int numberOffset = 32;

	GUI::DrawIcon("Entities/Common/GUI/HealthBarBase.png", 0, Vec2f(80, 16), origin + Vec2f(healthBarOffset + 6, 18));	
	
	GUI::DrawIcon("Entities/Common/GUI/HealthBarHealth.png", 0, Vec2f(HP*78/initialHealth, 16), origin + Vec2f(healthBarOffset + 6, 18));
	
	GUI::DrawIcon("Entities/Common/GUI/HealthCountBase.png", 0, Vec2f(48, 16), origin + Vec2f(0, 18));

	CaveStoryGUI::DrawNumber(HP * 8, origin + Vec2f(30 + 64, 16));
	
	
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
	Vec2f dim = Vec2f(362, 64);
	Vec2f ul(40, 80);
	Vec2f lr(ul.x + dim.x, ul.y + dim.y);
	//GUI::DrawPane(ul, lr);
	//renderBackBar(ul, dim.x, 1.0f);
	u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
	f32 width = bar_width_in_slots * 32.0f;
	//renderFrontStone(ul + Vec2f(dim.x + 32, 0), width, 1.0f);
	renderHPBar(blob, ul + Vec2f(0, 32));
	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}
