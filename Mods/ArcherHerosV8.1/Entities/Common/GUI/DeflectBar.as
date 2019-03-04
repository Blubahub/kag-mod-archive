// draws a health bar on mouse hover

void onRender(CSprite@ this)
{
CPlayer@ p = getLocalPlayer();
	if (g_videorecording  || !p.isMyPlayer())
		return;

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
  SColor thecolor = blob.isKeyPressed(key_action2) ? SColor(0xffff0000) : SColor(0xff0000ff);
		//VV right here VV
		Vec2f pos2d = blob.getScreenPos() - Vec2f(0, 20);
		Vec2f dim = Vec2f(24, 8);
		const f32 y = blob.getHeight() * 2.4f;
		const f32 initialHealth = 45.0f;
		if (initialHealth > 0.0f)
		{
			const f32 perc = blob.get_f32("Deflect") / initialHealth;
			if (perc >= 0.0f)
			{
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y +2));
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y +2), Vec2f(pos2d.x - dim.x + perc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), thecolor);
        
			}
		}
	
}