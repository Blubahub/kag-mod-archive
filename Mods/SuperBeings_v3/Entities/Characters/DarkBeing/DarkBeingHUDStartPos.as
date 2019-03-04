//for use with DefaultActorHUD.as based HUDs

const f32 HUD_X = 430.0f;
const f32 HUD_Y = getScreenHeight();

Vec2f getActorHUDStartPosition(CBlob@ blob, const u8 bar_width_in_slots)
{
	f32 width = bar_width_in_slots * 32.0f;
	return Vec2f(HUD_X + 160 + 50 - width, HUD_Y - 40);
}

void DrawInventoryOnHUD(CBlob@ this, Vec2f tl)
{
	GUI::DrawIcon("Soul.png", 0, Vec2f(16,16), tl, 1.0f);
	SColor col;
	f32 ratio = float(this.get_s16("power")) / float(1000);
	col = ratio > 0.4f ? SColor(255, 255, 255, 255) :
		  ratio > 0.2f ? SColor(255, 255, 255, 128) :
		  ratio > 0.1f ? SColor(255, 255, 128, 0) : SColor(255, 255, 0, 0);

	GUI::SetFont("menu");
	GUI::DrawText("" + this.get_s16("power"), tl + Vec2f(8, 24), col);
}

void DrawCoinsOnHUD(CBlob@ this, const int coins, Vec2f tl, const int slot)
{
	if (coins > 0)
	{
		GUI::DrawIconByName("$COIN$", tl + Vec2f(0 + slot * 32, 0));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins, tl + Vec2f(8 + slot * 32 , 24), color_white);
	}
}