#include "UI.as"

const int SPEED = 2;

void onInit(CRules@ this)
{
	this.set_string("scrolling text", "");
}

void onTick(CRules@ this)
{
	this.Sync("scrolling text", true);
}

void onRender(CRules@ this)
{
	if (UI::hasAnyContent())
		return;

	string text = this.get_string("scrolling text");
	if (text == "")
		return;

	GUI::SetFont("gui");

	const u32 time = getGameTime();
	const int screenWidth = getDriver().getScreenWidth();

	f32 pad = 64.0f;

	Vec2f dim;
	GUI::GetTextDimensions(text, dim);
	const u16 yoffset = this.get_u16("scrolling text offset");

	int wrap = Maths::Max(dim.x + pad, screenWidth);
	int xpos = screenWidth - ((time * SPEED) % wrap);
	GUI::DrawText(text, Vec2f(-dim.x + xpos, yoffset), color_white);
	GUI::DrawText(text, Vec2f(-dim.x + wrap + xpos, yoffset), color_white);

	if (dim.x < screenWidth / 2 - 50)
	{
		GUI::DrawText(text, Vec2f(-dim.x + xpos + (xpos > screenWidth / 2 ? -1 : 1) * screenWidth / 2, yoffset), color_white);
		GUI::DrawText(text, Vec2f(-dim.x + screenWidth + xpos + (xpos > screenWidth / 2 ? -1 : 1) * screenWidth / 2, yoffset), color_white);
	}
}
