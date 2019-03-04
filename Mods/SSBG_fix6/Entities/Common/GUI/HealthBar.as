// draws a health bar on mouse hover

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

    CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;		 
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	
	
	Vec2f pos2d = blob.getScreenPos();
	Vec2f dim = Vec2f(24,8);
	const f32 y = blob.getHeight()*2.4f;;
	
	f32 currentHealth = blob.getHealth();
	f32 initialHealth = blob.getInitialHealth();
	f32 fractionHealth = (initialHealth - currentHealth)/initialHealth;
	int percentHealth = fractionHealth * 1000;
	int hue = 255 - 255 * fractionHealth^2;

	SColor col =  SColor(255, 255, hue, hue);
	GUI::DrawText(""+percentHealth+"%", Vec2f(pos2d.x - dim.x+10, pos2d.y + y-75), col);
	
}
