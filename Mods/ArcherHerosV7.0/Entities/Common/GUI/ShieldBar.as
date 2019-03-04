// draws a health bar on mouse hover

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	if (blob.isKeyPressed(key_action2))
	{
		//VV right here VV
		Vec2f pos2d = blob.getScreenPos() - Vec2f(0, 20);
		Vec2f dim = Vec2f(24, 8);
		const f32 y = blob.getHeight() * 2.4f;
		const f32 initialHealth = 24.0f;
		if (initialHealth > 0.0f)
		{
			const f32 perc = blob.get_f32("Shield") / initialHealth;
			if (perc >= 0.0f)
			{
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 52), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y -48));
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y -48), Vec2f(pos2d.x - dim.x + perc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 52), SColor(0xff0000ff));
        
			}
		}
	}
}